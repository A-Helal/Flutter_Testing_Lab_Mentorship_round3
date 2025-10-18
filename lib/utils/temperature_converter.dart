/// Utility class for temperature conversions
class TemperatureConverter {
  /// Convert Celsius to Fahrenheit
  /// Formula: C to F = (c * 9 / 5) + 32
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Convert Fahrenheit to Celsius
  /// Formula: F to C = (f - 32) * 5 / 9
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }
}

