import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:music_diary_new/features/home/logic/home_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'package:music_diary_new/core/data/json_file_repo.dart';
import 'package:music_diary_new/core/models/user_profile.dart';
import 'package:music_diary_new/features/auth/logic/auth_service.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';
import 'package:music_diary_new/features/auth/start_menu_page.dart';
import 'package:music_diary_new/features/home/home_page.dart';

Future<void> main() async {
  // перехоплювати необроблені помилки в межах зони
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ініціалізація
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Якщо не веб, то крашлітікс
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
    } else {
      debugPrint('Crashlytics не підтримується у Flutter Web');
    }

    // Тестова подія
    await FirebaseAnalytics.instance
        .logEvent(name: 'test_event', parameters: {'env': kIsWeb ? 'web' : 'mobile'});

    print('Firebase connected successfully!');

    // сервіси для аутентифікації та локал сховище
    await AuthService.instance.initialize();
    if (!kIsWeb) {
      await JsonFileRepo.initialize();
    } else {
      print("JsonFileRepo disabled on Web");
    }

    // Запуск 
    runApp(
      ChangeNotifierProvider(
        create: (_) => HomeProvider()..initialize(),
        child: const DiaryApp(),
      ),
    );

  }, (error, stack) async {
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } else {
      debugPrint('Error (no Crashlytics on Web): $error');
    }
  });
}


class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return MaterialApp(
      title: 'Diary Blocks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: AuthService.instance.authState,
      builder: (context, user, _) {
        if (user == null) {
          // Якщо не авторизований
          FirebaseAnalytics.instance.logEvent(name: 'open_start_menu');
          return const StartMenuPage();
        }

        // Якщо авторизований
        FirebaseAnalytics.instance.logEvent(name: 'open_home_page');
        return const DiaryHomePage();
      },
    );
  }
}
