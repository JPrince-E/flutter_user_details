import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String age;
  String matricNumber;
  String profileImagePath;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.matricNumber,
    required this.profileImagePath,
  });

  factory UserModel.fromJson(DocumentSnapshot snapshot) {
    return UserModel(
      id: snapshot.id,
      name: snapshot['name'],
      age: snapshot['age'],
      matricNumber: snapshot['matricNumber'],
      profileImagePath: snapshot['profileImagePath'],
    );
  }
}
