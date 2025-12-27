import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:scribe/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class UserController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // store user in firestore database
  Future<bool> createUser(UserModel newUser, String uid) async {
    try {
      firestore.collection("users").doc(uid).set(newUser.toMap());
      return true;
    } catch (e) {
      debugPrint("Failed to save user in firestore: $e");
      return false;
    }
  }

  // update user profile
  Future<bool> updateUserProfile(UserModel updatedUser, String uid) async {
    try {
      firestore.collection("users").doc(uid).update(updatedUser.toMap());
      return true;
    } catch (e) {
      debugPrint("Failed to update user profile: $e");
      return false;
    }
  }

  // upload newProfilePic
  Future<String?> uploadProfilePic(String uid, XFile image) async {
    try {
      final storageRef = storage
          .ref()
          .child("profilePics")
          .child("$uid+profilePic.jpg");
      await storageRef.putData(await image.readAsBytes());
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint("Failed to upload profile pic: $e");
      return null;
    }
  }

  // get user info from database
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection("users")
          .doc(uid)
          .get();
      if (documentSnapshot.exists) {
        return UserModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>,
        );
      } else {
        debugPrint("User dont exist in database");
        return null;
      }
    } catch (e) {
      debugPrint("Failed to get profile info: $e");
      return null;
    }
  }

  // Check if user exist in the database
  Future<bool> userExist(String uid) async {
    try {
      final DocumentSnapshot docRef = await firestore
          .collection("users")
          .doc(uid)
          .get();
      return docRef.exists;
    } catch (e) {
      debugPrint("Failed to check if user exist: $e");
      return false;
    }
  }
}