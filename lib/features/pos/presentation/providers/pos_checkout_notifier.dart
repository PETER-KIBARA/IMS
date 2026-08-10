import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parked_cart.dart';
import '../../domain/entities/pos_cart.dart';
import 'pos_checkout_state.dart';

final posCheckoutNotifierProvider =
    NotifierProvider<PosCheckoutNotifier, PosCheckoutState>(
      PosCheckoutNotifier.new,
    );

class PosCheckoutNotifier extends Notifier<PosCheckoutState> {
  @override
  PosCheckoutState build() => PosCheckoutState.initial();

  void addProduct(PosProduct product, {int quantity = 1}) {
    if (quantity <= 0) return _setError(PosCheckoutError.invalidQuantity);
    final lines = [...state.cart.lines];
    final lineIndex = lines.indexWhere((line) => line.productId == product.id);
    final nextQuantity = lineIndex == -1
        ? quantity
        : lines[lineIndex].quantity + quantity;
    if (nextQuantity > product.availableQuantity) {
      return _setError(PosCheckoutError.insufficientStock);
    }

    if (lineIndex == -1) {
      lines.add(PosCartLine.fromProduct(product, quantity: quantity));
    } else {
      lines[lineIndex] = lines[lineIndex].copyWith(quantity: nextQuantity);
    }
    _updateCart(state.cart.copyWith(lines: lines));
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeLine(productId);
    final lines = [...state.cart.lines];
    final lineIndex = lines.indexWhere((line) => line.productId == productId);
    if (lineIndex == -1) return;
    if (quantity > lines[lineIndex].availableQuantity) {
      return _setError(PosCheckoutError.insufficientStock);
    }
    lines[lineIndex] = lines[lineIndex].copyWith(quantity: quantity);
    _updateCart(state.cart.copyWith(lines: lines));
  }

  void removeLine(String productId) => _updateCart(
    state.cart.copyWith(
      lines: state.cart.lines
          .where((line) => line.productId != productId)
          .toList(),
    ),
  );

  void setLineDiscount(String productId, PosDiscount? discount) => _updateLine(
    productId,
    (line) => discount == null
        ? line.copyWith(clearDiscount: true)
        : line.copyWith(discount: discount),
  );

  void setGlobalDiscount(PosDiscount? discount) => _updateCart(
    discount == null
        ? state.cart.copyWith(clearGlobalDiscount: true)
        : state.cart.copyWith(globalDiscount: discount),
  );

  void setPriceOverride(String productId, int? unitPrice) {
    if (unitPrice != null && unitPrice < 0) return;
    _updateLine(
      productId,
      (line) => unitPrice == null
          ? line.copyWith(clearOverriddenUnitPrice: true)
          : line.copyWith(overriddenUnitPrice: unitPrice),
    );
  }

  void addTender(PosTender tender) {
    if (tender.amount > state.cart.outstandingAmount &&
        tender.type != PosTenderType.cash) {
      return _setError(PosCheckoutError.invalidTender);
    }
    _updateCart(state.cart.copyWith(tenders: [...state.cart.tenders, tender]));
  }

  void removeTender(String tenderId) => _updateCart(
    state.cart.copyWith(
      tenders: state.cart.tenders
          .where((tender) => tender.id != tenderId)
          .toList(),
    ),
  );

  void parkCurrentCart({required String userId, String? label, DateTime? now}) {
    if (state.cart.isEmpty) return;
    final parkedAt = now ?? DateTime.now();
    final parkedCart = ParkedCart(
      id: state.cart.id,
      cart: state.cart,
      parkedAt: parkedAt,
      parkedByUserId: userId,
      label: label,
    );
    state = PosCheckoutState(
      cart: PosCart(
        id: 'active-${parkedAt.microsecondsSinceEpoch}',
        createdAt: parkedAt,
      ),
      parkedCarts: [...state.parkedCarts, parkedCart],
    );
  }

  void resumeParkedCart(String parkedCartId) {
    final parkedCart = state.parkedCarts
        .where((cart) => cart.id == parkedCartId)
        .firstOrNull;
    if (parkedCart == null) return;
    state = PosCheckoutState(
      cart: parkedCart.cart,
      parkedCarts: state.parkedCarts
          .where((cart) => cart.id != parkedCartId)
          .toList(),
    );
  }

  bool canCompleteSale() {
    if (!state.cart.isPaid) {
      _setError(PosCheckoutError.cartNotPaid);
      return false;
    }
    return true;
  }

  void _updateLine(
    String productId,
    PosCartLine Function(PosCartLine line) update,
  ) {
    final lines = state.cart.lines
        .map((line) => line.productId == productId ? update(line) : line)
        .toList();
    _updateCart(state.cart.copyWith(lines: lines));
  }

  void _updateCart(PosCart cart) =>
      state = state.copyWith(cart: cart, clearError: true);
  void _setError(PosCheckoutError error) =>
      state = state.copyWith(error: error);
}
