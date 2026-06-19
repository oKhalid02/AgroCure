import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/botanica_theme.dart';
import '../models/prediction.dart';
import '../services/history_service.dart';
import '../widgets/arch_clipper.dart';
import '../widgets/confidence_dial.dart';
import '../widgets/buttons.dart';
import '../widgets/ambient_background.dart';
import 'chat_screen.dart';

class ResultScreen extends StatefulWidget {
  final Prediction prediction;
  final Uint8List imageBytes;

  const ResultScreen(
      {super.key, required this.prediction, required this.imageBytes});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    HistoryService.save(widget.prediction);
  }

  bool get _healthy => widget.prediction.disease.toLowerCase().contains('healthy');

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final p = widget.prediction;
    final topPad = MediaQuery.of(context).padding.top;
    final diseaseColor = _healthy ? c.sage : c.terra;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: Column(
        children: [
          // ---- arch-framed photo ----
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Stack(
              children: [
                ClipPath(
                  clipper: ArchClipper(),
                  child: Image.memory(
                    widget.imageBytes,
                    width: double.infinity,
                    height: 230,
                    fit: BoxFit.cover,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                // scrim blending photo into the canvas
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 90,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [c.bg.withValues(alpha: 0), c.bg],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: topPad + 8,
                  left: 18,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c.surf.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          size: 14, color: c.ink),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- diagnosis body ----
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IDENTIFIED',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: c.ink3,
                                    letterSpacing: 1.8)),
                            const SizedBox(height: 5),
                            Text(p.plant, style: Serif.style(26, c.ink)),
                            const SizedBox(height: 10),
                            Text(p.disease,
                                style: Serif.style(18, diseaseColor,
                                    italic: true)),
                            const SizedBox(height: 8),
                            _statusPill(c),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      ConfidenceDial(value: p.confidence, size: 112)
                          .animate()
                          .fadeIn(delay: 200.ms),
                    ],
                  ),
                  const Spacer(),
                  // gentle hint
                  Center(
                    child: Text(
                      _healthy
                          ? 'Looking healthy — ask Sage how to keep it that way'
                          : 'Ask Sage for a treatment plan',
                      style: TextStyle(color: c.ink3, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Ask Sage about this',
                    icon: Icons.chat_bubble_outline,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(prediction: p)),
                    ),
                  ),
                  const SizedBox(height: 11),
                  SecondaryButton(
                    label: 'Scan another',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _statusPill(BotanicaColors c) {
    final color = _healthy ? c.sage : c.terra;
    final text = _healthy ? 'Healthy' : 'Needs attention';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
