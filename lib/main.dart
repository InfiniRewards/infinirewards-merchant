import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinirewards_merchant/config/theme.dart';
import 'package:infinirewards_merchant/models/app_state.dart';
import 'package:infinirewards_merchant/providers/starknet.dart';
import 'package:infinirewards_merchant/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AppStateDataImplAdapter());
  }

  runApp(
    const ProviderScope(
      child: InfiniRewardsApp(),
    ),
  );
}

class InfiniRewardsApp extends ConsumerWidget {
  const InfiniRewardsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(starknetProvider);
    return MaterialApp.router(
      title: 'InfiniRewards Merchant',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
