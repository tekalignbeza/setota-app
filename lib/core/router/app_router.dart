import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/providers/locale_provider.dart';
import '../../presentation/screens/addresses/add_address_screen.dart';
import '../../presentation/screens/addresses/addresses_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/checkout/order_success_screen.dart';
import '../../presentation/screens/checkout/payment_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/orders/order_detail_screen.dart';
import '../../presentation/screens/orders/order_tracking_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/product/product_reviews_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/vendor/vendor_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final prefs = ref.read(sharedPreferencesProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: !AppConstants.isProduction,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnSplash = state.matchedLocation == '/';
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // Still on splash → let it resolve
      if (isOnSplash) return null;

      // Check onboarding
      final onboardingComplete =
          prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
      if (!onboardingComplete && !isOnOnboarding && !isOnSplash) {
        return '/onboarding';
      }

      // Not authenticated → redirect to login (unless already on auth)
      if (!isAuthenticated && !isOnAuth && !isOnOnboarding && !isOnSplash) {
        return '/login';
      }

      // Authenticated but on auth/splash pages → redirect to home
      if (isAuthenticated && (isOnAuth || isOnSplash)) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password/:token',
        builder: (context, state) => ResetPasswordScreen(
          token: state.pathParameters['token'] ?? '',
        ),
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Product Routes
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(
          productId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/product/:id/reviews',
        builder: (context, state) => ProductReviewsScreen(
          productId: state.pathParameters['id'] ?? '',
        ),
      ),

      // Vendor Route
      GoRoute(
        path: '/vendor/:id',
        builder: (context, state) => VendorDetailScreen(
          vendorId: state.pathParameters['id'] ?? '',
        ),
      ),

      // Checkout Routes
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/checkout/success',
        builder: (context, state) => const OrderSuccessScreen(),
      ),

      // Order Routes
      GoRoute(
        path: '/order/:id',
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/order/:id/tracking',
        builder: (context, state) => OrderTrackingScreen(
          orderId: state.pathParameters['id'] ?? '',
        ),
      ),

      // Other Routes
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/addresses/add',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
