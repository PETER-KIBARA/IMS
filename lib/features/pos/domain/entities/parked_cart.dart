import 'package:equatable/equatable.dart';

import 'pos_cart.dart';

class ParkedCart extends Equatable {
  const ParkedCart({
    required this.id,
    required this.cart,
    required this.parkedAt,
    required this.parkedByUserId,
    this.label,
  });

  final String id;
  final PosCart cart;
  final DateTime parkedAt;
  final String parkedByUserId;
  final String? label;

  @override
  List<Object?> get props => [id, cart, parkedAt, parkedByUserId, label];
}
