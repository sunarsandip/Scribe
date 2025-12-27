import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scribe/controllers/user_controller.dart';
import 'package:scribe/models/user_model.dart';

class AuthController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  //login with email and password
  Future<Map<String, dynamic>> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return {
        'success': userCredential.user != null,
        'message': userCredential.user != null
            ? 'Login Successful'
            : 'Login Failed',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      return {'success': false, 'message': "${e.message}"};
    } catch (e) {
      debugPrint("Unexpected error during login: $e");
      return {'success': false, 'message': "$e"};
    }
  }

  //signup with email and password
  Future<Map<String, dynamic>> signupWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return {
        'success': userCredential.user != null,
        'message': userCredential.user != null
            ? 'Login Successful'
            : 'Login Failed',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint("Unable to create account with email and password: $e");
      return {'success': false, 'message': "${e.message}"};
    } catch (e) {
      debugPrint("Unable to create account with email and password: $e");
      return {'success': false, 'message': "$e"};
    }
  }

  // sign in with google
  Future<Map<String, dynamic>> logInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign out first to ensure fresh sign-in
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) {
        return {"success": false, "message": "Google Sign In Cancelled"};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );
      // checking if user exists in the Database
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final bool exists = await UserController().userExist(user.uid);
        if (!exists) {
          final UserModel newUser = UserModel(
            uid: user.uid,
            email: user.email ?? "",
            userName: user.displayName ?? "",
            profilePic: user.photoURL ?? "",
          );
          await UserController().createUser(newUser, newUser.uid);
        }
      }

      return {
        'success': userCredential.user != null,
        'message': userCredential.user != null
            ? 'Google Sign In Successful'
            : 'Google Sign In Failed',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint(
        "Firebase Auth Error during Google Sign In: ${e.code} - ${e.message}",
      );
      return {"success": false, "message": "Firebase Auth Error: ${e.message}"};
    } catch (e) {
      debugPrint("Failed to Sign In with Google: $e");
      return {"success": false, "message": "Failed to Sign In with Google: $e"};
    }
  }

  // logout method
  Future<void> logOut() async {
    try {
      // Sign out from Google Sign-In if user is signed in with Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      // Sign out from Firebase
      await auth.signOut();
    } catch (e) {
      debugPrint("Failed to log out: $e");
    }
  }

  // change password
  Future<Map<String, dynamic>> changePassword(
    String newPassword,
    String currentPassword,
    String email,
    BuildContext context,
  ) async {
    try {
      if (newPassword.isNotEmpty && currentPassword.isNotEmpty) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          final credential = EmailAuthProvider.credential(
            email: email,
            password: currentPassword,
          );
          await user!.reauthenticateWithCredential(credential);
          await user.updatePassword(newPassword);
          return {"success": true, "message": "Password changes successfully"};
        } on FirebaseAuthException catch (e) {
          return {"success": false, "message": "${e.message}"};
        }
      }
      return {"success": false, "message": "Password Fields Empty !"};
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error during password change: ${e.message}");
      return {'success': false, 'message': "${e.message}"};
    } catch (e) {
      debugPrint("Unexpected error during password change: $e");
      return {'success': false, 'message': "$e"};
    }
  }
}