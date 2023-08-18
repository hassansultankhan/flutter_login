import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/profileScreen.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();



  bool _isLoading = false; 
  bool emailTaken = false;
  bool emailSet = false;
  String email1 = "";
  bool emailError = false;

  @override

  void initState(){
    super.initState();
    
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: GestureDetector(
        
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                          controller: _emailController,
                          validator: (val) => emailValidator(val, emailTaken),
                          decoration: InputDecoration(labelText: 'Email'),
                        ),


                const SizedBox(height: 12),
                TextFormField(
                      controller: _passwordController,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Enter a password';
                        } else if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter Confirm Password';
                    } else if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  autofocus: true,
                  controller: _firstnameController,
                  validator: (val) => val!.isEmpty ? 'Enter First Name' : null,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastnameController,
                  validator: (val) => val!.isEmpty ? 'Enter Last Name' : null,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter your valid contact number';
                    } else if (!isValidPhoneNumber(val)) {
                      return 'Enter a valid numeric phone number';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone, // Use phone keyboard layout
                  decoration: InputDecoration(labelText: 'Phone Number'),
                ),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup, // Disable button when loading
                  child: _isLoading
                      ? CircularProgressIndicator() // Show loading indicator
                      : Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

                  Future<void> _handleSignup() async {
                      print('process start');
                      setState(() {
                        _isLoading = true;
                        emailTaken = false;
                      });

                      if (_formKey.currentState!.validate()) {
                        try {
                                 // upload firebase Authenticator credentials
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );

                                    print("Credentials accepted");

                                    //create firebase firestore collection with title of profiles
                                    final CollectionReference _profiles =
                                        FirebaseFirestore.instance.collection('Profiles');

                                    final String email = _emailController.text;
                                    final String password = _passwordController.text;
                                    final String firstName = _firstnameController.text;
                                    final String lastName = _lastnameController.text;
                                    final String phoneNumber = _phoneController.text;

                                    // add credentials to that collection database created above in firestore
                                    await _profiles.add({
                                      "email": email,
                                      "password": password,
                                      "First Name": firstName,
                                      "Last Name": lastName,
                                      "phone Number": phoneNumber,
                                      "timestamp": FieldValue.serverTimestamp(),
                                    });

                        

                            
                            // Query the documents in the collection and order by creation time in descending order
                              QuerySnapshot querySnapshot = await _profiles.orderBy('timestamp', descending: true).limit(1).get();

                              // Check if there are any documents in the query result
                              if (querySnapshot.docs.isNotEmpty) {
                                // Access the data of the first document (most recent)
                                String email1 = querySnapshot.docs.first['email'];

                                // Now you can use this data as needed
                                print('Most recent email: $email1');

                                //if email retreived set bool to transger credentials to profile page
                                if (email == email1 ) {
                                  setState(() {
                                    emailSet = true;
                                  });
                                }
                              } else {
                                // Handle the case where no documents were found
                                print('No documents found.');
                              }
                          } 
                          
                          // Handle the successful signup, if needed.
                        on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                            setState(() {
                              emailError = true;
                            });

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Error'),
                                content: Text('An account is already assigned to this email.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                          // Handle other signup errors, if needed.
                        } catch (e) {
                          print(e.toString());
                        } finally {
                          setState(() {
                            _isLoading = false;
                            emailTaken = false;
                          });
                        }
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      // stuck here
                      print("emailSet: $emailSet");
                      print("emailError: $emailError");
                      if (emailSet 
                      && !emailError
                      ){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>
                         ProfileScreen(
                          displayName: _firstnameController.text,
                          email: _emailController.text, 
                          photoUrl: "assets/smiley.png")));
                      }

                      // Clear text editing controller values
                      // dispose();
                    }


  bool isValidEmail(String email) {
  // Use a regular expression to check if the email is in a valid format
  final emailRegExp = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
    multiLine: false,
  );
  return emailRegExp.hasMatch(email);

  }

  String? emailValidator(String? val, bool isEmailTaken) {
  if (val!.isEmpty) {
    return 'Enter an email';
  } else if (!isValidEmail(val)) {
    return 'Enter a valid email address';
  } else if (isEmailTaken) {
    return "An account is already assigned to this email";
  }
  return null;
}

bool isValidPhoneNumber(String phoneNumber) {
  // Use a regular expression to check if the phone number is numeric
  final phoneRegExp = RegExp(r'^[0-9]+$');
  return phoneRegExp.hasMatch(phoneNumber);
}



}
