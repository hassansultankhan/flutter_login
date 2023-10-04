import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/signupscreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_login/profileScreen.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  // @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// class loginScreen extends StatelessWidget {

  //Entry point of firebase SDK (software development kit)
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
            const SizedBox(
              height: 10,
            ),
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
    try {
      print(log);
      // Sign out from Google Sign-In (clear previous credentials) by using the log value of true that is achieved from profileScreen with leave() function
      if (log == true) {
        print('signing out');
        await _googleSignIn.signOut();
      }

      //Hold fields describing a signed in user's identity, provided as input
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      //Below code generates signin token from google for the provided input by user
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      //this will create credentials from the google after the generation of signin token
      final AuthCredential credential = GoogleAuthProvider.credential(
        //accessToken is used as Google APIs (application programming interface) for accessing other google platforms like google drive etc.
        accessToken: googleAuth.accessToken,
        //idToken holds user related information. used ass id pass.
        idToken: googleAuth.idToken,
      );

      // this will return values of users from google and passed onto user variable
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
        builder: (context) {
          Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.top,
            ),
          );
          return Wrap(children: [
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Sign In'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                // Show the sign-in AlertDialog
                showSignInDialog(context);
                print("Signin screen displayed");
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
                }),
            // const SizedBox(height: 150,)
          ]);
        });
  }

  void showSignInDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    bool isLoading = false;
    String errorText = '';

    Future.delayed(Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Sign In'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                            height: 0), // Hide the indicator when not loading
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
                      onTap: () {
                        Navigator.pop(context); // Close the sign-in dialog
                        // Implement password recovery logic
                        sendLoginInformation(context, emailController.text);
                      },
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the sign-in dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            String email = emailController.text;
                            String password = passwordController.text;

                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
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
                                    errorText =
                                        'An error occurred. Please try again.';
                                  }
                                }
                              });
                            }
                          },
                          child: Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  void sendLoginInformation(BuildContext context, String emailValue) {
    showDialog(
      context: context,
      builder: (context) {
        String errorMessage =
            ''; // Add this variable to store the error message
        return AlertDialog(
          title: Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to send related information to your email?',
              ),
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ), // Display error message here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Implement the logic to send login information to the user's email
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailValue);
                  Navigator.pop(context); // Close the dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Email Sent'),
                      content: Text(
                          'Check your email account for login-related information.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the alert dialog
                          },
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                } catch (error) {
                  setState(() {
                    errorMessage = 'An error occurred while sending the email.';
                  });
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
