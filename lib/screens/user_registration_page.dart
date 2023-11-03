import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_user_details/models/user_model.dart';
import 'package:flutter_user_details/services/auth_service.dart';
import 'package:flutter_user_details/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

class UserRegistrationPage extends StatefulWidget {
  final UserModel userModel;
  final User user;
  const UserRegistrationPage(
      {Key? key, required this.userModel, required this.user})
      : super(key: key);

  @override
  UserRegistrationPageState createState() => UserRegistrationPageState();
}

class UserRegistrationPageState extends State<UserRegistrationPage> {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController matricNumberController = TextEditingController();
  String profileImagePath = '';
  bool loading = false;

  Future<void> pickImage(String inputSource) async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery);

    if (pickedImage == null) {
      return;
    } else {
      setState(() {
        profileImagePath = pickedImage.path;
      });
    }
  }

  Future<void> register() async {
    if (profileImagePath.isEmpty) {
      return;
    }

    File imageFile = File(profileImagePath);
    String? filename = imageFile.path.split('/').last;
    File compressedFile = await compressImage(imageFile);

    try {
      setState(() {
        loading = true;
      });

      await firebaseStorage.ref(filename).putFile(compressedFile);

      String imageUrl = await firebaseStorage.ref(filename).getDownloadURL();

      await FirestoreService().addUser(
        nameController.text,
        ageController.text,
        matricNumberController.text,
        imageUrl,
        widget.user.uid,
      );

      setState(() {
        loading = false;
        nameController.text = "";
        ageController.text = "";
        matricNumberController.text = "";
        profileImagePath = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfully Uploaded"),
        backgroundColor: Colors.teal, // Adjusted color scheme
      ));
    } on FirebaseException catch (e) {
      print(e);
    } catch (error) {
      print(error);
    }
  }

  Future compressImage(File file) async {
    File compressedFile =
        await FlutterNativeImage.compressImage(file.path, quality: 90);
    print("Original Size");
    print(file.lengthSync());
    print("Compressed Size");
    print(compressedFile.lengthSync());
    return compressedFile;
  }

  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  pickImage("camera");
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Adjusted color scheme
                ),
                child: const Text("Camera"),
              ),
              ElevatedButton(
                onPressed: () {
                  pickImage("gallery");
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Adjusted color scheme
                ),
                child: const Text("Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      appBar: AppBar(
        title: const Text(
          'User Registration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal, // Adjusted color scheme
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await AuthService().signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text("Sign Out"),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade300, Colors.teal.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImagePath.isNotEmpty
                              ? FileImage(File(profileImagePath))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: showImageSourceDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text('Select Image'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, // Adjusted color scheme
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Age',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, // Adjusted color scheme
                  ),
                ),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your age',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Matric Number',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, // Adjusted color scheme
                  ),
                ),
                TextField(
                  controller: matricNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your matric number',
                  ),
                ),
                const SizedBox(height: 20),
                loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                ageController.text.isEmpty ||
                                matricNumberController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'All fields are required!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      Colors.red, // Adjusted color scheme
                                ),
                              );
                            } else {
                              await register();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.teal, // Adjusted color scheme
                          ),
                          child: const Text(
                            'Update User',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
