import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final int productId;
  final String name;
  final String imageUrl;
  final int basePrice;
  final int? overriddenPrice;
  final int quantity;
  final int stock;
  final DiscountEntity? lineItemDiscount;
  final String? barcode;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.basePrice,
    this.overriddenPrice,
    required this.quantity,
    required this.stock,
    this.lineItemDiscount,
    this.barcode,
  });

  int get effectivePrice => overriddenPrice ?? basePrice;

  int get lineItemTotal {
    final subtotal = effectivePrice * quantity;
    if (lineItemDiscount == null) return subtotal;
    
    return lineItemDiscount!.applyTo(subtotal);
  }

  CartItemEntity copyWith({
    int? productId,
    String? name,
    String? imageUrl,
    int? basePrice,
    int? overriddenPrice,
    int? quantity,
    int? stock,
    DiscountEntity? lineItemDiscount,
    String? barcode,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      overriddenPrice: overriddenPrice ?? this.overriddenPrice,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      lineItemDiscount: lineItemDiscount ?? this.lineItemDiscount,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        name,
        imageUrl,
        basePrice,
        overriddenPrice,
        quantity,
        stock,
        lineItemDiscount,
        barcode,
      ];
}

enum DiscountType { percentage, fixed }

class DiscountEntity extends Equatable {
  final DiscountType type;
  final double value; // Percentage (0-100) or fixed amount
  final String? reason;

  const DiscountEntity({
    required this.type,
    required this.value,
    this.reason,
  });

  int applyTo(int amount) {
    switch (type) {
      case DiscountType.percentage:
        return (amount * (1 - value / 100)).round();
      case DiscountType.fixed:
        return (amount - value).clamp(0, amount);
    }
  }

  DiscountEntity copyWith({
    DiscountType? type,
    double? value,
    String? reason,
  }) {
    return DiscountEntity(
      type: type ?? this.type,
      value: value ?? this.value,
      reason: reason ?? this.reason,
    );
  }

  @override
  List<Object?> get props => [type, value, reason];
}
