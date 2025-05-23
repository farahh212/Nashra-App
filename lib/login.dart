import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nashra_project2/screens/announcementCitizens/announcements.dart';
import 'package:nashra_project2/screens/home.dart';
import 'providers/authProvider.dart' as my_auth;
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/theme.dart';

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
      name: _nameController.text,
    );

    if(successOrError == "Signup successful!"){
      // Step 1: Get FCM token
    
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
      final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");

    // Step 2: Update Firestore user's fcmToken
    if (fcmToken != null && fcmToken.isNotEmpty) {
      final email = _emailController.text.trim();
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final docId = userQuery.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({'fcmToken': fcmToken});
      }
    }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()), // Changed to HomeScreen
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark 
                      ? [Color(0xFF64B5F6), Color(0xFF2196F3), Color(0xFF1976D2)]
                      : [Color(0xFF1976D2), Color(0xFF2196F3), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'NASHRA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                authenticationMode == 0 ? 'Welcome Back,' : 'Create an Account',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                authenticationMode == 0
                  ? 'Login to your account'
                  : 'Sign up to get started',
                style: theme.textTheme.bodyMedium,
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
                backgroundColor: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),

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
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
              ),
              // Google login button
              TextButton(
              onPressed: () async {
              final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
              final result = await authProvider.signInWithGoogle();

              // Whether a new sign-in occurred or user was already signed in, check current user
              final user = FirebaseAuth.instance.currentUser;
              print(user);

              if (user != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google sign-in failed. Please try again.')),
                );
              }
            },

              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                  width: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Sign in with Google',
                  style: TextStyle(
                  color: isDark ? Color(0xFF64B5F6) : Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                  ),
                ),
                ],
              ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
