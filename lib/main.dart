import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_user_details/firebase_options.dart';
import 'package:flutter_user_details/models/user_model.dart';
import 'package:flutter_user_details/screens/register_screen.dart';
import 'package:flutter_user_details/screens/user_details_page.dart';
import 'package:flutter_user_details/screens/user_registration_page.dart';
import 'package:flutter_user_details/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  UserModel userModel = UserModel(
    id: "1",
    name: "YourName",
    age: "YourAge",
    matricNumber: "YourMatricNumber",
    profileImagePath: "",
  );
  runApp(MyApp(userModel: userModel));
}

class MyApp extends StatefulWidget {
  final UserModel userModel;

  MyApp({Key? key, required this.userModel}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // const MyApp({Key? key, required this.userModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: StreamBuilder(
        stream: AuthService().firebaseAuth.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          User? user = snapshot.data; // Initialize user here
          if (user != null) {
            // If UserModel is available, pass it; otherwise, pass null
            return App(user: user, userModel: widget.userModel);
          }
          return RegisterScreen(
            userModel: widget.userModel,
          );
        },
      ),
    );
  }
}

class App extends StatefulWidget {
  final UserModel userModel;
  final User user;

  App({
    Key? key,
    required this.userModel,
    required this.user,
  }) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  int _currentIndex = 0;
  List<Widget> _children = [];

  @override
  void initState() {
    super.initState();

    // Initialize the user and userModel from the widget's properties
    User user = widget.user;
    UserModel userModel = widget.userModel;

    _children = [
      UserRegistrationPage(
        userModel: userModel,
        user: user,
      ),
      UserDetailsPage(user: user),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'User Details',
          ),
        ],
      ),
    );
  }
}
