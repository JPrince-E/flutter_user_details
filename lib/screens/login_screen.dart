import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user_details/main.dart';
import 'package:flutter_user_details/models/user_model.dart';
import 'package:flutter_user_details/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final UserModel userModel;

  const LoginScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade300, Colors.blueGrey],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/pngegg.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ), // Label text color
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor:
                            Colors.teal.shade100, // Slightly darker color
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 25), // Increase the vertical padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ), // Label text color
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor:
                            Colors.teal.shade100, // Slightly darker color
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 25), // Increase the vertical padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("All fields are required!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                User? result = await AuthService().login(
                                  emailController.text,
                                  passwordController.text,
                                  context,
                                );
                                if (result != null) {
                                  print("Success");
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyApp(
                                        userModel: widget.userModel,
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                              setState(() {
                                loading = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.teal, // Change button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 18, // Reduced font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
