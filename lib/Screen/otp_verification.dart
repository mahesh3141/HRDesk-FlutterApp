import 'dart:async';

import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Add your login screen logic here
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  Color yellow = const Color.fromRGBO(255, 139, 0, 1);
  Color grayColor = const Color.fromRGBO(211, 211, 211, 211);
  int _timerDuration = 60;
  late Timer _timer;

  @override
  void initState() {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your login screen layout here
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: Container(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, left: 30.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: const Text(
                            "OTP Verification",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 30.0),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: const Text(
                            "Enter the 4-digit code,",
                            style:
                                TextStyle(color: Colors.black, fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: const Text(
                            "we texted to +xx xxxxx xxx63",
                            style:
                                TextStyle(color: Colors.black, fontSize: 20.0),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 50.0),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < _controllers.length; i++)
                                  Container(
                                    width: 50, // Adjust the width as needed
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: TextField(
                                      controller: _controllers[i],
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: SizedBox(
                                width: 200,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Center(
                                        child: Text(
                                      "Resend Code in",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    )),
                                    Text(
                                      " 00: $_timerDuration",
                                      style: TextStyle(
                                          color: yellow,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Container(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize: const Size(300,
                                        50), // Set the background color here
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Verify",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ),
                              ),
                            ),
                          ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 200,
                          height: 50,
                          child: Row(
                            children: [
                              const Center(
                                  child: Text(
                                "Didn’t received code?",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              )),
                              Text(
                                " Resend",
                                style: TextStyle(
                                    color: yellow, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerDuration > 0) {
          _timerDuration--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }
}
