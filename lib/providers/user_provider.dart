import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribe/controllers/user_controller.dart';
import 'package:scribe/models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final getUserProvider = FutureProvider<UserModel?>((ref) async {
  final authUser = await ref.watch(authStateProvider.future);
  if (authUser == null) {
    return null;
  }
  return UserController().getUser(authUser.uid);
});
