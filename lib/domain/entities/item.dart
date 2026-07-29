/// A sellable product from the company catalogue (`items_list`).
class Item {
  final int id;
  final String itemName;
  /// `finished_good` or `trade_item`.
  final String itemType;
  final double salePrice;
  final double purchasePrice;
  final double taxPercent;
  final double openingStockQty;
  final String barcodeNo;
  final bool isRefill;
  final bool isEmpty;

  const Item({
    required this.id,
    required this.itemName,
    this.itemType = '',
    this.salePrice = 0,
    this.purchasePrice = 0,
    this.taxPercent = 0,
    this.openingStockQty = 0,
    this.barcodeNo = '',
    this.isRefill = false,
    this.isEmpty = false,
  });

  String get itemTypeLabel {
    switch (itemType) {
      case 'finished_good':
        return 'Finished good';
      case 'trade_item':
        return 'Trade item';
      default:
        return itemType;
    }
  }
}

/// One page of an `items_list` response.
class ItemPage {
  final int page;
  final int perPage;
  final int total;
  final List<Item> items;

  const ItemPage({
    this.page = 1,
    this.perPage = 100,
    this.total = 0,
    this.items = const [],
  });

  bool get hasMore => page * perPage < total;
}
