"""
AgroCure v4 — Stage 2 Single Plant Trainer
Called by individual notebook cells, one plant at a time.
"""

import os, csv, json, time
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, models
from PIL import Image
from collections import Counter
import mlflow
import config_v4 as config

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
MEAN   = [0.485, 0.456, 0.406]
STD    = [0.229, 0.224, 0.225]

class DiseaseDS(Dataset):
    def __init__(self, csv_path, disease_to_idx, transform):
        self.transform      = transform
        self.disease_to_idx = disease_to_idx
        self.samples        = []
        with open(csv_path) as f:
            for row in csv.DictReader(f):
                if row["label"] in disease_to_idx:
                    self.samples.append((row["path"], disease_to_idx[row["label"]]))
    def __len__(self): return len(self.samples)
    def __getitem__(self, idx):
        path, label = self.samples[idx]
        return self.transform(Image.open(path).convert("RGB")), label

def get_loaders(plant, disease_to_idx):
    tr_tf = transforms.Compose([
        transforms.Resize((config.IMG_SIZE+32, config.IMG_SIZE+32)),
        transforms.RandomCrop(config.IMG_SIZE),
        transforms.RandomHorizontalFlip(),
        transforms.RandomVerticalFlip(p=0.1),
        transforms.RandomRotation(25),
        transforms.ColorJitter(0.3, 0.3, 0.3, 0.05),
        transforms.RandomGrayscale(p=0.05),
        transforms.ToTensor(),
        transforms.Normalize(MEAN, STD),
        transforms.RandomErasing(p=0.2),
    ])
    vl_tf = transforms.Compose([
        transforms.Resize((config.IMG_SIZE, config.IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(MEAN, STD),
    ])
    plant_splits = os.path.join(config.SPLITS_DIR, plant)
    tr = DiseaseDS(f"{plant_splits}/train.csv", disease_to_idx, tr_tf)
    vl = DiseaseDS(f"{plant_splits}/val.csv",   disease_to_idx, vl_tf)
    return (DataLoader(tr, batch_size=config.BATCH_SIZE, shuffle=True,
                       num_workers=config.NUM_WORKERS, pin_memory=True),
            DataLoader(vl, batch_size=config.BATCH_SIZE, shuffle=False,
                       num_workers=config.NUM_WORKERS, pin_memory=True))

def build_model(num_classes):
    m = models.efficientnet_v2_s(weights=models.EfficientNet_V2_S_Weights.DEFAULT)
    m.classifier = nn.Sequential(
        nn.Dropout(p=config.DROPOUT),
        nn.Linear(m.classifier[1].in_features, num_classes)
    )
    return m.to(DEVICE)

def get_weights(csv_path, disease_to_idx):
    counts = Counter()
    with open(csv_path) as f:
        for row in csv.DictReader(f):
            if row["label"] in disease_to_idx:
                counts[disease_to_idx[row["label"]]] += 1
    total = sum(counts.values())
    n     = len(disease_to_idx)
    w     = torch.zeros(n)
    for i, c in counts.items(): w[i] = total / (n * c)
    return w

def mixup(x, y, alpha):
    if alpha <= 0: return x, y, y, 1.0
    lam = np.random.beta(alpha, alpha)
    idx = torch.randperm(x.size(0), device=x.device)
    return lam*x+(1-lam)*x[idx], y, y[idx], lam

def run_epoch(model, loader, criterion, optimizer=None, train=True):
    model.train() if train else model.eval()
    total_loss = correct = total = 0
    ctx = torch.enable_grad() if train else torch.no_grad()
    with ctx:
        for imgs, labels in loader:
            imgs, labels = imgs.to(DEVICE), labels.to(DEVICE)
            if train and config.MIXUP_ALPHA > 0:
                imgs, ya, yb, lam = mixup(imgs, labels, config.MIXUP_ALPHA)
                out  = model(imgs)
                loss = lam*criterion(out,ya)+(1-lam)*criterion(out,yb)
            else:
                out  = model(imgs)
                loss = criterion(out, labels)
            if train:
                optimizer.zero_grad(); loss.backward()
                nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()
            total_loss += loss.item()*imgs.size(0)
            correct    += (out.argmax(1)==labels).sum().item()
            total      += imgs.size(0)
    return total_loss/total, correct/total

def train_plant_model(plant, diseases):
    print(f"\n{'='*60}")
    print(f"  Training: {plant}  ({len(diseases)} diseases)")
    for d in diseases: print(f"    - {d}")
    print(f"  Device: {DEVICE}")
    print(f"{'='*60}")

    os.makedirs(config.MODELS_DIR, exist_ok=True)

    disease_labels  = [f"{plant}{config.DISPLAY_SEP}{d}" for d in diseases]
    disease_to_idx  = {label: i for i, label in enumerate(disease_labels)}
    num_diseases    = len(diseases)

    plant_key  = plant.replace(" ", "_").replace("-", "_")
    model_path = os.path.join(config.MODELS_DIR, f"stage2_{plant_key}.pth")
    info_path  = os.path.join(config.MODELS_DIR, f"stage2_{plant_key}_info.json")

    train_loader, val_loader = get_loaders(plant, disease_to_idx)

    if len(train_loader.dataset) == 0:
        print(f"  ⚠  No training data for {plant} — skipping")
        return

    weights   = get_weights(f"{config.SPLITS_DIR}/{plant}/train.csv", disease_to_idx)
    criterion = nn.CrossEntropyLoss(weight=weights.to(DEVICE),
                                     label_smoothing=config.LABEL_SMOOTH)
    model     = build_model(num_diseases)
    history   = {"phase_a":{"train_loss":[],"train_acc":[],"val_loss":[],"val_acc":[]},
                 "phase_b":{"train_loss":[],"train_acc":[],"val_loss":[],"val_acc":[]}}

    with mlflow.start_run(run_name=f"stage2_{plant_key}"):

        mlflow.log_params({
            "stage": 2, "plant": plant,
            "num_diseases": num_diseases,
            "model": "EfficientNetV2-S",
            "lr": config.S2_PHASE_B_LR,
            "diseases": str(diseases),
        })

        # ── Phase A ───────────────────────────────────────────
        print(f"\n  Phase A — warmup ({config.S2_PHASE_A_EPOCHS} epochs)")
        for p in model.parameters(): p.requires_grad = False
        for p in model.classifier.parameters(): p.requires_grad = True
        opt_a = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()),
                           lr=config.S2_PHASE_A_LR)

        for ep in range(1, config.S2_PHASE_A_EPOCHS+1):
            t0 = time.time()
            tl, ta = run_epoch(model, train_loader, criterion, opt_a, train=True)
            vl, va = run_epoch(model, val_loader,   criterion, train=False)
            history["phase_a"]["train_loss"].append(tl)
            history["phase_a"]["train_acc"].append(ta)
            history["phase_a"]["val_loss"].append(vl)
            history["phase_a"]["val_acc"].append(va)
            print(f"    Ep {ep}/{config.S2_PHASE_A_EPOCHS}  train={ta:.3f}  val={va:.3f}  [{time.time()-t0:.0f}s]")

        # ── Phase B ───────────────────────────────────────────
        print(f"\n  Phase B — fine-tune (max {config.S2_PHASE_B_EPOCHS} epochs, patience={config.S2_EARLY_STOP_PAT})")
        for p in model.parameters(): p.requires_grad = True
        opt_b = optim.AdamW(model.parameters(), lr=config.S2_PHASE_B_LR,
                            weight_decay=config.WEIGHT_DECAY)
        sched = optim.lr_scheduler.CosineAnnealingLR(opt_b,
                    T_max=config.S2_PHASE_B_EPOCHS, eta_min=config.LR_MIN)

        best_val_loss  = float("inf")
        patience_count = 0
        best_ep        = 0

        for ep in range(1, config.S2_PHASE_B_EPOCHS+1):
            t0 = time.time()
            tl, ta = run_epoch(model, train_loader, criterion, opt_b, train=True)
            vl, va = run_epoch(model, val_loader,   criterion, train=False)
            sched.step()
            lr_now = sched.get_last_lr()[0]
            history["phase_b"]["train_loss"].append(tl)
            history["phase_b"]["train_acc"].append(ta)
            history["phase_b"]["val_loss"].append(vl)
            history["phase_b"]["val_acc"].append(va)

            improved = vl < best_val_loss
            marker   = " ★" if improved else ""
            mlflow.log_metrics({
                f"train_acc": ta, f"val_acc": va,
                f"val_loss": vl,  f"lr": lr_now,
            }, step=ep)
            print(f"    Ep {ep:2d}/{config.S2_PHASE_B_EPOCHS}  train={ta:.3f}  val={va:.3f}  loss={vl:.4f}  lr={lr_now:.2e}  [{time.time()-t0:.0f}s]{marker}")

            if improved:
                best_val_loss  = vl
                patience_count = 0
                best_ep        = ep
                torch.save({
                    "epoch": ep, "model_state": model.state_dict(),
                    "val_loss": vl, "val_acc": va,
                    "plant": plant, "disease_labels": disease_labels,
                }, model_path)
            else:
                patience_count += 1
                if patience_count >= config.S2_EARLY_STOP_PAT:
                    print(f"\n    Early stopping at epoch {ep} (best was ep {best_ep})")
                    break

        # Save info + history
        with open(info_path, "w") as f:
            json.dump({
                "plant": plant,
                "disease_labels": disease_labels,
                "disease_to_idx": disease_to_idx,
                "best_val_loss": best_val_loss,
                "best_epoch": best_ep,
            }, f, indent=2)

        with open(f"{config.MODELS_DIR}/stage2_{plant_key}_history.json", "w") as f:
            json.dump(history, f, indent=2)

        mlflow.log_metric("best_val_loss", best_val_loss)

        print(f"\n  ✅ {plant} done!")
        print(f"     Best val loss : {best_val_loss:.4f}  (epoch {best_ep})")
        print(f"     Model saved   → {model_path}")
