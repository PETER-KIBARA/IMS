import 'package:flutter_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = PosProduct(
    id: 'coffee',
    name: 'Coffee',
    unitPrice: 500,
    availableQuantity: 10,
  );

  test('calculates line and global discounts in the correct order', () {
    final cart = PosCart(
      id: 'cart-1',
      lines: [
        PosCartLine.fromProduct(product, quantity: 2).copyWith(
          discount: const PosDiscount(
            type: PosDiscountType.percentage,
            value: 10,
          ),
        ),
      ],
      globalDiscount: const PosDiscount(
        type: PosDiscountType.fixed,
        value: 100,
      ),
    );

    expect(cart.subtotal, 1000);
    expect(cart.lineDiscountAmount, 100);
    expect(cart.totalBeforeGlobalDiscount, 900);
    expect(cart.total, 800);
  });

  test('caps fixed discounts at the applicable amount', () {
    final cart = PosCart(
      id: 'cart-1',
      lines: [PosCartLine.fromProduct(product)],
      globalDiscount: const PosDiscount(
        type: PosDiscountType.fixed,
        value: 900,
      ),
    );

    expect(cart.total, 0);
  });

  test('calculates outstanding balance and cash change for split tender', () {
    final cart = PosCart(
      id: 'cart-1',
      lines: [PosCartLine.fromProduct(product, quantity: 2)],
      tenders: const [
        PosTender(id: 'mpesa', type: PosTenderType.mobileMoney, amount: 400),
        PosTender(id: 'cash', type: PosTenderType.cash, amount: 700),
      ],
    );

    expect(cart.outstandingAmount, 0);
    expect(cart.changeAmount, 100);
    expect(cart.isPaid, isTrue);
  });
}
