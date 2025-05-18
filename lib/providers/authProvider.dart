import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthProvider with ChangeNotifier {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String _token = '';
    DateTime _expiryDate = DateTime.utc(1970); // Set to a date in the past to indicate no token is available as a default value
    String _userId = '';
    bool _authenticated = false;
    bool _isAdmin = false; // Add admin flag

     dynamic _user;
  dynamic get user => _user;

  // Optionally, add a setter or method to update _user
  set user(dynamic value) {
    _user = value;
    notifyListeners();
  }

//this is used to check if the user is authenticated or not
    bool isAuthenticated() {
        return _authenticated;
    }

Future<UserCredential?> signInWithGoogle() async {
  try {
    // ✅ Skip sign-in if already authenticated
    if (_auth.currentUser != null) {
      
      _userId = _auth.currentUser!.uid;
      final idTokenResult = await _auth.currentUser!.getIdTokenResult();
      _token = idTokenResult.token ?? '';
      _expiryDate = idTokenResult.expirationTime ?? DateTime.now().add(Duration(hours: 1));
      _authenticated = true;
      _isAdmin = _auth.currentUser!.email?.toLowerCase() == 'government@nashra.com';
      notifyListeners();
      //print(_auth.currentUser);
      return null; 
    }

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = (await _auth.signInWithCredential(credential)).user;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();
      _token = idTokenResult.token ?? '';
      _expiryDate = idTokenResult.expirationTime ?? DateTime.now().add(Duration(hours: 1));
      _userId = user.uid;
      _authenticated = true;
      _isAdmin = user.email?.toLowerCase() == 'government@nashra.com';

      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDoc = await usersRef.doc(user.uid).get();
      if (!userDoc.exists) {
        await usersRef.doc(user.uid).set({
          'id': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'password': '', // Password not available from Google Sign-In
          'ads': [],
          'notifications': [],
          'reports': [],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      notifyListeners();
    }
  } catch (e) {
    print('Google Sign-In Error: $e');
    return null;
  }

  return null;
}



    bool get isAdmin => _isAdmin; // Add admin getter

    String get token{
        if(_expiryDate!=DateTime.utc(1970) && _expiryDate.isAfter(DateTime.now()) && _token != '')
        {
            return _token;
        }
            return '';
    }

    String get userId{
        return _userId;
    }


  Future<void> logout() async {
  await _auth.signOut();
  await GoogleSignIn().signOut(); // <-- Add this line
  _authenticated = false;
  _expiryDate = DateTime.now();
  _isAdmin = false;
  _token = '';
  _userId = '';
  notifyListeners();
}

 
//possible errors: EMAIL_EXISTS, OPERATION_NOT_ALLOWED, TOO_MANY_ATTEMPTS_TRY_LATER, EMAIL_NOT_FOUND, INVALID_PASSWORD, USER_DISABLED, WEAK_PASSWORD, INVALID_EMAIL
//error can be found in the response body of the request in the message
//its not caught in the try catch block, so we can handle it in the UI
//this is because the request is not failing, but the response is an error (not a server error)
//can use json.decode(response.body)['error']['message'] to get the error message, but we need to check if the response is an error first
//this is because if there is no error, the response body will not have the error key and this will throw an error


//GOAL: SUCCES/FAILURE MESSAGE TO UI

  Future<String> signup({required String em, required String pass, required String name}) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDCWaN2gvhvrDdKOsd4Gjvr9ve6_6lG-NI');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': em,
          'password': pass,
          'returnSecureToken': true,
        }),
        headers: {'Content-Type': 'application/json'},
      );

//only for testing/debugging purposes, doesnt appear in the UI
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
        print("✅ Token = ${decodedResponse['idToken']}");
        print("⏳ Expires In = ${decodedResponse['expiresIn']}");
        print("🆔 Local ID = ${decodedResponse['localId']}");
      } else {
        final errorResponse = json.decode(response.body);
        print("❌ Error: ${errorResponse['error']['message']}");
      }

    final responseData = json.decode(response.body);
    if (responseData['error'] != null) {
      return responseData['error']['message'];
    } else {
        _authenticated = true;
        _token = responseData['idToken'];
        _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _userId = responseData['localId'];
        // Create user in Firestore (like Google sign-in)
        final usersRef = FirebaseFirestore.instance.collection('users');
        final userDoc = await usersRef.doc(_userId).get();
        if (!userDoc.exists) {
          await usersRef.doc(_userId).set({
            'id': _userId,
            'name': name, // No display name from email/password signup
            'email': em,
            'password': pass, // Storing plain password is NOT recommended in production
            'ads': [],
            'notifications': [],
            'reports': [],
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        notifyListeners();

      return 'Signup successful!';
    }

    } catch (err) {
      print("❌ Exception: ${err.toString()}");
      throw err; // Rethrow the error to be handled in the UI
    }
  }

//Possible errors: EMAIL_NOT_FOUND, INVALID_PASSWORD, USER_DISABLED
Future<String> login({required String em, required String pass}) async {
    final url = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDCWaN2gvhvrDdKOsd4Gjvr9ve6_6lG-NI');
    try{
        final response = await http.post(url, body: json.encode({
          'email': em,
          'password': pass,
          'returnSecureToken': true,
        },), headers: {
          'Content-Type': 'application/json',
        },);
        if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
        print("✅ Token = ${decodedResponse['idToken']}");
        print("⏳ Expires In = ${decodedResponse['expiresIn']}");
        print("🆔 Local ID = ${decodedResponse['localId']}");
      } 

    final responseData = json.decode(response.body);
    if (responseData['error'] != null) {
      return responseData['error']['message'];
    } else {
        _authenticated = true;
        _token = responseData['idToken'];
        _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
        _userId = responseData['localId'];
        // Set admin status based on government email
        _isAdmin = em.toLowerCase() == 'government@nashra.com';
        notifyListeners();
      return 'Login successful!';
    }
      
    }
    catch (err) {
      print("❌ Exception: ${err.toString()}");
      throw err; // Rethrow the error to be handled in the UI
    }

}
}