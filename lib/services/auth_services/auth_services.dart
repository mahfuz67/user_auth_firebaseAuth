import 'package:firebase_auth/firebase_auth.dart';
import 'package:signup_signin/model/user.model.dart';

class AuthServices {
  String? errorText;
  bool isLoading = false;
  Future<User?> signupWithEmailAndPassword(UserA userr) async {
    try{
      FirebaseAuth  _auth = FirebaseAuth.instance;
      isLoading = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: userr.email, password: userr.password);
      User? user =  userCredential.user;
      if(user != null) {
          isLoading = false;
        return user;
      }else {
        return null;
      }
    }on FirebaseAuthException catch(e) {
      errorText = e.code;
    }catch(e){
      print(e.toString());
    }

  }

  Future<User?> loginWithEmailAndPassword(UserA userr) async{
    try{
      FirebaseAuth  _auth = FirebaseAuth.instance;
      isLoading = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: userr.email, password: userr.password);
      User? user =  userCredential.user;
      if(user != null) {
          isLoading = false;
        return user;
      }else {
        return null;
      }
    }on FirebaseAuthException catch(e) {
      errorText = e.code;
    }catch(e){
      print(e.toString());
    }
  }
}
