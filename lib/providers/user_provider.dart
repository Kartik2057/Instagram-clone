import 'package:flutter/foundation.dart';
import 'package:instagram_flutter/models/user.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();
  User get getUser => _user!;

  //Called by responsive layout and notifies the mobile screen layout provider
  Future<void> refreshUser() async {
    User user = await _authMethods.getCurrentUserDetails();
    _user = user;
    notifyListeners();
  }
}