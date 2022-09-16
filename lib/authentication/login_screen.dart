import 'package:euser/authentication/signup_screen.dart';
import 'package:euser/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../widgets/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm(BuildContext context) {
    if (!emailTextEditingController.text.contains("@") || !emailTextEditingController.text.contains(".")) {
      showToaster(context, "Please enter a valid email", 'fail');
    } else if (passwordTextEditingController.text.isNotEmpty) {
      if (passwordTextEditingController.text.length < 6) {
        showToaster(context, "Password must be at least 6 characters", 'fail');
      } else {
        loginUser();
      }
    } else if (passwordTextEditingController.text.isEmpty) {
      showToaster(context, "Password is required", 'fail');
    }
  }

  loginUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(
          message: "Processing . . .",
        );
      },
    );
    final User? firebaseUser = (await fAuth
            .signInWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
            .catchError((msg) {
      Navigator.pop(context);
      showToaster(context, "Error: " + msg.toString(), 'fail');
    }))
        .user;
    if (firebaseUser != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).once().then((userKey) {
        final snap = userKey.snapshot;
        if (snap.value != null) {
          currentFirebaseUser = firebaseUser;
          Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
        } else {
          fAuth.signOut();
          showToaster(context, "No record exist with this credential.", "fail");
          Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
        }
      });
    } else {
      Navigator.pop(context);
      showToaster(context, "Error occurred during Login.", "fail");
    }
  }

  void showToaster(BuildContext context, String str, String status) {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          str,
          style: status == "success" ? const TextStyle(color: Colors.green, fontSize: 15) : const TextStyle(color: Colors.red, fontSize: 15),
        ),
        action: SnackBarAction(label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 35),
            const Text(
              "Login",
              style: TextStyle(fontSize: 26, color: Color(0xFF4F6CAD), fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30),
              child: Image.asset("images/login.png"),
            ),
            const Text(
              "Welcome to E-hatid",
              style: TextStyle(fontSize: 26, color: Color(0xFF4F6CAD), fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Color(0xFF4F6CAD),
                ),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "jdcruz@gmail.com",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Color(0xFF4F6CAD)),
                  ),
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 187, 186, 186),
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Color(0xFF4F6CAD),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(
                  color: Color(0xFF4F6CAD),
                ),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Color(0xFF4F6CAD)),
                  ),
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 187, 186, 186),
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Color(0xFF4F6CAD),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            TextButton(
              child: const Text(
                "Don't have an Account? Sign Up here",
                style: TextStyle(color: Color(0xFF4F6CAD), fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpScreen()));
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                validateForm(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF4F6CAD),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
