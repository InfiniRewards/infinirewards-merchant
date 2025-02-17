import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinirewards_merchant/screens/auth_screen.dart';
import 'package:infinirewards_merchant/screens/dashboard_screen.dart';
import 'package:infinirewards_merchant/screens/points_issuance_screen.dart';
import 'package:infinirewards_merchant/screens/points_issuance_address_screen.dart';
import 'package:infinirewards_merchant/screens/points_issuance_phone_screen.dart';
import 'package:infinirewards_merchant/screens/signup_screen.dart';
import 'package:infinirewards_merchant/screens/splash_screen.dart';
import 'package:infinirewards_merchant/screens/voucher_creation_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/points-issuance',
      builder: (context, state) => const PointsIssuanceScreen(),
      routes: [
        GoRoute(
          path: 'phone',
          builder: (context, state) => const PointsIssuancePhoneScreen(),
        ),
        GoRoute(
          path: 'address',
          builder: (context, state) => const PointsIssuanceAddressScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/voucher-creation',
      builder: (context, state) => const VoucherCreationScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.error}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  ),
);
