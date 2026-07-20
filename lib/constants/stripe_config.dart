/// Stripe keys for TURAME (client-side PaymentIntent creation).
///
/// WARNING: The secret key must not ship in production builds.
/// Anyone can extract it from the app binary. Prefer a backend later.
class StripeConfig {
  static const String publishableKey =
      'pk_test_51Rpsj4ECjmB30ahPB5RJaElbHYJqKoaVqyMx9ixB5Rsx1lvURfRHXwtxSsPlkK7V9G4fkn9HwB0imm29sBhSEJUy00PB3T7jxn';

  static const String secretKey =
      'sk_test_51Rpsj4ECjmB30ahP4cnjaXQE1IhLTqbmKGAy9z6PWqa1QVPYJ1GznGHQg77MxHR8gYShfNq5K1IIJI69MmPzsVdT008SAxVnPG';

  static const String merchantDisplayName = 'TURAME';

  /// RWF is a zero-decimal currency in Stripe.
  static const String defaultCurrency = 'rwf';

  static bool get isConfigured =>
      publishableKey.startsWith('pk_') && secretKey.startsWith('sk_');
}
