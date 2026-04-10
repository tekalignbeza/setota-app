import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Setota';
  static const String appTagline = 'Send Beautiful Flowers & Gifts';
  static const String appVersion = '1.0.0';

  // API Base URL
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://setota-emaagsasfbd6d4ec.uaenorth-01.azurewebsites.net/api/v1';

  // WebSocket URL
  static String get wsUrl =>
      dotenv.env['WS_URL'] ??
      'wss://setota-emaagsasfbd6d4ec.uaenorth-01.azurewebsites.net/api/v1/ws/customer/websocket';

  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  static bool get isProduction => environment == 'production';

  // ── API Endpoints ──────────────────────────────────────────────

  // Auth
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String validateTokenEndpoint = '/auth/validate';

  // Products
  static const String productsEndpoint = '/products';
  static String productByIdEndpoint(String id) => '/products/$id';
  static String productsByCategoryEndpoint(String category) =>
      '/products/category/$category';
  static const String productsSearchEndpoint = '/products/search';
  static const String productsTrendingEndpoint = '/products/trending';
  static const String productsNewArrivalsEndpoint = '/products/new-arrivals';

  // Orders
  static const String ordersEndpoint = '/orders';
  static String orderByIdEndpoint(String id) => '/orders/$id';
  static String ordersByCustomerEndpoint(String customerId) =>
      '/orders/customer/$customerId';

  // Checkout & Payment
  static const String checkoutPayEndpoint = '/checkout/pay';
  static const String checkoutMethodsEndpoint = '/checkout/methods';
  static String checkoutVerifyEndpoint(String method) =>
      '/checkout/verify/$method';
  static const String checkoutCallbackEndpoint = '/checkout/callback/';

  // Customer
  static String customerByIdEndpoint(String id) => '/customers/$id';
  static String customerAddressesEndpoint(String id) =>
      '/customers/$id/addresses';
  static String customerFavoritesEndpoint(String id) =>
      '/customers/$id/favorites';

  // Reviews
  static const String reviewsEndpoint = '/reviews';

  // Cart
  static const String cartEndpoint = '/cart';

  // Notifications
  static const String notificationsEndpoint = '/notifications';

  // Vendors
  static const String vendorsEndpoint = '/vendors';
  static String vendorByIdEndpoint(String id) => '/vendors/$id';

  // Categories
  static const String categoriesEndpoint = '/categories';

  // ── Storage Keys ───────────────────────────────────────────────

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String customerIdKey = 'customer_id';
  static const String localeKey = 'locale';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String fcmTokenKey = 'fcm_token';
  static const String deviceIdKey = 'device_id';
  static const String themeKey = 'theme_mode';
  static const String recentSearchesKey = 'recent_searches';

  // ── Customer-Specific Constants ────────────────────────────────

  static const double minimumOrderAmount = 200.0;
  static const String currency = 'ETB';
  static const String currencySymbol = 'Br';
  static const double defaultDeliveryFee = 100.0;
  static const double freeDeliveryThreshold = 1000.0;

  // ── Occasion Types ─────────────────────────────────────────────

  static const Map<String, String> occasionTypes = {
    'birthday': '🎂',
    'wedding': '💒',
    'anniversary': '💍',
    'valentines': '❤️',
    'mothers_day': '👩',
    'graduation': '🎓',
    'get_well': '🏥',
    'sympathy': '🕊️',
    'congratulations': '🎉',
    'thank_you': '🙏',
    'just_because': '🌸',
    'new_baby': '👶',
    'housewarming': '🏠',
    'holiday': '🎄',
  };

  // ── Pagination ─────────────────────────────────────────────────

  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ── Timeouts ───────────────────────────────────────────────────

  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  static const int tokenRefreshBufferSeconds = 60;
  static const int splashDurationMillis = 2000;
}
