import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinirewards_merchant/models/app_state.dart';

part 'app_state.g.dart';

const _appStateBoxName = 'app_state';

@riverpod
class AppState extends _$AppState {
  late Box<AppStateData> _box;

  @override
  AppStateData build() {
    _init();
    return AppStateData();
  }

  Future<void> _init() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppStateDataImplAdapter());
    }

    // Open box
    _box = await Hive.openBox<AppStateData>(_appStateBoxName);

    // Load state from box or use default
    final savedState = _box.get('current');
    if (savedState != null) {
      state = savedState;
    }
  }

  Future<void> setNavigatorIndex(int index) async {
    state = state.copyWith(navigatorIndex: index);
    await _box.put('current', state);
  }

  Future<void> setTheme(String theme) async {
    state = state.copyWith(theme: theme);
    await _box.put('current', state);
  }

  Future<void> setAutoLoginResult(bool result) async {
    state = state.copyWith(autoLoginResult: result);
    await _box.put('current', state);
  }

  Future<void> clear() async {
    state = AppStateData();
    await _box.clear();
  }
}
