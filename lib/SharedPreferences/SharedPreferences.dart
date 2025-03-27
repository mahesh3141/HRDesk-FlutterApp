import 'package:shared_preferences/shared_preferences.dart';



class MyStaticClass {
  static bool isLoggedIn = false;
  static late  SharedPreferences prefs;
  static void save() async {
     prefs = await SharedPreferences.getInstance();

    // Store the user's name.
    //prefs.setString('name', 'John Doe');

    // Retrieve the user's name.
     //name = prefs.getString('name')!;

    // Print the user's name.
    //print(name);
  }
}