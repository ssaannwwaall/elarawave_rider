import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The set of order statuses a rider can move an order through, as confirmed
/// against the live `update_order_status` endpoint.
///
/// [value] is the machine-readable key sent to / received from the API
/// (`order_status`); [label] is the human-readable text shown in the UI
/// (`order_status_label`). Kept as an enum with an explicit value map so the
/// wire format never leaks into the UI and vice versa.
enum OrderStatus {
  pending('pending', 'Pending'),
  production('production', 'Production'),
  ready('ready', 'Ready'),
  dispatch('dispatch', 'Dispatch'),
  delivered('delivered', 'Delivered'),
  returnOrder('return_order', 'Return Order');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);

  /// Ordered list for building selectors (matches the backend's flow order).
  static const List<OrderStatus> all = OrderStatus.values;

  /// The forward fulfilment sequence a normal order moves through, in order.
  /// [returnOrder] is deliberately excluded — it's a branch/terminal state,
  /// not a step on the happy path — and is surfaced separately in the UI.
  static const List<OrderStatus> flow = [
    OrderStatus.pending,
    OrderStatus.production,
    OrderStatus.ready,
    OrderStatus.dispatch,
    OrderStatus.delivered,
  ];

  /// Position of this status within [flow], or -1 if it isn't a flow step
  /// (i.e. [returnOrder]).
  int get flowIndex => flow.indexOf(this);

  bool get isInFlow => flowIndex >= 0;

  /// Resolves a wire value (e.g. "ready") to its enum, or null if unknown.
  static OrderStatus? fromValue(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().trim();
    for (final status in OrderStatus.values) {
      if (status.value == normalized) return status;
    }
    return null;
  }

  /// Human-readable label for a raw wire value, falling back to the value
  /// itself (title-cased-ish) when the key is not one we know about.
  static String labelFor(String? value) => fromValue(value)?.label ?? (value ?? '');

  /// Badge/accent color for this status. Unknown statuses fall back to a
  /// neutral grey via [colorFor].
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.amber;
      case OrderStatus.production:
        return AppColors.elaraBlue;
      case OrderStatus.ready:
        return AppColors.amber;
      case OrderStatus.dispatch:
        return AppColors.aqua;
      case OrderStatus.delivered:
        return AppColors.mineral;
      case OrderStatus.returnOrder:
        return AppColors.coral;
    }
  }

  static Color colorFor(String? value) => fromValue(value)?.color ?? AppColors.inkMuted;
}
