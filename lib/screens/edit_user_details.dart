import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_user_details/models/user_model.dart';
import 'package:flutter_user_details/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

class EditUserDetails extends StatefulWidget {
  final UserModel userModel;
  final User user;

  const EditUserDetails(this.userModel, this.user, {Key? key})
      : super(key: key);

  @override
  EditUserDetailsState createState() => EditUserDetailsState();
}

class EditUserDetailsState extends State<EditUserDetails> {
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController matricNumberController = TextEditingController();

  String currentProfileImageUrl = '';
  String profileImagePath = '';
  final XFile? pickedImage = null;
  String compressedFileRaw = '';
  String imageUrl = '';
  String filename = '';
  File imageFile = File('');
  bool loading = false;

  Future<void> pickImage(String inputSource) async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery);

    if (pickedImage == null) {
      setState(() {
        profileImagePath = '';
      });
    } else {
      setState(() {
        profileImagePath = pickedImage.path;
        currentProfileImageUrl = '';
      });
    }
  }

  Future<void> update() async {
    try {
      setState(() {
        loading = true;
      });

      if (currentProfileImageUrl.isEmpty) {
        File imageFile = File(profileImagePath);
        String? filename = imageFile.path.split('/').last;
        File compressedFile = await compressImage(imageFile);
        await firebaseStorage.ref(filename).putFile(compressedFile);
        imageUrl = await firebaseStorage.ref(filename).getDownloadURL();
        await FirestoreService().updateUser(
          widget.userModel.id,
          nameController.text,
          ageController.text,
          matricNumberController.text,
          imageUrl,
        );
      } else {
        imageUrl = widget.userModel.profileImagePath;
        profileImagePath = '';
        await FirestoreService().updateUserDetails(
          widget.userModel.id,
          nameController.text,
          ageController.text,
          matricNumberController.text,
        );
      }

      setState(() {
        loading = false;
        nameController.text = "";
        ageController.text = "";
        matricNumberController.text = "";
        profileImagePath = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfully Updated"),
      ));
    } on FirebaseException catch (e) {
      print(e);
    } catch (error) {
      print(error);
    }
  }

  Future compressImage(File file) async {
    var compressedFile =
        await FlutterNativeImage.compressImage(file.path, quality: 50);
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
                child: const Text("Camera"),
              ),
              ElevatedButton(
                onPressed: () {
                  pickImage("gallery");
                  Navigator.pop(context);
                },
                child: const Text("Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    nameController.text = widget.userModel.name;
    ageController.text = widget.userModel.age;
    matricNumberController.text = widget.userModel.matricNumber;
    profileImagePath = widget.userModel.profileImagePath;
    currentProfileImageUrl = widget.userModel.profileImagePath;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      appBar: AppBar(
        title: const Text(
          'Edit User Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal, // Adjusted color scheme
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Please Confirm"),
                    content: const Text("Are you sure to delete the user?"),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          // Yes Button
                          await FirestoreService()
                              .deleteUser(widget.userModel.id);
                          // Close the dialog
                          Navigator.pop(context);
                          // Close the edit screen
                          Navigator.pop(context);
                        },
                        child: const Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No"),
                      )
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
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
              colors: [
                Colors.teal.shade300,
                Colors.teal.shade900
              ], // Adjusted color scheme
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
                      currentProfileImageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 75,
                              backgroundColor:
                                  Colors.teal, // Adjusted color scheme
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    currentProfileImageUrl.isNotEmpty
                                        ? CachedNetworkImageProvider(
                                            currentProfileImageUrl)
                                        : null,
                              ),
                            )
                          : CircleAvatar(
                              radius: 75,
                              backgroundColor:
                                  Colors.teal, // Adjusted color scheme
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
                          primary: Colors.teal, // Adjusted color scheme
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
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              await update();
                              Navigator.pop(context);
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
