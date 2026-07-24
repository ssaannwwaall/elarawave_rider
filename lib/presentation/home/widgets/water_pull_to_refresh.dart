import 'package:flutter/material.dart';
import '../../widgets/water/water_drop_loader.dart';

/// Pull-to-refresh with [WaterDropLoader] standing in for the platform's
/// default spinner. Requires the wrapped scrollable to use
/// [BouncingScrollPhysics] (see HomeScreen) so both Android and iOS report
/// real negative overscroll pixels — Android's default ClampingScrollPhysics
/// clamps at 0 and only fires [OverscrollNotification], which doesn't carry
/// a usable drag distance.
class WaterPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const WaterPullToRefresh({super.key, required this.child, required this.onRefresh});

  @override
  State<WaterPullToRefresh> createState() => _WaterPullToRefreshState();
}

class _WaterPullToRefreshState extends State<WaterPullToRefresh> {
  static const double _triggerDistance = 80;

  double _dragExtent = 0;
  bool _refreshing = false;

  bool _handleNotification(ScrollNotification notification) {
    final pixels = notification.metrics.pixels;
    if (!_refreshing && pixels < 0) {
      setState(() => _dragExtent = (-pixels).clamp(0, _triggerDistance * 1.6));
    }
    if (notification is ScrollEndNotification) {
      if (!_refreshing && _dragExtent >= _triggerDistance) {
        _startRefresh();
      } else if (!_refreshing && _dragExtent > 0) {
        setState(() => _dragExtent = 0);
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    setState(() => _refreshing = true);
    await widget.onRefresh();
    if (mounted) setState(() => _refreshing = false);
    if (mounted) setState(() => _dragExtent = 0);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _dragExtent > 8 || _refreshing;
    final travel = _refreshing ? _triggerDistance : _dragExtent;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleNotification,
          child: widget.child,
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: EdgeInsets.only(top: (travel - 32).clamp(8, 200).toDouble()),
              child: const Center(child: WaterDropLoader(size: 36)),
            ),
          ),
        ),
      ],
    );
  }
}
