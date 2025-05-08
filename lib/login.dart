import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'providers/authProvider.dart' as my_auth;
import 'package:provider/provider.dart';
import 'CitizenPages/announcements.dart'; // Ensure this exists

class LoginPage extends StatefulWidget {
  final int authenticationMode; // 0 for login, 1 for signup

  LoginPage({Key? key, this.authenticationMode = 0}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late int authenticationMode;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // For signup only
  final _nameController = TextEditingController(); // For signup only

  @override
  void initState() {
    super.initState();
    authenticationMode = widget.authenticationMode;
  }

  Future<void> loginORsignup() async {
    //Signup mode
    if (authenticationMode == 1){

      var successOrError = await Provider.of<my_auth.AuthProvider>(context, listen: false).signup(
      em: _emailController.text.trim(),
      pass: _passwordController.text,
    );

    if(successOrError == "Signup successful!"){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage(authenticationMode: 0)), // Pass authenticationMode as 0 for login
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successOrError)),
      );
    }
    }
    // Login mode
    else{
      var successOrError = await Provider.of<my_auth.AuthProvider>(context, listen: false).login(
      em: _emailController.text.trim(),
      pass: _passwordController.text,
    );
    if(successOrError == "Login successful!"){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Announcements()), // Pass authenticationMode as 0 for login
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successOrError)),
      );
      
    }
    
  }
  }

  void toggleAuthMode() {
    setState(() {
      authenticationMode = authenticationMode == 0 ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'NASHRA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                authenticationMode == 0 ? 'Welcome Back,' : 'Create an Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 8),
              Text(
                authenticationMode == 0
                    ? 'Login to your account'
                    : 'Sign up to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),
              if (authenticationMode == 1)
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'ex: Ali Ahmed',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (authenticationMode == 1) SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'ex: ali.ahmed123@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (authenticationMode == 1)
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: '********',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (authenticationMode == 1) SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loginORsignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    authenticationMode == 0 ? 'LOGIN' : 'SIGN UP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: toggleAuthMode,
                child: Center(
                  child: Text(
                    authenticationMode == 0
                        ? 'Don\'t have an account? Sign up instead'
                        : 'Already have an account? Login instead',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

