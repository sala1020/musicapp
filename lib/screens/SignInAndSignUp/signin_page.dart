// ignore_for_file: use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/main.dart';
import 'package:musicapp/screens/AdminScreen/bottomnavigation/bottom_navigation.dart';
import 'package:musicapp/screens/refactoring/bottom_navigation.dart';
import 'package:musicapp/screens/refactoring/sign_page.dart';
import 'package:musicapp/screens/SignInAndSignUp/singup_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  BoxShadow shadow = const BoxShadow(
    color: Color.fromARGB(3, 255, 255, 255),
    blurRadius: 80,
    offset: Offset(0, 0),
    spreadRadius: 5,
  );
  String email = '';
  String password = '';

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: SizedBox(
            height: 800,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: pageHeading(
                            head1: 'Sign IN',
                            head2: 'Enjoy The Magic Of Sound',
                            font1: 'Seymour One',
                            font2: 'Pacifico'),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Opacity(
                              opacity: 0.4,
                              child: Image.asset(
                                'Assets/musichead1.jpg',
                                height: 120,
                                width: 150,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      opacity: 0.5,
                      image: AssetImage('Assets/SigninBack.png'),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(45.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          textField(
                              keyboardtype: TextInputType.emailAddress,
                              label: 'Email Address',
                              controller: emailcontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter the Email Address';
                                } else if (!RegExp(
                                        r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                    .hasMatch(value)) {
                                  return 'Please Enter a Valid Email Address';
                                } else {
                                  return null;
                                }
                              },
                              onchanged: (value) {
                                setState(() {
                                  email = value!;
                                });

                                return null;
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          textField(
                              obscureText: true,
                              label: 'Password',
                              controller: passwordcontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter The Password';
                                } else {
                                  return null;
                                }
                              },
                              onchanged: (value) {
                                setState(() {
                                  password = value!;
                                });

                                return null;
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              print('object');
                              if (_formKey.currentState!.validate()) {
                                signin(emailcontroller, passwordcontroller);
                              }
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(120, 50)),
                            ),
                            child: Text(
                              'SIGN IN',
                              style: GoogleFonts.rowdies(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          suggest(
                              ctx: context,
                              firsttext: "Dont't Have An Account?",
                              linktext: " CREATE ONE.",
                              page: () => const SignUpPage())
                        ],
                      ),
                    ),
                  ),
                ),
                bottomHead(
                    head1: 'SALUZZY',
                    head2: "THE KEEPER OF SOUNDS",
                    font: 'Rokkitt',
                    head1size: 25,
                    head2size: 15)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signin(TextEditingController? emailcontroller,
      TextEditingController? passwordcontroller) async {
    try {
      print('already done');
      UserCredential usercredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print('user Logged In${usercredential.user!.email}');
      if (emailcontroller!.text == 'admin@gmail.com' &&
          passwordcontroller!.text == '123456') {
        Navigator.pushReplacement(
            context,
            PageTransition(
              child: const AdminBottomNav(),
              type: PageTransitionType.fade,
            ));
      } else {
        final _shardpref = await SharedPreferences.getInstance();
        _shardpref.setBool(SAVE_KEY_NAME, true);
        Navigator.pushReplacement(
            context,
            PageTransition(
              child: const BottomNavigation(),
              type: PageTransitionType.fade,
            ));
      }
    } catch (e) {
      print('error;$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          elevation: 1,
          content: Text(
            'Invalid Email or Password',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
