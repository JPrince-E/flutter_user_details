import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future addUser(String name, String age, String matricNumber,
      String profileImagePath, String userId) async {
    try {
      await firestore.collection('user').add({
        "name": name,
        "age": age,
        "matricNumber": matricNumber,
        "profileImagePath": profileImagePath,
        "date": DateTime.now(),
        "userId": userId
      });
    } catch (e) {
      //
    }
  }

  Future updateUser(
    String docId,
    String name,
    String age,
    String matricNumber,
    String profileImagePath,
  ) async {
    try {
      await firestore.collection('user').doc(docId).update({
        "name": name,
        "age": age,
        "matricNumber": matricNumber,
        "profileImagePath": profileImagePath,
      });
    } catch (e) {}
  }

  Future updateUserDetails(
    String docId,
    String name,
    String age,
    String matricNumber,
  ) async {
    try {
      await firestore.collection('user').doc(docId).update({
        "name": name,
        "age": age,
        "matricNumber": matricNumber,
      });
    } catch (e) {}
  }

  Future deleteUser(String docId) async {
    try {
      await firestore.collection('user').doc(docId).delete();
    } catch (e) {
      print(e);
    }
  }
}
