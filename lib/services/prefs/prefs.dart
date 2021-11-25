
import 'package:shared_preferences/shared_preferences.dart';

class SharedServices {

  static Future<void> saveBooks(String book) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("books", book);
  }
  static Future<String> getBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("books") ?? '';
  }

}
