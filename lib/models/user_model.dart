import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String image;
  final bool isOnline;
  final DateTime createAt;
  final DateTime lastActive;
  final String about;
  final String pushToken;
  UserModel({
     this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.isOnline,
    required this.createAt,
    required this.lastActive,
    required this.about,
    required this.pushToken,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    bool? isOnline,
    DateTime? createAt,
    DateTime? lastActive,
    String? about,
    String? pushToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      isOnline: isOnline ?? this.isOnline,
      createAt: createAt ?? this.createAt,
      lastActive: lastActive ?? this.lastActive,
      about: about ?? this.about,
      pushToken: pushToken ?? this.pushToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'isOnline': isOnline,
      'createAt': createAt,
      'lastActive': lastActive,
      'about': about,
      'pushToken': pushToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      isOnline: map['isOnline'] ?? '',
      createAt: (map['createAt'] as Timestamp).toDate(),
      lastActive: (map['lastActive']as Timestamp).toDate(),
      about: map['about'] ?? '',
      pushToken: map['pushToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, image: $image, isOnline: $isOnline, createAt: $createAt, lastActive: $lastActive, about: $about, pushToken: $pushToken)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.image == image &&
      other.isOnline == isOnline &&
      other.createAt == createAt &&
      other.lastActive == lastActive &&
      other.about == about &&
      other.pushToken == pushToken;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      image.hashCode ^
      isOnline.hashCode ^
      createAt.hashCode ^
      lastActive.hashCode ^
      about.hashCode ^
      pushToken.hashCode;
  }
}
