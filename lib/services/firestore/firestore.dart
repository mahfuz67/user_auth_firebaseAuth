import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_signin/model/user.model.dart';

class FireStoreServices {
  Future<void> insertUser(UserA user) async{
    try{
     bool insertIsSuccess = false;
      FirebaseFirestore firestore= FirebaseFirestore.instance;
      firestore.collection('users').add(user.toJson()).whenComplete(() => insertIsSuccess == true);
    }catch(e){
      print(e);
    }
  }

  Future<bool> checkIfEmailExist(String email) async{
    print(email);
      CollectionReference _collectionRef = FirebaseFirestore.instance.collection('users');
      QuerySnapshot querySnapshot = await _collectionRef.get();
      final allMails =
      querySnapshot.docs.map((doc) => doc.get('email')).toList();
      print(allMails);
      bool emailExist = allMails.contains(email);
      return emailExist;
  }


}