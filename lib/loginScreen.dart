import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/signupscreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_login/profileScreen.dart';

class loginScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool log = false;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _handleGoogleSignIn(context),
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () => signin(context),
              child: const Text('Sign in with Firebase'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    
    //  log = await Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => buildProfileScreen(), // Use a function to construct the ProfileScreen widget
    //           ),
    //         );
    try {
      print(log);
      // Sign out from Google Sign-In (clear previous credentials)
      if (log == true){
        print('signing out');
      await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        log = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              displayName: user.displayName ?? '',
              email: user.email ?? '',
              photoUrl: user.photoURL ?? '',
            ),
          ),
          
        );
        print('$log');
      }

    } catch (error, stackTrace) {
      print('Error signing in with Google: $error');
      print(stackTrace);
      // Handle the error here
    }
  }

  void signin(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (context){
        Padding(padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.top,

          ),); 
          return Wrap(
            
          children: [
            ListTile(
            leading: Icon(Icons.login),
            title: Text('Sign In'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              // Show the sign-in AlertDialog
              showSignInDialog(context);
            },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Sign Up'),
                  onTap: () async {
                    Navigator.pop(context); // Close the bottom sheet
                                                    final success = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                                                    );

                                                      if (success == true) {
                                                        // Handle successful sign up (you can show a success message here)
                                                                        }
                                  }
                                ),
                                // const SizedBox(height: 150,)
                        ]
                    );
                      }
                  );

                }

  void showSignInDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController emailController = TextEditingController();
      TextEditingController passwordController = TextEditingController();
      bool isLoading = false;
      String errorText = '';

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Sign In'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 10),
                isLoading
                    ? CircularProgressIndicator()
                    : GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });

                          String email = emailController.text;
                          String password = passwordController.text;

                          try {
                            UserCredential userCredential =
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                            // Successfully signed in
                            User? user = userCredential.user;
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    displayName: user.displayName ?? '',
                                    email: user.email ?? '',
                                    photoUrl: user.photoURL ?? '',
                                  ),
                                ),
                              );
                            }
                          } catch (error) {
                            setState(() {
                              isLoading = false;
                              if (error is FirebaseAuthException) {
                                if (error.code == 'user-not-found') {
                                  errorText =
                                      'There is no account against this email.';
                                } else if (error.code == 'wrong-password') {
                                  errorText = 'Wrong password.';
                                } else {
                                  errorText = 'An error occurred. Please try again.';
                                }
                              }
                            });
                          }
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                SizedBox(height: 10),
                // Inside the StatefulBuilder's builder function                 
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorText,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    // ... (rest of the code remains the same)
                  ),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the sign-in dialog
                    // Implement password recovery logic
                  },
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the sign-in dialog
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}





}
