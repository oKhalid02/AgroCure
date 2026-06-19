# Deploying the AgroCure backend to Hugging Face Spaces

Free CPU hosting for the FastAPI model server (`/predict`, `/chat`, …).

## One-time setup

1. **Create an account** at https://huggingface.co

2. **Create the Space**
   - Click your avatar → **New Space**
   - Name: `agrocure-api`
   - License: any (e.g. MIT)
   - **Space SDK: Docker** → **Blank**
   - Visibility: Public (or Private)
   - Create

3. **Add the OpenAI key as a secret** (so Sage works)
   - Open the Space → **Settings** → **Variables and secrets** → **New secret**
   - Name: `OPENAI_API_KEY`
   - Value: your `sk-...` key
   - Save

4. **Install tooling locally** (once)
   ```bash
   brew install git-lfs
   pip install -U "huggingface_hub[cli]"
   huggingface-cli login        # paste a WRITE token from HF → Settings → Access Tokens
   ```

## Deploy (and re-deploy on every change)

From the project root:
```bash
bash deploy/hf/push_to_space.sh <your-hf-username> agrocure-api
```

This copies `api/`, `src/`, and the 545 MB `checkpoints/` (via git-lfs) into the
Space, then pushes. The first build takes ~5–10 min; later code edits are fast
because the model files don't re-upload.

Watch the build log on the Space page. When it's green:

```
Live URL: https://<your-hf-username>-agrocure-api.hf.space
```

Check it: open `https://<...>.hf.space/health` in a browser.

## Point the app at the live backend

```bash
flutter run --dart-define=API_URL=https://<your-hf-username>-agrocure-api.hf.space
```

Or for a release build:
```bash
flutter build ipa --dart-define=API_URL=https://<your-hf-username>-agrocure-api.hf.space
```

## Notes
- Free Spaces sleep after inactivity and wake on the next request (first call is slow).
- The model loads lazily on the first `/predict`, so cold starts take a few extra seconds.
- "Edit → live": re-run `push_to_space.sh` after changes. (A GitHub Action can
  automate this on every push — ask when you want it.)
