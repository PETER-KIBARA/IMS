import 'package:equatable/equatable.dart';

import '../../domain/entities/parked_cart.dart';
import '../../domain/entities/pos_cart.dart';

enum PosCheckoutError {
  insufficientStock,
  invalidQuantity,
  invalidTender,
  cartNotPaid,
}

class PosCheckoutState extends Equatable {
  const PosCheckoutState({
    required this.cart,
    this.parkedCarts = const [],
    this.error,
  });

  factory PosCheckoutState.initial() =>
      const PosCheckoutState(cart: PosCart(id: 'active'));

  final PosCart cart;
  final List<ParkedCart> parkedCarts;
  final PosCheckoutError? error;

  PosCheckoutState copyWith({
    PosCart? cart,
    List<ParkedCart>? parkedCarts,
    PosCheckoutError? error,
    bool clearError = false,
  }) => PosCheckoutState(
    cart: cart ?? this.cart,
    parkedCarts: parkedCarts ?? this.parkedCarts,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [cart, parkedCarts, error];
}
