import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gardenmate/Pages/ForgotPassword.dart';
import 'package:gardenmate/Pages/Home.dart';
import 'package:gardenmate/Pages/SignUp_Page.dart';
import 'package:gardenmate/Values/Authentication.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future<void> userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          if (userData['email'] == email) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ModelsPage(successMessage: "Login Successful!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Email mismatch! User not found in Firestore.",
                style: TextStyle(fontSize: 18.0),
              ),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "User document not found in Firestore.",
              style: TextStyle(fontSize: 18.0),
            ),
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      handleFirebaseAuthException(e);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        content: Text(
          "An unexpected error occurred. Please try again.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  void handleFirebaseAuthException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(
          "No user found for that email.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(
          "Wrong password provided.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 57, 56, 56),
        content: Text(
          "An error occurred during authentication. Please try again.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  void testFirestoreAccess() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> testSnapshot =
          await FirebaseFirestore.instance
              .collection("Users")
              .doc("testUid")
              .get();

      if (testSnapshot.exists) {
        print("Test Document Data: ${testSnapshot.data()}");
      } else {
        print("Test document not found.");
      }
    } catch (e) {
      print("Error during Firestore access test: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    testFirestoreAccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Adjust height as needed
              /*Image.asset(
                "assets/Logo1.png", // Replace with your logo asset path
                height: 120, // Adjust height as needed
              ),*/
              SizedBox(height: 80), // Adjust height as needed
              Text(
                "Welcome",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Login to your account",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 40),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter E-mail';
                        }
                        return null;
                      },
                      controller: mailcontroller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: passwordcontroller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              width: 2.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            // Implement password visibility toggle
                          },
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            email = mailcontroller.text;
                            password = passwordcontroller.text;
                          });
                          userLogin();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "----- or Login with -----",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: Image.asset(
                      "assets/google.png",
                      height: 24,
                      width: 24,
                    ),
                  ),
                  /*TextButton(
                    onPressed: () {
                      AuthMethods().signInWithFacebook(context);
                    },
                    child: Image.asset(
                      "assets/facebook.png",
                      height: 24,
                      width: 24,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      AuthMethods().signInWithInstagram(context);
                    },
                    child: Image.asset(
                      "assets/instagram.png",
                      height: 24,
                      width: 24,
                    ),
                  ),*/
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have account?",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SignUp()));
                    },
                    child: Text(
                      "Create Now",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
