import 'package:cutout_ai/core/network/dio_config.dart';
import 'package:cutout_ai/core/providers/connectivity_provider.dart';
import 'package:cutout_ai/core/services/connectivity_service.dart';
import 'package:cutout_ai/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test — démarre sans erreur', (tester) async {
    // Service de connectivité sans initialize() pour éviter les timers en test
    final fakeConnectivity = ConnectivityService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(Dio()),
          connectivityServiceProvider.overrideWithValue(fakeConnectivity),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
