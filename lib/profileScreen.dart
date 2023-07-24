import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  final String displayName;
  final String email;
  final String photoUrl;

  const ProfileScreen({
    Key? key,
    required this.displayName,
    required this.email,
    required this.photoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.exit_to_app),
            onPressed:() => leave(context),
          ),

        ],
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(photoUrl),
            ),
            SizedBox(height: 16),
            Text(
              'Name: $displayName',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> leave(BuildContext context) async {

    
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google SignIn
      await _googleSignIn.signOut();

      // Navigate back to the login screen
      Navigator.pop(context);
    } catch (error) {
      print('Error signing out: $error');
      // Handle the error here
    }
  }


  }
