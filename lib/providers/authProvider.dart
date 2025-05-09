import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
    String _token = '';
    DateTime _expiryDate = DateTime.utc(1970); // Set to a date in the past to indicate no token is available as a default value
    String _userId = '';
    bool _authenticated = false;

//this is used to check if the user is authenticated or not
    bool isAuthenticated() {
        return _authenticated;
    }

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

    //log out
    void logout(){
        _authenticated = false;
        _expiryDate = DateTime.now();
    }
 
//possible errors: EMAIL_EXISTS, OPERATION_NOT_ALLOWED, TOO_MANY_ATTEMPTS_TRY_LATER, EMAIL_NOT_FOUND, INVALID_PASSWORD, USER_DISABLED, WEAK_PASSWORD, INVALID_EMAIL
//error can be found in the response body of the request in the message
//its not caught in the try catch block, so we can handle it in the UI
//this is because the request is not failing, but the response is an error (not a server error)
//can use json.decode(response.body)['error']['message'] to get the error message, but we need to check if the response is an error first
//this is because if there is no error, the response body will not have the error key and this will throw an error


//GOAL: SUCCES/FAILURE MESSAGE TO UI

  Future<String> signup({required String em, required String pass}) async {
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
      return 'Login successful!';
    }
      
    }
    catch (err) {
      print("❌ Exception: ${err.toString()}");
      throw err; // Rethrow the error to be handled in the UI
    }

}
}