import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' as typed;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'companyCodeScreen.dart';
import 'login_screen.dart';

class WebViewScreen extends StatefulWidget {
  String? site_url;
  String? clr_code;
  String? appbarname;

  WebViewScreen(this.site_url, this.clr_code, this.appbarname, {super.key});

  @override
  _MyWebViewScreenState createState() => _MyWebViewScreenState();
}

class _MyWebViewScreenState extends State<WebViewScreen> {
  bool _isConnected = true;
  late Connectivity _connectivity;
  bool _isLoading = true;
  int? c_code = 0xFFFF8000;
  String? urlvalue;

  //final flutterWebviewPlugin = FlutterWebviewPlugin();
  late InAppWebViewController _webViewController;
  var objShared;

  @override
  void initState() {
    super.initState();
    c_code = int.tryParse("${widget.clr_code}");
    urlvalue = widget.site_url;
    print("color==== $c_code");
    storagePath();
    // _connectivity = Connectivity();
    // _connectivity.onConnectivityChanged.listen(_updateConnectionStatus as void Function(List<ConnectivityResult> event)?);
    // _checkConnection();
  }

  void storagePath() async{
      var status = await Permission.storage.status;
      if(status.isDenied){
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location,
          Permission.storage,
        ].request();
      }
      if(!status.isGranted){
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
      }
  }

  // Future<void> _checkConnection() async {
  //   final result = await _connectivity.checkConnectivity();
  //   _updateConnectionStatus(result as ConnectivityResult);
  // }

  // void _updateConnectionStatus(ConnectivityResult result) {
  //   setState(() {
  //     _isConnected = result != ConnectivityResult.none;
  //   });
  // }

  doLogout() async {
   // objShared = await SharedPreferences.getInstance();
   // objShared.setBool('is_visible', true);
    //await objShared.clear();
    print('Call after close dashboard Screen');
    print('**** is_visible ${objShared.getString('is_visible')}');
    print('**** companycode ${objShared.getString('companycode')}');
    print('**** from2ndscreen ${objShared.getString('from2ndscreen')}');
    print('**** first_time ${objShared.getString('first_time')}');
    print('**** cardno ${objShared.getString('cardno')}');
    print('**** deviceid ${objShared.getString('deviceid')}');

    Navigator.pushNamedAndRemoveUntil(
        context, CompanyCodeScreen() as String, (Route<dynamic> route) => false);
  }

  Future<void> downloadPdfFile(String url, String? suggestedFilename) async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (status.isGranted) {
      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          print('*** file Name ${suggestedFilename}');
          var directory;
          bool dirDownloadExists = true;
          if (Platform.isIOS) {
            directory = await getDownloadsDirectory();
          } else {
            directory = Directory("/storage/emulated/0/Download/");

            // dirDownloadExists = await Directory(directory).exists();
            // if (dirDownloadExists) {
            //   directory = "/storage/emulated/0/Download/";
            // } else {
            //   directory = "/storage/emulated/0/Downloads/";
            // }

            String tempPath = directory.path;
            var filePath = tempPath + '${suggestedFilename}';
            if(! await new File(filePath).exists()){
              print('*** file path ${filePath}');
              typed.Uint8List data = response.bodyBytes;
              print('*** data ${data}');
              final buffer = data.buffer;
              print('*** buffer ${buffer}');
              File file = File(filePath);

              print('*** file ${file}');
               await file.writeAsBytes(
                   buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
              showInSnackBar("PDF downloaded to $filePath");
              print('*** complete write byte');
            }else{
              showInSnackBar("PDF already downloaded at $filePath");
            }

          }
        }
      } catch (e) {
        print("Download error: $e");
        showInSnackBar("Error @ Download PDF");
      }
    } else {
      showInSnackBar("Storage permission denied");
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _performLogout() {
    // Perform logout logic here
    // For example, navigate to the login screen

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
               // doLogout();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                print('Close the app****');
                exit(0);
                //Navigator.of(context).pop();
                // Implement your logout logic here
                // For example, you can clear user session or navigate to the login screen.
                // After logging out, you should close the dialog and navigate as needed.
               // Navigator.pop(context); // Close the dialog

                // Implement your logout logic here
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
          appBar: AppBar(
            title: Text('${widget.appbarname}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _performLogout,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Container(
              child: Column(
                children: [
                  Container(
                    child: const Text(
                      "Please your internet connection !",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Container(
                      child: const Icon(
                        Icons.signal_wifi_connected_no_internet_4,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Container(
                      child: const Text(
                        "Connection may not be available or slow",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  /*   Container(
               child: Icon(Icons.arrow_circle_down_sharp,color: Colors.red,),
             ),*/
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 30.0),
                  //   child: Center(
                  //     child: ElevatedButton(
                  //       onPressed: _checkConnection,
                  //       child: const Text('Reload'),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ));
    } else {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('${widget.appbarname}'),
          centerTitle: true,
          backgroundColor: Color(c_code!),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _performLogout,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: Stack(
            children: <Widget>[
              /*WebView(

              initialUrl: '${widget.site_url}', // Replace with your desired URL
              javascriptMode: JavascriptMode.unrestricted,
              javascriptChannels: <JavascriptChannel>{
                _createLogoutChannel(context),
              },
               onPageFinished: (url) {
                 setState(() {
                   _isLoading = false;
                 });
               },
               https://stackoverflow.com/questions/57937664/flutter-how-to-download-files-in-webview
            )*/
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(urlvalue!)),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onDownloadStartRequest: (controller, request) async {
                  print('*** Download pdf start :-${request.url}');
                  print(
                      '*** Download file name :-${request.suggestedFilename}');
                  await downloadPdfFile(
                      request.url.toString(), request.suggestedFilename);
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isLoading = false;
                  });
                },
                onGeolocationPermissionsShowPrompt:
                    (_webViewController, origin) async {
                  // Grant geolocation permissions
                  return GeolocationPermissionShowPromptResponse(
                    origin: origin,
                    allow: true,
                    retain: true,
                  );
                },
              ),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
            ],
          ),
        ),
      );
    }
  }

  /*JavascriptChannel _createLogoutChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'logoutChannel',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message == 'logout') {
          // Perform logout logic here
          // For example, navigate to the login screen
          Navigator.pop(context);
        }
      },
    );
  }*/

  getlink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("is_visible", true);
    String? link = prefs.getString("site_url");
    print("Link====$link");
    return link;
  }
}
