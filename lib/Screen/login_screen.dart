import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_imei/device_imei.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'dashboard_Screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({super.key});

  //final  bool  is_visible;

  //LoginScreen(this.is_visible);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  // Add your login screen logic here
  bool isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Color grayColor = const Color.fromRGBO(211, 211, 211, 211);
  String latitude = 'Unknown';
  String longitude = 'Unknown';
  String? _id;
  String isReason = "0";
  String? isCheckIn;
  String? checkInTime;
  late SharedPreferences prefs;
  final String _platformVersion = 'Unknown';
  String? deviceImei;
  String? type;
  String message = "Please allow permission request!";
  late DeviceInfoPlugin deviceInfo;
  bool getPermission = false;
  bool isloading = false;
  final _deviceImeiPlugin = DeviceImei();

  String? is_visible;
  String? savedCardNo;
  List<String>?
      years; //= List.generate(20, (index) => DateTime.now().year - index);
  String? selectedYear; //DateTime.now().year;

  String? password, username, comapnycode, date, time, name, reasonData;

  String? cardno ,empName;

  final TextEditingController _Username = TextEditingController();

  final TextEditingController _Password = TextEditingController();

  final TextEditingController _Year = TextEditingController();

  final reasonTextField = TextEditingController();

  bool _obscureText = true;

  Timer? _timer;
  int? intValue = 0;

  ConnectivityResult? _connectionStatus;

  String? clr_code;
  String? appbarname;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    datetime();
    shared();
    _getLocation();
    _setPlatformType();

    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _connectionStatus = result as ConnectivityResult;
      });

      // Check if the internet connection is restored
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        showInSnackBar("Internet Connected");
        // Internet connection is available again, you can perform actions here.
        if (intValue == 0) {
        } else {
          _startTimer(intValue!);
        }
      }
    });

    // Get the initial connectivity state
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _connectionStatus = result as ConnectivityResult?;
      });
    });

    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
      super.dispose();
    }


  }

  void _startTimer(int time) {
    // Start the timer to make API calls every 4 minutes
    print("*** lat long ==== $latitude " "$longitude");
    if (time > 0) {
      _timer = Timer.periodic(Duration(minutes: time), (Timer timer) async {
        if (latitude == "Unknown" || longitude == "Unknown") {
          showInSnackBar("GPS Error Try After Sometime");

          // checkINcheckOUT(1);
        } else {
          datetime();

          bool isConnected = await checkInternetConnection();
          if (isConnected) {
            checkINcheckOUT(0);
          } else {
            showInSnackBar("No Internet Connection");
          }
        }
      });
    } else {
      print("******NO DATA*******");
    }
  }

  void _stopTimer() {
    // Stop the timer
    _timer?.cancel();
  }

  datetime() {
    DateTime now = DateTime.now();
    date = "${now.year}-${now.month}-${now.day}";
    time = " ${now.hour}:${now.minute}:${now.second}";
    print("*** Date====$date");
    print("*** time====$time");
  }



  void shared() async {
    prefs = await SharedPreferences.getInstance();
    bool? checkVisible = prefs.getBool("is_visible");
    if (checkVisible != null && checkVisible) {
      is_visible = "true";
    } else {
      is_visible = "false";
    }
    if (prefs.getString('isCheckIn') != null) {
      isCheckIn = prefs.getString('isCheckIn');
    }
    if (prefs.getString('checkInTime') != null) {
      checkInTime = prefs.getString('checkInTime');
    } else {
      print('**** isCheckInTime ${prefs.getString('checkInTime')}');
    }
    if(prefs.getString('isReason')!=null) {
      isReason = prefs.getString('isReason')!;
    }
    comapnycode = prefs.getString("companycode");
    empName = prefs.getString('empName') != null ? prefs.getString('empName'):"";
    name = prefs.getString("User_Name");
    years = prefs.getStringList("year_list");
    selectedYear = years![0];
    //name ??= "";
    print("is_visible===$is_visible");
    savedCardNo = prefs.getString('cardno');
    print("**** cardNo :- $savedCardNo");

    setState(() {
      if(prefs.getString('userName')!=null && prefs.getString('passwords')!=null) {
        username = prefs.getString('userName');
        password = prefs.getString('passwords');
      }
    });
  }



  _setPlatformType() {
    if (Platform.isAndroid) {
      setState(() {
        type = 'Android';
      });
    } else if (Platform.isIOS) {
      setState(() {
        type = 'iOS';
      });
    } else {
      setState(() {
        type = 'other';
      });
    }
  }



  _getLocation() async {
    final permissionStatus = await Permission.storage.status;
    if(!permissionStatus.isGranted) {
      // Do stuff that require permission here
      Map<Permission,PermissionStatus> pStatus = await[
        Permission.storage,Permission.camera
      ].request();
    }
    if (permissionStatus.isDenied) {
      // Here just ask for the permission for the first time
      await Permission.storage.request();

      // I noticed that sometimes popup won't show after user press deny
      // so I do the check once again but now go straight to appSettings
      if (!permissionStatus.isGranted) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
      }
    } else if (!permissionStatus.isGranted) {
      // Here open app settings for user to manually enable permission in case
      // where permission was permanently denied
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        latitude = '${position.latitude}';
        longitude = '${position.longitude}';
        print("*** lat long ======== $latitude $longitude");
      });
    } else {
      var status = await Permission.location.request();
      if (status.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          latitude = '${position.latitude}';
          longitude = '${position.longitude}';
          print("======== $latitude $longitude");
        });
        // Permission granted, get location
      } else {
        // Handle permission denied
      }
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    String displayedYear = selectedYear?.replaceAll('"', '') ?? "";
    return WillPopScope(
      onWillPop: () async {
        // Handle the back button press here
        // You can show a confirmation dialog or directly exit the app.
        // To exit the app, you can use the `SystemNavigator` class.

        // Example: Show a confirmation dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit App?'),
              content: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Pop the dialog
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Pop the dialog
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ).then((exitConfirmed) {
          if (exitConfirmed == true) {
            // Exit the app
            //Navigator.of(context).pop(true);
            exit(0);
          }
        });

        return false; // Prevents the app from navigating back
      },
      child: Scaffold(
        // Customize your login screen layout here
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, left: 30.0),
                          child: Container(
                              alignment: Alignment.topCenter,
                              child: const Text(
                                "Welcome ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 25.0),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 5.0),
                          child: Container(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "$empName",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 24.0),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                          child: Container(
                            alignment: Alignment.topCenter,
                            child: const Text(
                              "Company Code",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 12.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Container(
                            alignment: Alignment.topCenter,
                            width: 200.0,
                            child: TextField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      20), // Adjust the radius value as needed
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                ),
                                hintText: comapnycode,
                                hintStyle: const TextStyle(color: Colors.black),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal:
                                        70.0), // Adjust this value to center the hint vertically
                              ),
                            ),
                          ),
                        ),

                          (isReason == "1")
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, left: 20.0, right: 20.0),
                                  child: TextField(
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 5,
                                    textAlign: TextAlign.left,
                                    onChanged: (value) {
                                      reasonData = value;
                                    },
                                    controller: reasonTextField,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            20), // Adjust the radius value as needed
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      hintText:
                                          'Enter reason up to 60 characters...',
                                      // contentPadding: const EdgeInsets
                                      //     .symmetric(
                                      //     horizontal:
                                      //     200.0), // Adjust this value to center the hint vertically
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        //check in / checkout button
                      if (is_visible == "true")
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  // Check In button logic
                                  if (latitude == "Unknown" ||
                                      longitude == "Unknown") {
                                    showInSnackBar(
                                        "GPS Error Try After Sometime");

                                    // checkINcheckOUT(1);
                                  } else {
                                    starttime();
                                    print('**** reasonData ${reasonData}');
                                    if(isReason=="1" && reasonData==null) {
                                      showInSnackBar("Please enter the reason");
                                    } else {
                                      checkchecinout(1);
                                    }
                                  }
                                },
                                icon: const Icon(Icons.login),
                                label: const Text('Check In'),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  // Check Out button logic

                                  _stopTimer();
                                  if (latitude == "Unknown" ||
                                      longitude == "Unknown") {
                                    showInSnackBar(
                                        "GPS Error Try After Sometime");

                                    // checkINcheckOUT(1);
                                  } else {
                                    if(isReason=="1" && reasonData==null){
                                      showInSnackBar("Please enter the reason");
                                    } else {
                                      checkchecinout(2);
                                    }
                                  }

                                  // checkINcheckOUT(2);
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Check Out'),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, top: 40.0),
                          child: Container(
                              alignment: Alignment.topLeft,
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 30.0),
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        "Username",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: SizedBox(
                                    width: 300.0,
                                    child: TextField(
                                      controller: _usernameController,
                                      onChanged: (value) {
                                        username = value;
                                      },
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          // Adjust the radius value as needed
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                        ),
                                        hintText: 'Username',
                                        contentPadding: const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                                100.0), // Adjust this value to center the hint vertically
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30.0, top: 20.0),
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        "Password",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                const SizedBox(
                                  height: 10,
                                  width: 200.0,
                                ),
                                SizedBox(
                                  width: 300.0,
                                  child: TextField(
                                    controller: _Password,
                                    textAlign: TextAlign.center,
                                    obscureText: _obscureText,
                                    onChanged: (value) {
                                      password = value;
                                    },
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          // Adjust the radius value as needed
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                        ),
                                        hintText: 'Password',
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                60, 12, 12, 20),
                                        // Adjust this value to center the hint vertically
                                        suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureText
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureText = !_obscureText;
                                              });
                                            })),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30.0, top: 20.0),
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        "Leave year",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      //decoration: InputDecoration(labelText: 'Select a Year'),
                                      readOnly: true,
                                      controller: TextEditingController(
                                          text: displayedYear.toString()),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          // Adjust the radius value as needed
                                          borderSide: const BorderSide(
                                              color: Colors.black),
                                        ),
                                        hintText: 'Select a Year',
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                20, 12, 12, 20),
                                        // Adjust this value to center the hint vertically
                                        suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                        ),
                                      ),
                                      onTap: () {
                                        // Show the dropdown when the text field is tapped
                                        openYears(years);
                                      },
                                    ),
                                  ),
                                ),

                                /*     Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Container(
                                      child:Text("Forgot Password?",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),) ,
                                    ),
                                  ),*/
                                Padding(
                                  padding: const EdgeInsets.only(top: 30.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      update();
                                      _checkTextField();
                                      login();

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
                                          'Login In',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ])),
                        ),
                        const SizedBox(height: 20.0),
                        Center(
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text(""),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void update() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('first_time', false);
    prefs.setString('firstAttempt', "False");
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Device is connected to the internet.
    } else {
      return false; // Device is not connected to the internet.
    }
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();

    var url =
        Uri.parse("${prefs.getString('webservicePath')}" "/api_login.php");
    print("Url== $url");

    var headers = {
      'Content-Type': 'multipart/form-data', //application/json
    };
    var request = http.MultipartRequest('POST', (url));
    request.headers.addAll(headers);
    request.fields['username'] = username!;
    request.fields['password'] = password!;
    request.fields['leave_year'] = "$selectedYear";
    request.fields['imei'] = prefs.getString('deviceId')!;

    //print("IEMI LOG===$_id");
    print("Url Request===${request.fields}");

    var response = await request.send();

    // print("Url== ${response}");
    print("Url StatusCode== ${response.statusCode}");
    // if (kDebugMode) {
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      print('Url Response data: $responseString');
      var jsonResponse = json.decode(responseString);
      var status = jsonResponse['status'];

      var status1 = jsonResponse['status1'];

      prefs.setString('userName',username!);
      prefs.setString('passwords',password!);

      print('successful:');
      //Navigator.pushReplacementNamed(context, '/home');
      if (status1 == "true") {
        if (status == "true") {
          cardno = jsonResponse['cardno'];
          empName = jsonResponse['empname'];
          print('cardno:===== $cardno');
          prefs.setString('cardno', cardno!);
          prefs.setString('empName', empName!);
        }

        var imeiStatus = jsonResponse['imei_status'];
        var siteUrl = jsonResponse['site_url'];
        var timer = jsonResponse['get_loc_min'];

        clr_code = jsonResponse['clr_code'];
        appbarname = jsonResponse['app_name'];

        intValue = int.tryParse(timer);
        _startTimer(intValue!);

        print('Status:===== $imeiStatus');

        showInSnackBar("Login Successfully");
        print("***start loading webView ");
        saveData(cardno, siteUrl, intValue!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(siteUrl, clr_code, appbarname),
          ),
        );
      } else {
        showInSnackBar("Invalid User");
      }
    }
    // }
  }



  Future<void> saveData(var cardno, var siteUrl, int timmer) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("deviceid", "$_id");
    prefs.setInt("timmer", intValue!);
    prefs.setBool("is_visible", true);
    prefs.setString('cardno', cardno);
    // MyStaticClass.prefs = await SharedPreferences.getInstance();
    // if (prefs.getString('from2ndscreen') == "true") {
    //   prefs.setString('cardno', cardno!);
    //   print("Cardno=== ${prefs.getString("cardno")}");
    // }
    prefs.setString('site_url', siteUrl!);
    prefs.setString('clr_code', clr_code!);

   // print("is_visible :=> ${prefs.getString('is_visible')}");
    //prefs.setBool('first_time', false);
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

  Future<void> checkINcheckOUT(int status) async {
    datetime();
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    DateTime now = DateTime.now();
    date = "${now.day}-${now.month}-${now.year}";
    time = " ${now.hour}:${now.minute}:${now.second}";

    // final dt = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    // final format = DateFormat.jm(); //"6:00 AM"
    // time = format.format(dt);
    print('*** times ${time}');
    if (status == 1) {
      prefs.setString('isCheckIn', "True");
      prefs.setString('checkInTime', '${date}-${time} ');
    } else {
      prefs.setString('isCheckIn', "False");
    }
    print('**** isCheckIn ${prefs.getString('isCheckIn')}');
    print('**** isCheckInTime ${prefs.getString('checkInTime')}');

    var url =
        Uri.parse("${prefs.getString('webservicePath')}" "/api_check_io.php");
    print("Url== $url");
    print('*** cardNo pref ${prefs.getString('cardno')} ');
    print('*** date $date');
    print('*** time $time! ');

    var headers = {
      'Content-Type': 'multipart/form-data', //application/json
    };
    var request = http.MultipartRequest('POST', (url));

    request.fields['cardno'] = prefs.getString('cardno')!;
    request.fields['chk_in_out'] = "$status";
    request.fields['logs_date'] = "$date";
    request.fields['logs_time'] = time!;
    if(reasonData!=null) {
      request.fields['check_reason'] = reasonData!;
    }
    request.fields['latitude'] = latitude;
    request.fields['longitude'] = longitude;
    request.fields['sea_level'] = "3";
    request.fields['dt_tm_manual'] = "No";
    request.headers.addAll(headers);
    print("Url Request===${request.fields}");

    var response = await request.send();

    print("Url== $response");
    print("Url== ${response.statusCode}");
    //if (kDebugMode) {
    setState(() {
      isLoading = false;
      isCheckIn = prefs.getString('isCheckIn');
      checkInTime = prefs.getString('checkInTime');
    });
    int check = status;
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      print('Response data: $responseString');
      var jsonResponse = json.decode(responseString);
      var statusresponse = jsonResponse['status']; //sql
      if (statusresponse == "true") {
        if (check == 1) {
          showInSnackBar("Check In Successfully");
        } else if (check == 2) {
          showInSnackBar("Check Out Successfully");
        } else {
          showInSnackBar("Location Updated Successfully");
        }
      } else {
        showInSnackBar("$jsonResponse");
      }
      setState(() {
        reasonTextField.clear();
      });
      print('successful:');
    }
  }

  /**
   * Below function is for open the bottom sheet for select the finacial year
   * **/
  openYears(List<String>? years) {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (context) {
          return Container(
            height: 270,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      flex: 4,
                      child: Text('Select Year',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0)),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: new Icon(Icons.clear),
                        highlightColor: Colors.grey,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: BouncingScrollPhysics(),
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var yr in years!)
                                InkWell(
                                  onTap: () {
                                    // Navigator.pushNamed(context, "write your route");
                                    setState(() {
                                      selectedYear = yr;
                                    });

                                    print(
                                        '*** selected year:= ${selectedYear}');
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(7.0),
                                    child: Text(yr.replaceAll(RegExp('"'), ''),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0)),
                                  ),
                                )
                            ])
                      ])
                ],
              ),
            ),
          );
        });
  }

  // Future<void> savenextData(var cardno, var siteUrl) async {
  //   prefs = await SharedPreferences.getInstance();
  //   prefs.setString("deviceid", "$_id");
  //   // MyStaticClass.prefs = await SharedPreferences.getInstance();
  //   prefs.setString('cardno', cardno!);
  //   prefs.setString('site_url', siteUrl!);
  //   print("is_visible okok${prefs.getString('cardno')}");
  // }

  void _checkTextField() {
    String username = _usernameController.text.trim();
    String password = _Password.text.trim();

    if (username.isEmpty || password.isEmpty || selectedYear!.isEmpty) {
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
    }
    // else {
    //   //checklog();
    //   login();
    //   // The TextField has some text
    //   // You can handle this case as needed
    // }
  }

  checklog() async {
    bool isConnected = await checkInternetConnection();

    if (isConnected) {
      login();
    } else {
      showInSnackBar("No Internet Connection");
    }
  }

  checkchecinout(int status) async {
    checkINcheckOUT(status);
  }

  void starttime() async {
    prefs = await SharedPreferences.getInstance();
    int? timevale = prefs.getInt("timmer");
    print("Timmer==== $timevale");
    _startTimer(timevale!);
  }
}
