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

  // Function to handle user login and verification
  Future<void> userLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // After successful login, fetch user details from Firestore
      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection(
                "Users") // Ensure this matches your Firestore collection name
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          // Check if email in Firestore matches the email entered during login
          Map<String, dynamic> userData = snapshot.data()!;
          print(
              "Firestore Data: $userData"); // Log Firestore data for debugging
          if (userData['email'] == email) {
            // Email verified, proceed to home page
            print("User Name: ${userData['name']}");
            print("User Email: ${userData['email']}");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ModelsPage()));
          } else {
            // Email mismatch, handle error
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Email mismatch! User not found in Firestore.",
                style: TextStyle(fontSize: 18.0),
              ),
            ));
          }
        } else {
          // User document not found, handle error
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
      handleFirebaseAuthException(e); // Call helper function to handle errors
    } catch (error) {
      print("Error during user login: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        content: Text(
          "An unexpected error occurred. Please try again.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  // Helper function to handle FirebaseAuthExceptions
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
      print("Unhandled FirebaseAuthException: ${e.code}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color.fromARGB(255, 57, 56, 56),
        content: Text(
          "An error occurred during authentication. Please try again.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  // Test Firestore access to ensure it's working
  void testFirestoreAccess() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> testSnapshot =
          await FirebaseFirestore.instance
              .collection(
                  "Users") // Ensure this matches your Firestore collection name
              .doc("testUid") // Use a known document ID for testing
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
    testFirestoreAccess(); // Test Firestore access on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/Logo.png",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter E-mail';
                          }
                          return null;
                        },
                        controller: mailcontroller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email),
                            hintText: "Email",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0)),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        controller: passwordcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.lock_outline),
                            hintText: "Password",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0)),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
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
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 125, 159, 197),
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                              child: Text(
                            "Log In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500),
                          ))),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()));
              },
              child: Text("Forgot Password?",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500)),
            ),
            SizedBox(
              height: 120.0,
            ),
            Text(
              "----- or LogIn with -----",
              style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    AuthMethods().signInWithGoogle(context);
                    // Implement sign in with Google method
                  },
                  child: Image.asset(
                    "assets/google.png",
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                /*SizedBox(
                  width: 30.0,
                ),
                TextButton(
                  onPressed: () {
                    AuthMethods().signInWithApple();
                    // Implement sign in with Apple method
                  },
                  child: Image.asset(
                    "assets/apple1.png",
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  ),
                )*/
              ],
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?",
                    style: TextStyle(
                        color: Color(0xFF8c8e98),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 5.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUp()));
                  },
                  child: Text(
                    "SignUp",
                    style: TextStyle(
                        color: Color(0xFF273671),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
