import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


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



  bool _isLoading = false; 
  bool emailTaken = false;// Track loading state
  bool _reload = false;

  @override

  void initState(){
    super.initState();
    _emailController.addListener(_emailControllerListener);
    _emailController.addListener(_emailControllerrefresh);
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
                                  if (_reload = true){
                                    _emailControllerrefresh();
                                  }
                                   // Start loadinge
                                });

                                if (_formKey.currentState!.validate()) {
                                  try {
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    // Handle the successful signup, if needed.
                                  } 
                              
                                  on FirebaseAuthException catch (e) {
                                    
                                      if (e.code == 'weak-password') 
                                          {
                                        print('The password provided is too weak.');
                                          }
                                          else if (e.code == 'email-already-in-use') {
                                        print('The account already exists for that email.');
                                          // setState(() {
                                          _emailControllerListener();
                                          // });
                                           }
                                    // Handle other signup errors, if needed.
                                  } 
                                  
                                  catch (e) {
                                    print(e.toString());
                                  }
                                  finally {
                                    setState(() {
                                      _isLoading = false;
                                      emailTaken = false;
                                      // dispose(); // Reset the emailTaken flag
                                    });
                                  }
                                }
                                
                                  setState(() {
                                        _isLoading = false;
                                        _reload = true;
                                      }                                
                                      );
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

void _emailControllerListener(){
  emailTaken = true;
}
void _emailControllerrefresh(){
  emailTaken = false;
}



}
