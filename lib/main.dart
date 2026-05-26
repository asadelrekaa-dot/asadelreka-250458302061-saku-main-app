import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SakuApp());
}

class SakuApp extends StatefulWidget {
  const SakuApp({super.key});

  @override
  State<SakuApp> createState() => _SakuAppState();
}

class _SakuAppState extends State<SakuApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri?>? _widgetClickSubscription;
  bool _openedFromHomeWidget = false;

  @override
  void initState() {
    super.initState();
    _listenForHomeWidgetLaunches();
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenForHomeWidgetLaunches() async {
    if (kIsWeb) return;

    _widgetClickSubscription = HomeWidget.widgetClicked.listen(
      _handleWidgetUri,
      onError: (_) {},
    );

    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      _handleWidgetUri(uri);
    } catch (_) {
      // The home widget platform channel is only available on installed apps.
    }
  }

  void _handleWidgetUri(Uri? uri) {
    if (!_isAddNoteUri(uri)) return;

    _openedFromHomeWidget = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;

      if (navigator == null) return;

      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const DashboardPage(
            openAddNote: true,
          ),
        ),
        (route) => false,
      );
    });
  }

  bool _isAddNoteUri(Uri? uri) {
    if (uri == null) return false;

    return uri.scheme == 'saku' && uri.host == 'add-note';
  }

  @override
  Widget build(BuildContext context) {
    final routeFromUrl = Uri.base.fragment.split('?').first;

    final nextRoute =
        routeFromUrl.startsWith('/') && routeFromUrl.length > 1
            ? routeFromUrl
            : OnboardingPage.routeName;

    return MaterialApp(
      title: 'Saku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: _navigatorKey,
      initialRoute: SplashPage.routeName,
      routes: {
        SplashPage.routeName: (_) => SplashPage(
              onFinished: () {
                if (_openedFromHomeWidget) return;

                _navigatorKey.currentState?.pushReplacementNamed(
                  nextRoute,
                );
              },
            ),
        OnboardingPage.routeName: (_) => const OnboardingPage(),
        LoginPage.routeName: (_) => const LoginPage(),
        RegisterPage.routeName: (_) => const RegisterPage(),
        DashboardPage.routeName: (_) => const DashboardPage(),
      },
    );
  }
}