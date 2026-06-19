import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The full Botanica palette, carried as a [ThemeExtension] so every colour
/// resolves correctly in both light and dark mode. Access it anywhere with
/// `context.c` (see the extension at the bottom of this file).
@immutable
class BotanicaColors extends ThemeExtension<BotanicaColors> {
  final Color bg;        // app canvas
  final Color surf;      // raised card
  final Color surf2;     // chip / inset
  final Color ink;       // primary text
  final Color ink2;      // secondary text
  final Color ink3;      // faint text / labels
  final Color line;      // hairline border
  final Color track;     // dial / meter track
  final Color acc;       // chartreuse accent
  final Color accInk;    // text on accent
  final Color terra;     // disease / warm
  final Color sage;      // success / confidence
  final Color hero;      // hero card (inverts the canvas)
  final Color heroInk;   // hero primary text
  final Color heroInk2;  // hero secondary text
  final Color heroLeaf;  // hero contour + sprout
  final Color heroCta;   // hero call-to-action fill
  final Color heroCtaInk;// hero call-to-action text
  final Color btn;       // primary button fill
  final Color btnInk;    // primary button text

  const BotanicaColors({
    required this.bg,
    required this.surf,
    required this.surf2,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.line,
    required this.track,
    required this.acc,
    required this.accInk,
    required this.terra,
    required this.sage,
    required this.hero,
    required this.heroInk,
    required this.heroInk2,
    required this.heroLeaf,
    required this.heroCta,
    required this.heroCtaInk,
    required this.btn,
    required this.btnInk,
  });

  static const light = BotanicaColors(
    bg: Color(0xFFECE7D9),
    surf: Color(0xFFFBF9F3),
    surf2: Color(0xFFF1ECDF),
    ink: Color(0xFF1B2D22),
    ink2: Color(0xFF5C6457),
    ink3: Color(0xFF90978A),
    line: Color(0xFFDED7C5),
    track: Color(0xFFE2DAC6),
    acc: Color(0xFFC7E05F),
    accInk: Color(0xFF26331A),
    terra: Color(0xFFC26B3E),
    sage: Color(0xFF3E7C4F),
    hero: Color(0xFF1B2D22),
    heroInk: Color(0xFFF4F1E6),
    heroInk2: Color(0xFF9FB0A2),
    heroLeaf: Color(0xFFC7E05F),
    heroCta: Color(0xFFC7E05F),
    heroCtaInk: Color(0xFF26331A),
    btn: Color(0xFF1B2D22),
    btnInk: Color(0xFFF4F1E6),
  );

  static const dark = BotanicaColors(
    bg: Color(0xFF0F130C),
    surf: Color(0xFF191E14),
    surf2: Color(0xFF222A1B),
    ink: Color(0xFFF1EEE1),
    ink2: Color(0xFFA7B099),
    ink3: Color(0xFF717A66),
    line: Color(0xFF29301F),
    track: Color(0xFF272F1E),
    acc: Color(0xFFC7E05F),
    accInk: Color(0xFF1A2010),
    terra: Color(0xFFE3955F),
    sage: Color(0xFF93C170),
    hero: Color(0xFFECE7D9),
    heroInk: Color(0xFF1B2418),
    heroInk2: Color(0xFF5C6457),
    heroLeaf: Color(0xFF1B2418),
    heroCta: Color(0xFF1B2D22),
    heroCtaInk: Color(0xFFC7E05F),
    btn: Color(0xFFC7E05F),
    btnInk: Color(0xFF1A2010),
  );

  @override
  BotanicaColors copyWith({
    Color? bg, Color? surf, Color? surf2, Color? ink, Color? ink2, Color? ink3,
    Color? line, Color? track, Color? acc, Color? accInk, Color? terra,
    Color? sage, Color? hero, Color? heroInk, Color? heroInk2, Color? heroLeaf,
    Color? heroCta, Color? heroCtaInk, Color? btn, Color? btnInk,
  }) {
    return BotanicaColors(
      bg: bg ?? this.bg,
      surf: surf ?? this.surf,
      surf2: surf2 ?? this.surf2,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      line: line ?? this.line,
      track: track ?? this.track,
      acc: acc ?? this.acc,
      accInk: accInk ?? this.accInk,
      terra: terra ?? this.terra,
      sage: sage ?? this.sage,
      hero: hero ?? this.hero,
      heroInk: heroInk ?? this.heroInk,
      heroInk2: heroInk2 ?? this.heroInk2,
      heroLeaf: heroLeaf ?? this.heroLeaf,
      heroCta: heroCta ?? this.heroCta,
      heroCtaInk: heroCtaInk ?? this.heroCtaInk,
      btn: btn ?? this.btn,
      btnInk: btnInk ?? this.btnInk,
    );
  }

  @override
  BotanicaColors lerp(ThemeExtension<BotanicaColors>? other, double t) {
    if (other is! BotanicaColors) return this;
    return BotanicaColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surf: Color.lerp(surf, other.surf, t)!,
      surf2: Color.lerp(surf2, other.surf2, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      line: Color.lerp(line, other.line, t)!,
      track: Color.lerp(track, other.track, t)!,
      acc: Color.lerp(acc, other.acc, t)!,
      accInk: Color.lerp(accInk, other.accInk, t)!,
      terra: Color.lerp(terra, other.terra, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      hero: Color.lerp(hero, other.hero, t)!,
      heroInk: Color.lerp(heroInk, other.heroInk, t)!,
      heroInk2: Color.lerp(heroInk2, other.heroInk2, t)!,
      heroLeaf: Color.lerp(heroLeaf, other.heroLeaf, t)!,
      heroCta: Color.lerp(heroCta, other.heroCta, t)!,
      heroCtaInk: Color.lerp(heroCtaInk, other.heroCtaInk, t)!,
      btn: Color.lerp(btn, other.btn, t)!,
      btnInk: Color.lerp(btnInk, other.btnInk, t)!,
    );
  }
}

/// Builds the [ThemeData] for a given Botanica palette.
class BotanicaTheme {
  static ThemeData _build(Brightness brightness, BotanicaColors c) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: c.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.acc,
        brightness: brightness,
        surface: c.bg,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: c.ink,
        displayColor: c.ink,
      ),
      extensions: [c],
    );
  }

  static ThemeData get light => _build(Brightness.light, BotanicaColors.light);
  static ThemeData get dark => _build(Brightness.dark, BotanicaColors.dark);
}

/// Fraunces — the editorial serif used for all display type.
class Serif {
  static TextStyle style(
    double size,
    Color color, {
    bool italic = false,
    FontWeight weight = FontWeight.w400,
    double height = 1.05,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

/// Terse access to the palette: `context.c.ink`, `context.c.acc`, ...
extension BotanicaContext on BuildContext {
  BotanicaColors get c => Theme.of(this).extension<BotanicaColors>()!;
}
