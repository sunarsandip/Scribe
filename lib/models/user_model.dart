import 'dart:convert';

class UserModel {
  final String uid;
  final String email;
  final String userName;
  final String profilePic;
  UserModel({
    required this.uid,
    required this.email,
    required this.userName,
    required this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      userName: map['userName'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? uid,
    String? email,
    String? userName,
    String? profilePic,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}