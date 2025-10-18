import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/shopping_cart.dart';
import 'package:flutter_testing_lab/models/cart_model.dart';

void main() {
  group('Shopping Cart - Unit Tests', () {
    late CartModel cartModel;

    setUp(() {
      cartModel = CartModel();
    });

    group('Add Item Tests', () {
      test('Should add new item to empty cart', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        expect(cartModel.items.length, 1);
        expect(cartModel.items[0].id, '1');
        expect(cartModel.items[0].name, 'Test Item');
        expect(cartModel.items[0].price, 10.0);
        expect(cartModel.items[0].quantity, 1);
      });

      test('Should increment quantity when adding duplicate item', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        cartModel.addItem('1', 'Test Item', 10.0);
        
        expect(cartModel.items.length, 1);
        expect(cartModel.items[0].quantity, 2);
      });

      test('Should add different items separately', () {
        cartModel.addItem('1', 'Item 1', 10.0);
        cartModel.addItem('2', 'Item 2', 20.0);
        
        expect(cartModel.items.length, 2);
        expect(cartModel.items[0].id, '1');
        expect(cartModel.items[1].id, '2');
      });

      test('Should not exceed max quantity when adding duplicate', () {
        // Add item up to max quantity
        for (int i = 0; i < 99; i++) {
          cartModel.addItem('1', 'Test Item', 10.0);
        }
        
        expect(cartModel.items[0].quantity, 99);
        
        // Try to add one more
        cartModel.addItem('1', 'Test Item', 10.0);
        
        // Should still be at max
        expect(cartModel.items[0].quantity, 99);
      });

      test('Should add item with discount', () {
        cartModel.addItem('1', 'Discounted Item', 100.0, discount: 0.1);
        
        expect(cartModel.items[0].discount, 0.1);
      });
    });

    group('Remove Item Tests', () {
      test('Should remove item from cart', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        cartModel.addItem('2', 'Test Item 2', 20.0);
        
        cartModel.removeItem('1');
        
        expect(cartModel.items.length, 1);
        expect(cartModel.items[0].id, '2');
      });

      test('Should handle removing non-existent item', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        cartModel.removeItem('999');
        
        expect(cartModel.items.length, 1);
      });
    });

    group('Update Quantity Tests', () {
      test('Should update item quantity', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        cartModel.updateQuantity('1', 5);
        
        expect(cartModel.items[0].quantity, 5);
      });

      test('Should remove item when quantity set to 0', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        cartModel.updateQuantity('1', 0);
        
        expect(cartModel.items.length, 0);
      });

      test('Should remove item when quantity set to negative', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        cartModel.updateQuantity('1', -5);
        
        expect(cartModel.items.length, 0);
      });

      test('Should cap quantity at max when updating', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        cartModel.updateQuantity('1', 150);
        
        expect(cartModel.items[0].quantity, 99);
      });

      test('Should handle updating non-existent item', () {
        cartModel.addItem('1', 'Test Item', 10.0);
        
        cartModel.updateQuantity('999', 5);
        
        expect(cartModel.items.length, 1);
        expect(cartModel.items[0].quantity, 1);
      });
    });

    group('Clear Cart Tests', () {
      test('Should clear all items from cart', () {
        cartModel.addItem('1', 'Test Item 1', 10.0);
        cartModel.addItem('2', 'Test Item 2', 20.0);
        
        cartModel.clearCart();
        
        expect(cartModel.items.length, 0);
      });

      test('Should handle clearing empty cart', () {
        cartModel.clearCart();
        
        expect(cartModel.items.length, 0);
      });
    });

    group('Calculation Tests', () {
      test('Should calculate correct subtotal', () {
        cartModel.addItem('1', 'Item 1', 10.0);
        cartModel.addItem('2', 'Item 2', 20.0);
        cartModel.updateQuantity('1', 2); // 2 * 10 = 20
        
        expect(cartModel.subtotal, 40.0); // 20 + 20
      });

      test('Should return 0 for empty cart subtotal', () {
        expect(cartModel.subtotal, 0.0);
      });

      test('Should calculate correct discount', () {
        // Item: price 100, discount 10%, quantity 2
        cartModel.addItem('1', 'Item 1', 100.0, discount: 0.1);
        cartModel.updateQuantity('1', 2);
        
        // Discount = 0.1 * 100 * 2 = 20
        expect(cartModel.totalDiscount, 20.0);
      });

      test('Should return 0 for empty cart discount', () {
        expect(cartModel.totalDiscount, 0.0);
      });

      test('Should calculate correct total amount', () {
        cartModel.addItem('1', 'Item 1', 100.0, discount: 0.1);
        cartModel.updateQuantity('1', 2);
        
        // Subtotal = 100 * 2 = 200
        // Discount = 0.1 * 100 * 2 = 20
        // Total = 200 - 20 = 180
        expect(cartModel.totalAmount, 180.0);
      });

      test('Should handle 100% discount (total should not be negative)', () {
        cartModel.addItem('1', 'Free Item', 100.0, discount: 1.0);
        
        // Total should be 0, not negative
        expect(cartModel.totalAmount, 0.0);
      });

      test('Should handle discount greater than 100%', () {
        cartModel.addItem('1', 'Item', 100.0, discount: 1.5);
        
        // Total should be 0, not negative
        expect(cartModel.totalAmount, 0.0);
      });

      test('Should calculate correct total items count', () {
        cartModel.addItem('1', 'Item 1', 10.0);
        cartModel.addItem('2', 'Item 2', 20.0);
        cartModel.updateQuantity('1', 3);
        cartModel.updateQuantity('2', 2);
        
        expect(cartModel.totalItems, 5); // 3 + 2
      });

      test('Should return 0 for empty cart total items', () {
        expect(cartModel.totalItems, 0);
      });

      test('Should calculate complex cart correctly', () {
        // iPhone: $999.99, 10% discount, qty 2
        cartModel.addItem('1', 'iPhone', 999.99, discount: 0.1);
        cartModel.updateQuantity('1', 2);
        
        // Galaxy: $899.99, 15% discount, qty 1
        cartModel.addItem('2', 'Galaxy', 899.99, discount: 0.15);
        
        // iPad: $1099.99, no discount, qty 1
        cartModel.addItem('3', 'iPad', 1099.99);
        
        // Subtotal = (999.99 * 2) + 899.99 + 1099.99 = 3999.96
        expect(cartModel.subtotal, closeTo(3999.96, 0.01));
        
        // Discount = (999.99 * 0.1 * 2) + (899.99 * 0.15) + 0 = 199.998 + 134.9985 = 334.9965
        expect(cartModel.totalDiscount, closeTo(334.9965, 0.01));
        
        // Total = 3999.96 - 334.9965 = 3664.9635
        expect(cartModel.totalAmount, closeTo(3664.9635, 0.01));
      });
    });
  });

  group('Shopping Cart - Widget Tests', () {
    testWidgets('Should display empty cart message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Should display cart items after adding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add an item
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      expect(find.text('Cart is empty'), findsNothing);
      expect(find.text('Apple iPhone'), findsOneWidget);
    });

    testWidgets('Should update quantity when adding duplicate item', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add iPhone
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      // Add iPhone again
      await tester.tap(find.text('Add iPhone Again'));
      await tester.pumpAndSettle();

      // Should show quantity 2, not two separate items
      expect(find.text('Apple iPhone'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Quantity display
    });

    testWidgets('Should clear cart when Clear Cart button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add items
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      // Clear cart
      await tester.tap(find.text('Clear Cart'));
      await tester.pumpAndSettle();

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Should display correct totals', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add iPhone with 10% discount
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      // Check that summary fields exist
      expect(find.textContaining('Subtotal:'), findsOneWidget);
      expect(find.textContaining('Total Discount:'), findsOneWidget);
      expect(find.textContaining('Total Amount:'), findsOneWidget);
      
      // Check that total is less than subtotal (discount applied)
      expect(find.textContaining('\$999.99'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should increment and decrement quantity', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add item
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      // Find the + button and tap it
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      // Find the - button and tap it
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Should remove item when quantity becomes 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add item
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      // Decrement to 0
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('Cart is empty'), findsOneWidget);
    });

    testWidgets('Should delete item when delete button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShoppingCart(),
          ),
        ),
      );

      // Add items
      await tester.tap(find.text('Add iPhone'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Galaxy'));
      await tester.pumpAndSettle();

      // Delete iPhone
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      expect(find.text('Apple iPhone'), findsNothing);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
    });
  });
}

