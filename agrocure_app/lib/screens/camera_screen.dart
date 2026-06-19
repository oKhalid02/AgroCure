import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/botanica_theme.dart';
import '../widgets/seedling_logo.dart';
import '../widgets/buttons.dart';
import '../widgets/ambient_background.dart';
import 'result_screen.dart';
import '../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  late final AnimationController _scan;

  static const _arch = BorderRadius.only(
    topLeft: Radius.circular(140),
    topRight: Radius.circular(140),
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
  );

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  Future<void> _pickAndPredict(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final bytes = await picked.readAsBytes();
      final result = await ApiService.predict(bytes);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                ResultScreen(prediction: result, imageBytes: bytes)),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    Text('Capture', style: Serif.style(18, c.ink)),
                  ],
                ),
                const SizedBox(height: 22),
                Expanded(child: _viewfinder(c, isDark)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  alignment: WrapAlignment.center,
                  children: [
                    _tip(c, 'Bright light'),
                    _tip(c, 'Single leaf'),
                    _tip(c, 'No blur'),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _errorBox(c),
                ],
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Take photo',
                  icon: Icons.camera_alt_rounded,
                  onTap: _loading
                      ? null
                      : () => _pickAndPredict(ImageSource.camera),
                ),
                const SizedBox(height: 11),
                SecondaryButton(
                  label: 'Choose from gallery',
                  onTap: _loading
                      ? null
                      : () => _pickAndPredict(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _viewfinder(BotanicaColors c, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.surf, Color.lerp(c.surf, c.bg, 0.5)!],
        ),
        borderRadius: _arch,
        border: Border.all(color: c.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _arch,
        child: Stack(
          children: [
            ..._brackets(c),
            // animated scan line
            if (!_loading)
              AnimatedBuilder(
                animation: _scan,
                builder: (context, _) {
                  return LayoutBuilder(builder: (context, box) {
                    final y = 40 + (_scan.value * (box.maxHeight - 80));
                    return Positioned(
                      top: y,
                      left: 28,
                      right: 28,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            c.acc.withValues(alpha: 0),
                            c.acc.withValues(alpha: 0.8),
                            c.acc.withValues(alpha: 0),
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: c.acc.withValues(alpha: 0.5),
                                blurRadius: 8),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            Center(
              child: _loading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: c.sage, strokeWidth: 2.5),
                        const SizedBox(height: 20),
                        Text('Analysing leaf…',
                            style: Serif.style(17, c.ink, italic: true)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 0.4,
                          child: SeedlingLogo(
                              size: 56, leafColor: c.ink, strokeWidth: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Text('Center the leaf',
                            style: Serif.style(18, c.ink, italic: true)),
                        const SizedBox(height: 6),
                        Text('Hold steady within the frame',
                            style: TextStyle(color: c.ink3, fontSize: 11)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _brackets(BotanicaColors c) {
    final color = c.acc.withValues(alpha: 0.7);
    const len = 22.0;
    final side = BorderSide(color: color, width: 2);
    Widget mk(Alignment a, Border b) => Align(
          alignment: a,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
                width: len, height: len, decoration: BoxDecoration(border: b)),
          ),
        );
    return [
      mk(Alignment.topLeft, Border(top: side, left: side)),
      mk(Alignment.topRight, Border(top: side, right: side)),
      mk(Alignment.bottomLeft, Border(bottom: side, left: side)),
      mk(Alignment.bottomRight, Border(bottom: side, right: side)),
    ];
  }

  Widget _errorBox(BotanicaColors c) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.terra.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.terra.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: c.terra, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not reach the model. Is the API running?',
              style: TextStyle(color: c.terra, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(BotanicaColors c, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: c.surf2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Text(text, style: TextStyle(color: c.ink2, fontSize: 10)),
    );
  }
}
