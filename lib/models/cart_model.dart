import 'package:flutter_testing_lab/widgets/shopping_cart.dart';

/// Cart model for managing shopping cart operations
class CartModel {
  final List<CartItem> _items = [];
  static const int maxQuantity = 99;

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(String id, String name, double price, {double discount = 0.0}) {
    final existingItemIndex = _items.indexWhere((item) => item.id == id);

    if (existingItemIndex != -1) {
      // Item exists, increment quantity if not at max
      if (_items[existingItemIndex].quantity < maxQuantity) {
        _items[existingItemIndex].quantity++;
      }
    } else {
      // New item, add to cart
      _items.add(
        CartItem(id: id, name: name, price: price, discount: discount),
      );
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
  }

  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        // Cap quantity at maxQuantity
        _items[index].quantity = newQuantity.clamp(1, maxQuantity);
      }
    }
  }

  void clearCart() {
    _items.clear();
  }

  double get subtotal {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  double get totalDiscount {
    double discount = 0;
    for (var item in _items) {
      // Discount is percentage * price * quantity
      discount += item.discount * item.price * item.quantity;
    }
    return discount;
  }

  double get totalAmount {
    // Total should be subtotal minus discount
    // Ensure it doesn't go negative (handle 100% or more discount)
    final total = subtotal - totalDiscount;
    return total < 0 ? 0 : total;
  }

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
}

