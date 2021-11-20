

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signup_signin/changenotifiers/signinnotifiers.dart';

class Providers {
  static final signInProvider = ChangeNotifierProvider((ref)=> SignInNotifiers());
}