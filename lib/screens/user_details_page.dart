import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_user_details/models/user_model.dart';
import 'package:flutter_user_details/screens/edit_user_details.dart';
import 'package:flutter_user_details/services/auth_service.dart';

class UserDetailsPage extends StatelessWidget {
  final User user;

  const UserDetailsPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      appBar: AppBar(
        title: const Text(
          'User Details',
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
      body: Container(
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('user')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
              return const Center(
                child: Text("No User Available"),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.docs.length ?? 0,
                itemBuilder: (context, index) {
                  UserModel userModel =
                      UserModel.fromJson(snapshot.data.docs[index]);

                  return Card(
                    color: Colors.teal,
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.teal, // Adjusted color scheme
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          backgroundImage: userModel.profileImagePath.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  userModel.profileImagePath)
                              : null,
                        ),
                      ),
                      title: Text(
                        userModel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey, // Adjusted color scheme
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Age: ${userModel.age}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "Matric Number: ${userModel.matricNumber}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                EditUserDetails(userModel, user)));
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
