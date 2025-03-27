import 'package:flutter/material.dart';

// Make sure this line is present

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class CompanyCodeScreen extends StatefulWidget {
  static const String id = 'companycode_screen';

  const CompanyCodeScreen({super.key});

  @override
  _CompanyCodeScreenState createState() => _CompanyCodeScreenState();
}

class _CompanyCodeScreenState extends State<CompanyCodeScreen> {
  Color textColor = const Color.fromRGBO(255, 139, 0, 1);
  final TextEditingController _textEditingController = TextEditingController();

  var companycode = "DEMO";
  bool isLoading = false;
  String? message = "";
  List<String> dropdownItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your splash screen layout here
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Container(
                            alignment: Alignment.topCenter,
                            child: const Text(
                              "HRDESK",
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 30.0),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Center(
                  child: SizedBox(
                    width: 500.0,
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 300.0,
                      height: 300,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Container(
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      Center(
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text(""),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 300.0,
                          child: TextField(
                            controller: _textEditingController,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              companycode = value;
                              print("The value entered is : $value");
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                // Adjust the radius value as needed
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Company Code',
                              contentPadding: const EdgeInsets.fromLTRB(
                                  30,
                                  12,
                                  12,
                                  20), // Adjust this value to center the hint vertically
                              // Adjust this value to center the hint vertically
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _checkTextField();
                        },
                        child: Container(
                          width: 250,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius value as needed
                          ),
                          child: const Center(
                            child: Text(
                              'GO',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> Login() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("https://www.hrdesk.live/" "crons/parent_db.php");
    print("*** Url== $url");

    var headers = {
      'Content-Type': 'multipart/form-data', //application/json
    };
    var request = http.MultipartRequest('POST', (url));
    request.fields['compcode'] = companycode;
    request.headers.addAll(headers);
    var response = await request.send();

    print("*** Response== $response");
    //  if (kDebugMode) {
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      print('*** Response data: $responseString');
      var jsonResponse = json.decode(responseString);

      var status = jsonResponse['status'];
      print('***Status:===== $status');
      Map<String, dynamic> responseMap = json.decode(responseString);

      if (status == "true") {
        showInSnackBar("Verified Successfully");
        var webservicePath = jsonResponse['webservice_path'];
        print('***Webservice Path:===== $webservicePath');
        dropdownItems =
            List<String>.from(responseMap['year'].map((year) => '"$year"'));
        saveData(webservicePath, status, dropdownItems);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );

        print('successful:');
      } else {
        showInSnackBar("Invalid Code");
      }
    } else {
      showInSnackBar("Somthing Went Wrong");
    }
    //  }
  }

  Future<void> saveData(
      var webservicePath, var status, List<String> dropdownItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('webservicePath', webservicePath!);
    prefs.setString('companycode', companycode);
    prefs.setStringList('year_list', dropdownItems);
    //prefs.setString('firstAttempt', "False");
  }

  showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _checkTextField() {
    String text = _textEditingController.text.trim();

    if (text.isEmpty) {
      // The TextField is blank (empty)
      // You can perform your desired action here
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Blank TextField'),
            content: const Text('The TextField is empty.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Login();
      // The TextField has some text
      // You can handle this case as needed
    }
  }
}
