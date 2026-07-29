import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/motion_config.dart';

/// The hero effect: a GLSL fragment shader (shaders/water_caustics.frag)
/// rendering layered, domain-warped noise as caustic light patterns —
/// meant to read as light passing through genuinely clean water, not a
/// decorative blue blob. See docs/ANIMATION.md for the performance budget.
///
/// Degrades gracefully to a static [AppColors.waterGradient] when:
///   - the shader fails to compile/load (caught, never crashes the screen)
///   - [MotionConfig.reduceMotion] is set (manual toggle or platform a11y)
///   - the widget is scrolled off-screen (ticker pauses via VisibilityDetector)
///   - the app is backgrounded (ticker checks [WidgetsBinding.lifecycleState])
class LiquidCausticsBackground extends StatefulWidget {
  final double intensity;
  final Color colorDeep;
  final Color colorLight;
  final Widget? child;

  const LiquidCausticsBackground({
    super.key,
    this.intensity = 1.0,
    this.colorDeep = AppColors.heroDeep,
    this.colorLight = AppColors.heroLight,
    this.child,
  });

  @override
  State<LiquidCausticsBackground> createState() => _LiquidCausticsBackgroundState();
}

class _LiquidCausticsBackgroundState extends State<LiquidCausticsBackground>
    with SingleTickerProviderStateMixin {
  final Key _visibilityKey = UniqueKey();
  ui.FragmentShader? _shader;
  bool _shaderFailed = false;
  bool _visible = true;
  late final Ticker _ticker;
  late final Worker _motionWorker;
  double _time = 0;

  // Cap the repaint rate to ~30fps instead of repainting the full-screen
  // caustics shader on every vsync. Painting every frame (60/90/120Hz)
  // saturates the surface's buffer queue on lower-end GPUs — the source of
  // the "BLASTBufferQueue ... Can't acquire next buffer" log spam — for no
  // perceptible benefit on slow, organic water motion.
  static const Duration _minFrameInterval = Duration(milliseconds: 33);
  Duration _lastFrame = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker(_onTick);
    _syncTicker(notify: false);
    // React live to MotionConfig — not just at creation — so toggling
    // "reduce motion" affects this widget even while it's already on screen.
    _motionWorker = ever(motion.reduceMotion, (_) => _syncTicker());
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset('shaders/water_caustics.frag');
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (_) {
      if (mounted) setState(() => _shaderFailed = true);
    }
  }

  void _syncTicker({bool notify = true}) {
    final shouldRun = _visible && motion.motionEnabled;
    if (shouldRun && !_ticker.isActive) {
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
    if (notify && mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;
    if (elapsed - _lastFrame < _minFrameInterval) return;
    _lastFrame = elapsed;
    setState(() => _time = elapsed.inMilliseconds / 1000.0);
  }

  @override
  void dispose() {
    _motionWorker.dispose();
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    final Widget background;
    if (_shaderFailed || shader == null || !motion.motionEnabled) {
      background = const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.waterGradient));
    } else {
      background = CustomPaint(
        painter: _CausticsPainter(
          shader: shader,
          time: _time,
          intensity: widget.intensity,
          colorDeep: widget.colorDeep,
          colorLight: widget.colorLight,
        ),
        child: const SizedBox.expand(),
      );
    }

    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        _visible = info.visibleFraction > 0;
        _syncTicker();
      },
      // `background` is positioned to fill whatever size the Stack resolves
      // to; `widget.child` is the *only* non-positioned child, so it's what
      // actually determines that size. This lets the same widget work both
      // in a fully bounded context (Scaffold body, fixed-height SizedBox —
      // Splash/Login) and in a content-sized context with no bounded height
      // from the parent (a Sliver — the Home header): in the latter case,
      // forcing StackFit.expand would ask for infinite height and crash.
      child: Stack(
        children: [
          Positioned.fill(child: background),
          widget.child ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _CausticsPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double intensity;
  final Color colorDeep;
  final Color colorLight;

  _CausticsPainter({
    required this.shader,
    required this.time,
    required this.intensity,
    required this.colorDeep,
    required this.colorLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, intensity)
      ..setFloat(4, colorDeep.r)
      ..setFloat(5, colorDeep.g)
      ..setFloat(6, colorDeep.b)
      ..setFloat(7, colorDeep.a)
      ..setFloat(8, colorLight.r)
      ..setFloat(9, colorLight.g)
      ..setFloat(10, colorLight.b)
      ..setFloat(11, colorLight.a);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _CausticsPainter oldDelegate) => oldDelegate.time != time;
}
