import 'dart:convert';

import 'package:biometric_login/pages/home.dart';
import 'package:biometric_login/model/login_credential.dart';
import 'package:biometric_login/utils/secure_storage.dart';
import 'package:biometric_login/api/service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LocalAuthentication auth;
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  // String errorMessage = "";

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
  }

  Future<void> showMyDialog(
      BuildContext context, bool rememberMeChecked) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: StatefulBuilder(builder: (context, setState) {
            return Form(
              key: formKey,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Username"),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username can't be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text("Password"),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: !passwordVisible,
                      controller: passwordController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 10),
                          suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                              child: Icon(passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password can't be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CheckboxListTile(
                        title: const Text("Remember me"),
                        value: rememberMeChecked,
                        onChanged: (newValue) {
                          setState(() {
                            rememberMeChecked = newValue!;
                          });
                        }),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    // Text(
                    //   errorMessage,
                    //   style: const TextStyle(color: Colors.red),
                    // )
                  ]),
            );
          }),
          actions: [
            TextButton(
              child: const Text('Login'),
              onPressed: () {
                bool isValid = formKey.currentState!.validate();
                String username = usernameController.text;
                String password = passwordController.text;
                String secretKey = "-"; //TODO: change to env later
                if (isValid) {
                  submitData(
                      username,
                      password,
                      secretKey,
                      generateChecksum(username, password, secretKey),
                      rememberMeChecked);
                }
              },
            ),
          ],
        );
      },
    );
  }

  String generateChecksum(String username, String password, String secretKey) {
    String content =
        "$username | $password | $secretKey"; //TODO: generate env file
    return md5.convert(utf8.encode(content)).toString();
  }

  submitData(String username, String password, String secretKey,
      String checksum, bool rememberMeChecked) async {
    bool isSuccess =
        await Service().postLogin(username, password, secretKey, checksum);

    if (isSuccess) {
      if (rememberMeChecked) {
        SecureStorage()
            .writeLoginCredential(username, password, secretKey, checksum);
      }
      navigateToHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed login"),
        backgroundColor: Colors.red,
      ));
      // setState(() {
      //   errorMessage = "Login failed";
      // });
    }
  }

  Future<void> authenticateBiometrics(LoginCredential? loginCredential) async {
    try {
      bool authenticated = await auth.authenticate(
          localizedReason: "Confirm identity to continue",
          options: const AuthenticationOptions(
              stickyAuth: false, biometricOnly: true));

      if (authenticated) {
        bool isSuccess = await Service().postLogin(
            loginCredential!.username,
            loginCredential.password,
            loginCredential.secretKey,
            loginCredential.checksum);
        if (isSuccess) {
          navigateToHome();
        }
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  navigateToHome() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    bool rememberMeChecked = false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Login")),
      body: FutureBuilder(
          future: SecureStorage().readLoginCredential(),
          builder: (context, widget) {
            if (widget.hasData) {
              authenticateBiometrics(widget.data);
              return Center();
            } else {
              return Center(
                child: FloatingActionButton(
                    child: const Text("Login"),
                    onPressed: () {
                      showMyDialog(context, rememberMeChecked);
                    }),
              );
            }
          }),
    );
  }
}
