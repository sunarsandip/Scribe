import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scribe/controllers/recording_controller.dart';
import 'package:scribe/core/services/mic_permission_service.dart';
import 'package:scribe/models/meeting_model.dart';
import 'package:scribe/models/user_model.dart';
import 'package:scribe/views/screens/features/features_screen.dart';
import 'package:scribe/views/screens/auth/login_screen.dart';
import 'package:scribe/views/screens/auth/signup_screen.dart';
import 'package:scribe/views/screens/main/main_screen.dart';
import 'package:scribe/views/screens/meeting_info/meeting_info_screen.dart';
import 'package:scribe/views/screens/profile/update_profile_screen.dart';
import 'package:scribe/views/screens/record/record_screen.dart';
import 'package:scribe/views/screens/request_feature/request_feature_screen.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _listener = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _listener;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }
}

final _AuthChangeNotifier _authListenable = _AuthChangeNotifier();

class AppRouteConfig {
  AppRouteConfig();
  late final GoRouter appRoutes = GoRouter(
    initialLocation: "/",
    refreshListenable: _authListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = _authListenable.isLoggedIn;
      final path = state.uri.path;
      final loggingIn = path == '/login' || path == '/signup';
      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) return '/';
      return null;
    },

    // all the screens
    routes: [
      GoRoute(
        path: "/",
        name: "mainScreen",
        builder: (context, state) {
          return MainScreen();
        },
      ),
      GoRoute(
        path: "/login",
        name: "login",
        builder: (context, state) {
          return LoginScreen();
        },
      ),
      GoRoute(
        path: "/signup",
        name: "signup",
        builder: (context, state) {
          return SignupScreen();
        },
      ),
      GoRoute(
        path: "/recording",
        name: "recording",
        builder: (context, state) {
          return MicPermissionService(
            builder: (ctx) {
              final ctrl = state.extra is RecordingController
                  ? state.extra as RecordingController
                  : RecordingController();
              return RecordScreen(
                recordingController: ctrl,
                onNavigateToHome: () => context.goNamed("mainScreen"),
              );
            },
          );
        },
      ),
      GoRoute(
        path: "/meetingInfo",
        name: "meetingInfo",
        builder: (context, state) {
          final meetingData = state.extra as MeetingModel;
          return MeetingInfoScreen.MeetingInfoScreen(meetingData: meetingData);
        },
      ),
      GoRoute(
        path: "/updateProfile",
        name: "updateProfile",
        builder: (context, state) {
          final userData = state.extra as UserModel;
          return UpdateProfileScreen(userData: userData);
        },
      ),
      GoRoute(
        path: "/requestFeature",
        name: "requestFeature",
        builder: (context, state) {
          return RequestFeatureScreen();
        },
      ),
      GoRoute(
        path: "/features",
        name: "features",
        builder: (context, state) {
          return FeaturesScreen();
        },
      ),
    ],
  );
}