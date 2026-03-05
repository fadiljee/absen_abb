import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SPLASH SCREEN — "IGNITION" THEME
//  Urutan animasi:
//   0ms   → background gelap muncul
//   200ms → ring terluar mulai expand (skala + fade)
//   400ms → ring tengah mulai expand
//   600ms → ring dalam mulai
//   800ms → logo scale-in dengan elastic bounce
//  1200ms → teks nama app slide up + fade
//  1600ms → tagline fade in
//  2000ms → loading bar mulai isi dari kiri ke kanan
//  3400ms → navigate ke HomeScreen dengan slide-up transition
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // --- Controllers ---
  late AnimationController _bgCtrl;       // background gradient reveal
  late AnimationController _ringsCtrl;    // 3 expanding rings
  late AnimationController _logoCtrl;     // logo bounce-in
  late AnimationController _textCtrl;     // nama + tagline
  late AnimationController _barCtrl;      // loading progress bar
  late AnimationController _pulseCtrl;    // logo glow pulse (loop)
  late AnimationController _particleCtrl; // floating particles (loop)

  // --- Animations ---
  late Animation<double> _bgFade;

  late Animation<double> _ring1Scale, _ring1Fade;
  late Animation<double> _ring2Scale, _ring2Fade;
  late Animation<double> _ring3Scale, _ring3Fade;

  late Animation<double> _logoScale, _logoFade, _logoRotate;

  late Animation<double> _nameSlide, _nameFade;
  late Animation<double> _tagFade;

  late Animation<double> _barProgress;

  late Animation<double> _pulseScale;
  late Animation<double> _particleAngle;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Background ──────────────────────────────────────────────
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeIn);

    // ── Rings ────────────────────────────────────────────────────
    _ringsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _ring1Scale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ringsCtrl, curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic)));
    _ring1Fade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ringsCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _ring2Scale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ringsCtrl, curve: const Interval(0.15, 0.75, curve: Curves.easeOutCubic)));
    _ring2Fade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ringsCtrl, curve: const Interval(0.15, 0.5, curve: Curves.easeOut)));

    _ring3Scale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ringsCtrl, curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)));
    _ring3Fade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ringsCtrl, curve: const Interval(0.3, 0.65, curve: Curves.easeOut)));

    // ── Logo ──────────────────────────────────────────────────────
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _logoScale  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _logoRotate = Tween<double>(begin: -0.08, end: 0.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    // ── Text ──────────────────────────────────────────────────────
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _nameSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _nameFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _tagFade   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    // ── Loading Bar ───────────────────────────────────────────────
    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _barProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut));

    // ── Pulse (loop) ──────────────────────────────────────────────
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // ── Particles (loop) ─────────────────────────────────────────
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _particleAngle = Tween<double>(begin: 0, end: 2 * math.pi).animate(_particleCtrl);

    // ── Sequence ──────────────────────────────────────────────────
    _bgCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200),  () { if (mounted) _ringsCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 700),  () { if (mounted) _logoCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 1200), () { if (mounted) _textCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) _barCtrl.forward(); });

    // ── Navigate ─────────────────────────────────────────────────
    Future.delayed(const Duration(milliseconds: 3400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 900),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: anim, child: child),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _ringsCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _barCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgFade, _ringsCtrl, _logoCtrl, _textCtrl, _barProgress,
          _pulseScale, _particleAngle,
        ]),
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Background gradient ──────────────────────────
              _buildBackground(),

              // ── 2. Floating particles ───────────────────────────
              _buildParticles(size),

              // ── 3. Decorative corner lines ──────────────────────
              _buildCornerAccents(size),

              // ── 4. Ring burst ───────────────────────────────────
              Center(child: _buildRings()),

              // ── 5. Logo + glow ──────────────────────────────────
              Center(child: _buildLogo()),

              // ── 6. Text block (nama + tagline) ──────────────────
              _buildTextBlock(size),

              // ── 7. Bottom: loading bar + version ────────────────
              _buildBottomSection(size),
            ],
          );
        },
      ),
    );
  }

  // ─── BACKGROUND ──────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return FadeTransition(
      opacity: _bgFade,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.25),
            radius: 1.2,
            colors: [
              const Color(0xFF3D0000).withOpacity(0.9),
              const Color(0xFF1A0000).withOpacity(0.7),
              const Color(0xFF0A0A0A),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  // ─── PARTICLES ────────────────────────────────────────────────────────────
  Widget _buildParticles(Size size) {
    return CustomPaint(
      painter: _ParticlePainter(
        angle: _particleAngle.value,
        opacity: _bgFade.value,
      ),
      size: size,
    );
  }

  // ─── CORNER ACCENTS ───────────────────────────────────────────────────────
  Widget _buildCornerAccents(Size size) {
    return Opacity(
      opacity: (_bgFade.value * 0.35).clamp(0, 1),
      child: CustomPaint(
        painter: _CornerAccentPainter(),
        size: size,
      ),
    );
  }

  // ─── RINGS ────────────────────────────────────────────────────────────────
  Widget _buildRings() {
    return SizedBox(
      width: 280, height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRing(_ring3Scale.value, _ring3Fade.value, 280, 1.5, const Color(0xFFB71C1C), 0.10),
          _buildRing(_ring2Scale.value, _ring2Fade.value, 220, 1.0, const Color(0xFFEF5350), 0.15),
          _buildRing(_ring1Scale.value, _ring1Fade.value, 165, 1.5, const Color(0xFFEF9A9A), 0.22),
        ],
      ),
    );
  }

  Widget _buildRing(double scale, double fade, double size, double stroke, Color color, double alpha) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: (fade * alpha * 3.5).clamp(0, 1),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(alpha * 3), width: stroke),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 20, spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── LOGO ─────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Transform.scale(
      scale: _logoScale.value * _pulseScale.value,
      child: Transform.rotate(
        angle: _logoRotate.value,
        child: Opacity(
          opacity: _logoFade.value.clamp(0, 1),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB71C1C).withOpacity(0.55 * _logoFade.value),
                      blurRadius: 55, spreadRadius: 12,
                    ),
                    BoxShadow(
                      color: const Color(0xFFEF5350).withOpacity(0.25 * _logoFade.value),
                      blurRadius: 90, spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              // Logo container with gradient border
              Container(
                width: 118, height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D0000), Color(0xFF1A0000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFFB71C1C).withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TEXT BLOCK ───────────────────────────────────────────────────────────
  Widget _buildTextBlock(Size size) {
    return Positioned(
      top: size.height * 0.62,
      left: 0, right: 0,
      child: Column(
        children: [
          // App name
          Transform.translate(
            offset: Offset(0, _nameSlide.value),
            child: Opacity(
              opacity: _nameFade.value.clamp(0, 1),
              child: const Text(
                "ABSENSI",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF5F5F5),
                  letterSpacing: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Decorative line between name and tagline
          Transform.translate(
            offset: Offset(0, _nameSlide.value * 0.5),
            child: Opacity(
              opacity: _nameFade.value.clamp(0, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _gradientLine(80),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 5, height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  _gradientLine(80),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tagline
          Opacity(
            opacity: _tagFade.value.clamp(0, 1),
            child: const Text(
              "Manajemen Kehadiran Pegawai",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9E9E),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientLine(double width) {
    return Container(
      width: width, height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFB71C1C).withOpacity(0.6),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM SECTION ───────────────────────────────────────────────────────
  Widget _buildBottomSection(Size size) {
    return Positioned(
      bottom: 48,
      left: 40, right: 40,
      child: Column(
        children: [
          // Progress bar container
          Opacity(
            opacity: (_barProgress.value * 4).clamp(0, 1),
            child: Column(
              children: [
                // Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Memuat...",
                      style: TextStyle(fontSize: 10, color: Color(0xFF616161), letterSpacing: 1)),
                    Text("${(_barProgress.value * 100).toInt()}%",
                      style: const TextStyle(fontSize: 10, color: Color(0xFFB71C1C),
                          letterSpacing: 1, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                // Bar track
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LayoutBuilder(
                    builder: (_, constraints) => Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: Duration.zero,
                        width: constraints.maxWidth * _barProgress.value,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7F0000), Color(0xFFEF5350)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB71C1C).withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Version text
          Opacity(
            opacity: _tagFade.value.clamp(0, 1),
            child: const Text(
              "v1.0.0",
              style: TextStyle(fontSize: 10, color: Color(0xFF424242), letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM PAINTER — FLOATING PARTICLES
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double angle;
  final double opacity;

  _ParticlePainter({required this.angle, required this.opacity});

  static final List<_ParticleData> _particles = List.generate(18, (i) {
    final rng = math.Random(i * 37 + 13);
    return _ParticleData(
      orbitRadius: 80 + rng.nextDouble() * 200,
      angleOffset: rng.nextDouble() * 2 * math.pi,
      speed: 0.4 + rng.nextDouble() * 0.8,
      size: 1.0 + rng.nextDouble() * 2.5,
      brightness: 0.2 + rng.nextDouble() * 0.5,
      yBias: (rng.nextDouble() - 0.5) * 0.4,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;

    for (final p in _particles) {
      final a = p.angleOffset + angle * p.speed;
      final x = cx + p.orbitRadius * math.cos(a);
      final y = cy + p.orbitRadius * math.sin(a) * 0.45 + p.yBias * size.height;

      final paint = Paint()
        ..color = const Color(0xFFEF5350).withOpacity(p.brightness * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.angle != angle || old.opacity != opacity;
}

class _ParticleData {
  final double orbitRadius, angleOffset, speed, size, brightness, yBias;
  const _ParticleData({
    required this.orbitRadius,
    required this.angleOffset,
    required this.speed,
    required this.size,
    required this.brightness,
    required this.yBias,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM PAINTER — CORNER ACCENTS
// ─────────────────────────────────────────────────────────────────────────────
class _CornerAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB71C1C).withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    const pad = 28.0;

    // Top-left
    canvas.drawLine(const Offset(pad, pad + len), const Offset(pad, pad), paint);
    canvas.drawLine(const Offset(pad, pad), Offset(pad + len, pad), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - pad - len, pad), Offset(size.width - pad, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad, pad + len), paint);

    // Bottom-left
    canvas.drawLine(Offset(pad, size.height - pad - len), Offset(pad, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad + len, size.height - pad), paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - pad - len, size.height - pad), Offset(size.width - pad, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad - len), Offset(size.width - pad, size.height - pad), paint);
  }

  @override
  bool shouldRepaint(_CornerAccentPainter _) => false;
}