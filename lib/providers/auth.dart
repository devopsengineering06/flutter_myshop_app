import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  /* 
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │   Properties                                                                │
  └─────────────────────────────────────────────────────────────────────────────┘
 */
  String? _userId;
  String? _token;
  DateTime? _expiryDate;
  Timer? _authTimer;

  /* 
  ┌─────────────────────────────────────────────────────────────────────────────┐
  │   Getters                                                                   │
  └─────────────────────────────────────────────────────────────────────────────┘
 */
  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  bool get isAuth {
    return token != null;
  }

  /* 
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ Authenticate                                                            │
  └─────────────────────────────────────────────────────────────────────────┘
 */
  Future<void> _authenticate(
      String? email, String? password, String? urlSegment) async {
    String authId = 'AIzaSyCiAX461bCWh0qTCDHLz9G9Kph91Vzncgo';

    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$authId');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      //  print(json.decode(response.body));
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _userId = responseData['localId'];
      _token = responseData['idToken'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      // print(_expiryDate);
      _autoLogout();
      notifyListeners();
      keepLoggedIn();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  /* 
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ Keep Logged In                                                          │
  └─────────────────────────────────────────────────────────────────────────┘
 */
  Future<void> keepLoggedIn() async {
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), tryAutoLogin);
  }

  /* 
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ Try Auto Login                                                          │
  └─────────────────────────────────────────────────────────────────────────┘
 */
  Future<bool> tryAutoLogin() async {
    // GET DATA FROM SHARED PREFERENCES
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiry']);

    // IF EXPIRED
    if (expiryDate.isBefore(DateTime.now())) {
      return refreshToken();
    }

    // IF NOT EXPIRED
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    return true;
  }

  /* 
  ┌───────────────────────────────────────────────────────────────────────────┐
  │ Refresh Token                                                             │
  └───────────────────────────────────────────────────────────────────────────┘
 */
  Future<bool> refreshToken() async {
    String authId = 'AIzaSyCiAX461bCWh0qTCDHLz9G9Kph91Vzncgo';
    // POST HTTP REQUEST
    final url =
        Uri.parse('https://securetoken.googleapis.com/v1/token?key=$authId');

    final prefs = await SharedPreferences.getInstance();
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, Object>;

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'grant_type': 'refresh_token',
            'refresh_token': extractedUserData['refreshToken'],
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return false;
      }
      _token = responseData['id_token'];
      _userId = responseData['user_id'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expires_in'],
          ),
        ),
      );
      notifyListeners();

      // STORE DATA IN SHARED PREFERENCES
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);

      keepLoggedIn();
      return true;
    } catch (error) {
      return false;
    }
  }

  /* 
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ Logout                                                                  │
  └─────────────────────────────────────────────────────────────────────────┘
 */
  Future<void> logout() async {
    _userId = null;
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
