import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_user_details/models/user_model.dart';
import 'package:flutter_user_details/screens/login_screen.dart';
import 'package:flutter_user_details/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final UserModel userModel;

  const RegisterScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register",
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
              colors: [Colors.teal.shade300, Colors.teal.shade200],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      child: Image.asset('images/pngeggs.png'),
                    ),
                    const SizedBox(height: 5),
                    _buildTextField(
                      controller: emailController,
                      labelText: "Email",
                      labelStyle: const TextStyle(
                        fontSize: 200,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: passwordController,
                      labelText: "Password",
                      labelStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: confirmPasswordController,
                      labelText: "Confirm Password",
                      labelStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    loading
                        ? const CircularProgressIndicator()
                        : _buildElevatedButton(
                            text: "Submit",
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                _showSnackBar(
                                    context, "All fields are required!");
                              } else if (passwordController.text !=
                                  confirmPasswordController.text) {
                                _showSnackBar(
                                    context, "Password doesn't match!");
                              } else {
                                User? result = await AuthService().register(
                                    emailController.text,
                                    passwordController.text,
                                    context);
                                if (result != null) {
                                  print("Success");
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(
                                          userModel: widget.userModel),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                              setState(() {
                                loading = false;
                              });
                            },
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(userModel: widget.userModel),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                      ),
                      child: const Text("Already have an account? Login here"),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    loading
                        ? const CircularProgressIndicator()
                        : SignInButton(
                            Buttons.Google,
                            text: "Continue with Google",
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await AuthService().signInWithGoogle();
                              setState(() {
                                loading = false;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool isPassword = false,
    required labelStyle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(prefixIcon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 20), // Increase the vertical padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            primary: Colors.teal, // Change button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
