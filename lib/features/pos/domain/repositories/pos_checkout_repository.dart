import '../entities/parked_cart.dart';
import '../entities/pos_cart.dart';

/// Persistence boundary for local-first cart recovery and held orders.
abstract class PosCheckoutRepository {
  Future<void> saveActiveCart(PosCart cart);
  Future<PosCart?> getActiveCart();
  Future<void> clearActiveCart();
  Future<void> parkCart(ParkedCart parkedCart);
  Future<List<ParkedCart>> getParkedCarts();
  Future<void> removeParkedCart(String parkedCartId);
}
