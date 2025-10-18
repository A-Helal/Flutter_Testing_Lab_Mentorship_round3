import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';
import 'package:flutter_testing_lab/utils/temperature_converter.dart';

void main() {
  group('Weather Display - Unit Tests', () {
    group('Temperature Conversion Tests', () {
      test('Should convert Celsius to Fahrenheit correctly', () {
        expect(TemperatureConverter.celsiusToFahrenheit(0), 32.0);
        expect(TemperatureConverter.celsiusToFahrenheit(100), 212.0);
        expect(TemperatureConverter.celsiusToFahrenheit(25), 77.0);
        expect(TemperatureConverter.celsiusToFahrenheit(-40), -40.0);
        expect(TemperatureConverter.celsiusToFahrenheit(37), 98.6);
      });

      test('Should convert Fahrenheit to Celsius correctly', () {
        expect(TemperatureConverter.fahrenheitToCelsius(32), 0.0);
        expect(TemperatureConverter.fahrenheitToCelsius(212), 100.0);
        expect(TemperatureConverter.fahrenheitToCelsius(77), 25.0);
        expect(TemperatureConverter.fahrenheitToCelsius(-40), -40.0);
        expect(TemperatureConverter.fahrenheitToCelsius(98.6), closeTo(37, 0.01));
      });

      test('Celsius to Fahrenheit and back should return original value', () {
        const testValues = [0.0, 25.0, 100.0, -40.0, 37.5];
        
        for (final celsius in testValues) {
          final fahrenheit = TemperatureConverter.celsiusToFahrenheit(celsius);
          final backToCelsius = TemperatureConverter.fahrenheitToCelsius(fahrenheit);
          expect(backToCelsius, closeTo(celsius, 0.0001));
        }
      });
    });

    group('WeatherData Parsing Tests', () {
      test('Should parse complete weather data correctly', () {
        final json = {
          'city': 'New York',
          'temperature': 25.5,
          'description': 'Sunny',
          'humidity': 65,
          'windSpeed': 12.3,
          'icon': '☀️',
        };

        final weatherData = WeatherData.fromJson(json);

        expect(weatherData.city, 'New York');
        expect(weatherData.temperatureCelsius, 25.5);
        expect(weatherData.description, 'Sunny');
        expect(weatherData.humidity, 65);
        expect(weatherData.windSpeed, 12.3);
        expect(weatherData.icon, '☀️');
      });

      test('Should handle null weather data', () {
        expect(
          () => WeatherData.fromJson(null),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Should handle missing required fields', () {
        final jsonMissingCity = {
          'temperature': 25.5,
          'description': 'Sunny',
        };

        expect(
          () => WeatherData.fromJson(jsonMissingCity),
          throwsA(isA<ArgumentError>()),
        );

        final jsonMissingTemp = {
          'city': 'New York',
          'description': 'Sunny',
        };

        expect(
          () => WeatherData.fromJson(jsonMissingTemp),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Should handle missing optional fields with defaults', () {
        final json = {
          'city': 'New York',
          'temperature': 25.5,
        };

        final weatherData = WeatherData.fromJson(json);

        expect(weatherData.city, 'New York');
        expect(weatherData.temperatureCelsius, 25.5);
        expect(weatherData.description, 'N/A');
        expect(weatherData.humidity, 0);
        expect(weatherData.windSpeed, 0.0);
        expect(weatherData.icon, '🌡️');
      });

      test('Should handle integer temperature values', () {
        final json = {
          'city': 'Tokyo',
          'temperature': 25, // Integer instead of double
        };

        final weatherData = WeatherData.fromJson(json);
        expect(weatherData.temperatureCelsius, 25.0);
      });
    });
  });

  group('Weather Display - Widget Tests', () {
    testWidgets('Should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Pump once to start the async operation
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Complete the async operation to avoid timer issues
      await tester.pumpAndSettle();
    });

    testWidgets('Should display weather data after loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should show weather data (not loading or error)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsNothing);
      
      // Should display city name (may appear in dropdown and display)
      expect(find.text('New York'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should show error for invalid city', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Select invalid city
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Invalid City').last);
      await tester.pump(); // Trigger the dropdown selection

      // Wait for loading and then error
      await tester.pump(); // Start async operation
      
      // Should show loading first
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the error state
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to fetch weather data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Should toggle between Celsius and Fahrenheit', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should display Celsius initially
      expect(find.textContaining('°C'), findsOneWidget);
      expect(find.text('Celsius'), findsOneWidget);

      // Toggle to Fahrenheit
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Should display Fahrenheit
      expect(find.textContaining('°F'), findsOneWidget);
      expect(find.text('Fahrenheit'), findsOneWidget);
      
      // Toggle back to Celsius
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Should display Celsius again
      expect(find.textContaining('°C'), findsOneWidget);
      expect(find.text('Celsius'), findsOneWidget);
    });

    testWidgets('Should refresh weather data when refresh button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for initial data
      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.text('Refresh'));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for reload
      await tester.pumpAndSettle();

      // Should show weather data again
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('New York'), findsAtLeastNWidgets(1));
    });

    testWidgets('Should display weather details', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should display humidity
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.textContaining('%'), findsOneWidget);

      // Should display wind speed
      expect(find.text('Wind Speed'), findsOneWidget);
      expect(find.textContaining('km/h'), findsOneWidget);
    });

    testWidgets('Should change city when dropdown selection changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Should show New York initially
      expect(find.text('New York'), findsAtLeastNWidgets(1));

      // Change to London
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('London').last);
      await tester.pump(); // Close dropdown
      
      // Pump to start async operation
      await tester.pump();
      
      // Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for new data
      await tester.pumpAndSettle();

      // Should show London weather (appears in dropdown and display)
      expect(find.text('London'), findsAtLeastNWidgets(1));
      expect(find.text('Rainy'), findsOneWidget);
      expect(find.text('🌧️'), findsOneWidget);
    });

    testWidgets('Should retry loading after error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherDisplay(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Select invalid city to trigger error
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Invalid City').last);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Should show error
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for retry to complete
      await tester.pumpAndSettle();

      // Should still show error (since city is still invalid)
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}

