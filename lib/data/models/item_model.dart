import '../../domain/entities/item.dart';

bool _yesNo(dynamic v) {
  final s = v?.toString().trim().toLowerCase();
  return s == 'yes' || s == '1' || s == 'true';
}

double _dbl(dynamic v) =>
    v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

int _int(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.itemName,
    super.itemType,
    super.salePrice,
    super.purchasePrice,
    super.taxPercent,
    super.openingStockQty,
    super.barcodeNo,
    super.isRefill,
    super.isEmpty,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: _int(json['id']),
      itemName: json['item_name']?.toString() ?? '',
      itemType: json['item_type']?.toString() ?? '',
      salePrice: _dbl(json['sale_price']),
      purchasePrice: _dbl(json['purchase_price']),
      taxPercent: _dbl(json['tax_percent']),
      openingStockQty: _dbl(json['opening_stock_qty']),
      barcodeNo: json['barcode_no']?.toString() ?? '',
      isRefill: _yesNo(json['is_refill']),
      isEmpty: _yesNo(json['is_empty']),
    );
  }
}

class ItemPageModel extends ItemPage {
  const ItemPageModel({
    super.page,
    super.perPage,
    super.total,
    super.items,
  });

  factory ItemPageModel.fromJson(Map<String, dynamic> json) {
    int intOr(dynamic v, int fallback) =>
        v is int ? v : int.tryParse('$v') ?? fallback;

    final rows = json['items'] as List<dynamic>? ?? [];
    return ItemPageModel(
      page: intOr(json['page'], 1),
      perPage: intOr(json['per_page'], 100),
      total: intOr(json['total'], rows.length),
      items: rows
          .whereType<Map<String, dynamic>>()
          .map((e) => ItemModel.fromJson(e))
          .toList(),
    );
  }
}
