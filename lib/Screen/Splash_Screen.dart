import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'companyCodeScreen.dart';
import 'login_screen.dart'; // Make sure this line is present
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool? status;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // String?message="Finish";
  List<String> dropdownItems = [];
  var companycode;
  // late SharedPreferences prefs;
  bool showSpinner = false;
  var objShared;
  var deviceid;

  @override
  void initState()  {
    super.initState();
    getDeviceInfo();
  }

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('www.hrdesk.live');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void getDeviceInfo() async{
    bool isOnline = await hasNetwork();
    if(isOnline){
      objShared = await SharedPreferences.getInstance();
      String? deviceId = await _getId();
      if(deviceId!=null){
        companycode = objShared.getString('companycode');
        print('*** companycode ${companycode}');
        print('**** cardno from shared ${objShared.getString('cardno')}');
        objShared.setString('deviceId',deviceId);
        if(objShared.getString('firstAttempt')==null){
          objShared.setString('firstAttempt',"True");
        }
        if(companycode == null || companycode == ''){
         startTime();
        }else {
          if(objShared.getString('cardno')==null){
            showInSnackBar("Your account is not activated yet wait for admin approval");
            Navigator.pushNamed(context, LoginScreen.id);
          }else {
            callParentDB(deviceId);
          }
        }
      }
    }else{
      showInSnackBar("Please check your internet or wifi connection..");
    }

  }

  startTime() async {
    var duration = new Duration(seconds: 5);
    return new Timer(duration, navigation);
  }

  void navigation() {
    if (objShared.getString('firstAttempt')== "True") {
      Navigator.pushNamed(context, CompanyCodeScreen.id);
    } else {
      Navigator.pushNamed(context, LoginScreen.id);
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return AndroidId().getId(); // unique ID on Android
    }
  }

  Future<void> callParentDB(String? deviceId) async {
    setState(() {
      isLoading = true;
    });
    print('*** device Id $deviceId');
    var basePath = objShared.getString('webservicePath');
    var url = Uri.parse("${basePath}" "/api_splash.php");
    print("****splash Url== $url");

    var headers = {
      'Content-Type': 'multipart/form-data', //application/json
    };
    var request = http.MultipartRequest('POST', (url));
    request.fields['cardno'] = objShared.getString('cardno');
    request.fields['deviceid'] = objShared.getString('deviceId');
    request.headers.addAll(headers);
    var response = await request.send();
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      print('*** Response data: $responseString');
      var jsonResponse = json.decode(responseString);
      var status = jsonResponse['status'];
      if(status=="false"){
        objShared.setBool('is_visible',false);
      }else{
        objShared.setBool('is_visible',true);
      }
      Map<String, dynamic> responseMap = json.decode(responseString);

      dropdownItems =
          List<String>.from(responseMap['year'].map((year) => '"$year"'));
      objShared.setStringList('year_list', dropdownItems);
      var isReason = jsonResponse['is_reason'];
      objShared.setString('isReason',isReason);
      objShared.setString('empName',jsonResponse['name']);
      //var webservicePath = jsonResponse['webservice_path'];
      //objShared.setString('webservicePath', webservicePath);
      startTime();
    }else{
      showInSnackBar("Calling to api fail..");
      SystemNavigator.pop();
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
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

  /*Future<void> Login() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    var url = Uri.parse( "https://www.hrdesk.live/" "crons/parent_db.php");
    print("Url== $url");

    var headers = {
      'Content-Type': 'multipart/form-data', //application/json
    };
    var request = http.MultipartRequest('POST', (url));
    if(prefs.getString('companycode')!=null) {
      request.fields['compcode'] = "${prefs.getString('companycode')}";
    }else{
      request.fields['compcode'] ='1002';
    }
    request.headers.addAll(headers);
    var response = await request.send();
    print("***Url first  Request===${request.fields}");

    print("***Url== $response");

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

        dropdownItems = List<String>.from(responseMap['year'].map((year) => '"$year"'));
        prefs.setStringList('year_list',dropdownItems );//status!
       // saveData(webservicePath, status);
      var webservicePath = jsonResponse['webservice_path'];
      print('*** Webservice Path:===== $webservicePath');
      if(webservicePath!=null) {
        prefs.setString('webservicePath', webservicePath!);
      }
        print('successful:');
      getstaus(prefs);
    }else{
      showToast("Somthing Went Wrong");
    }

  }

  Future<void> getstaus(SharedPreferences prefs) async {
    print("Is====$isLoading");
    setState(() {
      isLoading = true;
    });

    String? webservicePath = prefs.getString('webservicePath');
    //String defaulturl = webservicePath ?? 'https://example.com/defaultWebService';
    late Uri url;

    if (webservicePath != null) {

       url = Uri.parse( "${prefs.getString('webservicePath')}""/api_splash.php" );  //"https://www.hrdesk.live" +
    }
    print("Splash_Url== $url");

    var headers = {
      'Content-Type': 'multipart/form-data', //application/json
    };
    var request = http.MultipartRequest('POST', (url));
    request.headers.addAll(headers);
    request.fields['cardno'] = prefs.getString('cardno')??"0";
    request.fields['deviceid'] = prefs.getString('deviceid')??"0";
    request.fields['compcode'] = "${prefs.getString('companycode')}";

    var response = await request.send();
    print("Url splash  Request===${request.fields}");

      if (response.statusCode == 200) {
        close();
        var responseString = await response.stream.bytesToString();
        print('Splash Response data: $responseString');
        var jsonResponse = json.decode(responseString);
        print('jsonResponse data: $jsonResponse');

        var name = jsonResponse['name'];
        var status = jsonResponse['status'];
        var compcode = jsonResponse['compcode'];

        print('**** status $status');
        print('**** !status $status! ');
        print('dropdownItems:===== $dropdownItems');
        print('*** Splash Status become is_visible on SP:===== $status');
        print('**** not status ${status!}');
        print('name:===== $name');

       // saveData(name, status,compcode);
        prefs.setString('is_visible',status! ); //
        prefs.setString('User_Name',name! );
        prefs.setString('companycode', compcode);
        prefs.setBool('first_time', true);
        print('successful:');
        getdata(prefs);
      }else{
        print('No code');

      }

  }

  void getdata(SharedPreferences prefs) async{
    //prefs = await SharedPreferences.getInstance();
    status = prefs.getBool('first_time');

    print("*** Splash firstTime status ==${prefs.getBool('first_time')}");

    print("first_time ==$status");

    Future.delayed(const Duration(seconds: 3), () {
      if(status==true ){
        prefs.setBool('first_time', false);
        Navigator.pushReplacementNamed(context, '/companyCodeScreen');

      }else{
        prefs.setString("from2ndscreen", "false");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );

      }

    });
  }


  Future<void> saveData(var name,var status,var compcode) async {
    prefs = await SharedPreferences.getInstance();


    // MyStaticClass.prefs = await SharedPreferences.getInstance();
    prefs.setString('is_visible',status! ); //
    prefs.setString('User_Name',name! );
    prefs.setString('companycode', compcode);
    print("is_visible okok${prefs.getString('is_visible')}");

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

  void close() {
    setState(() {
      isLoading =false;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your splash screen layout here
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              //color: Colors.white,
              child: Image.asset(
                'assets/images/splashnew2.png',
                //width: 150,

                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Container(child: const Text("")),
            ),
          ],
        ),
      ),
    );
  }
}
