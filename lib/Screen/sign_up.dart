import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Make sure this line is present

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Add your login screen logic here
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Color grayColor = const Color.fromRGBO(211, 211, 211, 211);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your login screen layout here
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: SvgPicture.asset(
                            'assets/images/cross.svg',
                            width: 25.0,
                            height: 25.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, left: 30.0),
                        child: Container(
                            alignment: Alignment.topLeft,
                            child: const Text(
                              "Hello! Register to",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 25.0),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Container(
                            alignment: Alignment.topLeft,
                            child: const Text(
                              "get started",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 25.0),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 30.0),
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
                                    textAlign: TextAlign.start,
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      border: const OutlineInputBorder(),
                                      filled: true, // Fill the background color
                                      fillColor: grayColor,
                                      // contentPadding: EdgeInsets.symmetric(vertical: 15),
                                      isCollapsed: false,
                                      alignLabelWithHint: true,
                                      // contentPadding: EdgeInsets.symmetric(vertical: 15), // Set the height
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, top: 10.0),
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Email",
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
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      border: const OutlineInputBorder(),
                                      filled: true, // Fill the background color
                                      fillColor: grayColor,
                                      // contentPadding: EdgeInsets.symmetric(vertical: 15), // Set the height
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, top: 10.0),
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Mobile no",
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
                                    decoration: InputDecoration(
                                      labelText: 'Mobile no',
                                      border: const OutlineInputBorder(),
                                      filled: true, // Fill the background color
                                      fillColor: grayColor,
                                      // contentPadding: EdgeInsets.symmetric(vertical: 15), // Set the height
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
                                  controller: _passwordController,
                                  obscureText: true, // Hide password characters
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: const OutlineInputBorder(),
                                    filled: true, // Fill the background color
                                    fillColor: grayColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0, top: 20.0),
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      "Confirm Password",
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
                                  controller: _passwordController,
                                  obscureText: true, // Hide password characters
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    border: const OutlineInputBorder(),
                                    filled: true, // Fill the background color
                                    fillColor: grayColor,
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
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/otp');
                                    },
                                    child: const Text(
                                      "Sign in",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18.0),
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
