import 'package:flutter_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:flutter_pos/features/pos/presentation/providers/pos_checkout_notifier.dart';
import 'package:flutter_pos/features/pos/presentation/providers/pos_checkout_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = PosProduct(
    id: 'p1',
    name: 'Milk',
    unitPrice: 120,
    availableQuantity: 2,
  );

  ProviderContainer createContainer() => ProviderContainer();

  test('prevents a cart line exceeding current stock', () {
    final container = createContainer();
    addTearDown(container.dispose);
    final notifier = container.read(posCheckoutNotifierProvider.notifier);

    notifier.addProduct(product, quantity: 2);
    notifier.addProduct(product);

    final state = container.read(posCheckoutNotifierProvider);
    expect(state.cart.lines.single.quantity, 2);
    expect(state.error, PosCheckoutError.insufficientStock);
  });

  test('rejects non-cash tender above the outstanding balance', () {
    final container = createContainer();
    addTearDown(container.dispose);
    final notifier = container.read(posCheckoutNotifierProvider.notifier);
    notifier.addProduct(product);

    notifier.addTender(
      const PosTender(id: 'card-1', type: PosTenderType.card, amount: 121),
    );

    final state = container.read(posCheckoutNotifierProvider);
    expect(state.cart.tenders, isEmpty);
    expect(state.error, PosCheckoutError.invalidTender);
  });
}
