import 'package:equatable/equatable.dart';

/// POS monetary values are stored in the smallest currency unit (for example,
/// cents) so checkout arithmetic never relies on floating point values.
enum PosDiscountType { percentage, fixed }

class PosDiscount extends Equatable {
  const PosDiscount({
    required this.type,
    required this.value,
    this.reason,
  }) : assert(value >= 0),
       assert(type != PosDiscountType.percentage || value <= 100);

  final PosDiscountType type;
  final int value;
  final String? reason;

  int discountFor(int amount) {
    if (amount <= 0) return 0;
    return switch (type) {
      PosDiscountType.percentage => (amount * value / 100).round(),
      PosDiscountType.fixed => value.clamp(0, amount),
    };
  }

  @override
  List<Object?> get props => [type, value, reason];
}

class PosProduct extends Equatable {
  const PosProduct({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.availableQuantity,
    this.barcode,
    this.categoryId,
    this.imageUrl,
  }) : assert(unitPrice >= 0),
       assert(availableQuantity >= 0);

  final String id;
  final String name;
  final int unitPrice;
  final int availableQuantity;
  final String? barcode;
  final String? categoryId;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    unitPrice,
    availableQuantity,
    barcode,
    categoryId,
    imageUrl,
  ];
}

class PosCartLine extends Equatable {
  const PosCartLine({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.availableQuantity,
    required this.unitPrice,
    this.overriddenUnitPrice,
    this.discount,
    this.barcode,
  }) : assert(quantity > 0),
       assert(availableQuantity >= 0),
       assert(unitPrice >= 0),
       assert(overriddenUnitPrice == null || overriddenUnitPrice >= 0);

  factory PosCartLine.fromProduct(PosProduct product, {int quantity = 1}) =>
      PosCartLine(
        productId: product.id,
        name: product.name,
        quantity: quantity,
        availableQuantity: product.availableQuantity,
        unitPrice: product.unitPrice,
        barcode: product.barcode,
      );

  final String productId;
  final String name;
  final int quantity;
  final int availableQuantity;
  final int unitPrice;
  final int? overriddenUnitPrice;
  final PosDiscount? discount;
  final String? barcode;

  int get effectiveUnitPrice => overriddenUnitPrice ?? unitPrice;
  int get subtotal => effectiveUnitPrice * quantity;
  int get discountAmount => discount?.discountFor(subtotal) ?? 0;
  int get total => subtotal - discountAmount;

  PosCartLine copyWith({
    int? quantity,
    int? overriddenUnitPrice,
    PosDiscount? discount,
    bool clearOverriddenUnitPrice = false,
    bool clearDiscount = false,
  }) => PosCartLine(
    productId: productId,
    name: name,
    quantity: quantity ?? this.quantity,
    availableQuantity: availableQuantity,
    unitPrice: unitPrice,
    overriddenUnitPrice: clearOverriddenUnitPrice
        ? null
        : overriddenUnitPrice ?? this.overriddenUnitPrice,
    discount: clearDiscount ? null : discount ?? this.discount,
    barcode: barcode,
  );

  @override
  List<Object?> get props => [
    productId,
    name,
    quantity,
    availableQuantity,
    unitPrice,
    overriddenUnitPrice,
    discount,
    barcode,
  ];
}

enum PosTenderType { cash, mobileMoney, card, digitalWallet }

class PosTender extends Equatable {
  const PosTender({
    required this.id,
    required this.type,
    required this.amount,
    this.reference,
  }) : assert(amount > 0);

  final String id;
  final PosTenderType type;
  final int amount;
  final String? reference;

  @override
  List<Object?> get props => [id, type, amount, reference];
}

class PosCart extends Equatable {
  const PosCart({
    required this.id,
    this.lines = const [],
    this.globalDiscount,
    this.tenders = const [],
    this.customerId,
    this.note,
    this.createdAt,
  });

  final String id;
  final List<PosCartLine> lines;
  final PosDiscount? globalDiscount;
  final List<PosTender> tenders;
  final String? customerId;
  final String? note;
  final DateTime? createdAt;

  bool get isEmpty => lines.isEmpty;
  int get subtotal => lines.fold(0, (sum, line) => sum + line.subtotal);
  int get lineDiscountAmount =>
      lines.fold(0, (sum, line) => sum + line.discountAmount);
  int get totalBeforeGlobalDiscount => subtotal - lineDiscountAmount;
  int get globalDiscountAmount =>
      globalDiscount?.discountFor(totalBeforeGlobalDiscount) ?? 0;
  int get total => totalBeforeGlobalDiscount - globalDiscountAmount;
  int get tenderedAmount =>
      tenders.fold(0, (sum, tender) => sum + tender.amount);
  int get outstandingAmount => (total - tenderedAmount).clamp(0, total);
  int get changeAmount => (tenderedAmount - total).clamp(0, tenderedAmount);
  bool get isPaid => !isEmpty && outstandingAmount == 0;

  PosCart copyWith({
    List<PosCartLine>? lines,
    PosDiscount? globalDiscount,
    List<PosTender>? tenders,
    String? customerId,
    String? note,
    bool clearGlobalDiscount = false,
  }) => PosCart(
    id: id,
    lines: lines ?? this.lines,
    globalDiscount: clearGlobalDiscount
        ? null
        : globalDiscount ?? this.globalDiscount,
    tenders: tenders ?? this.tenders,
    customerId: customerId ?? this.customerId,
    note: note ?? this.note,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    lines,
    globalDiscount,
    tenders,
    customerId,
    note,
    createdAt,
  ];
}
