// ignore_for_file: camel_case_types, use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/main.dart';
import 'package:musicapp/screens/SignInAndSignUp/signin_page.dart';
import 'package:musicapp/screens/SignInAndSignUp/singup_page.dart';
import 'package:musicapp/screens/refactoring/bottom_navigation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    checklogin();
  }

  _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        opacityLevel = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(milliseconds: 900),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('Assets/walpaper.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 100,
                  top: 360,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(width: 1, color: Colors.white),
                        ),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.s,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        'SALUZZY',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Millions of songs.',
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  child: const SignInPage(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(200, 50)),
                            ),
                            child: Text(
                              'SIGN IN',
                              style: GoogleFonts.rubik(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'or',
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Create An Account.',
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageTransition(
                                  child: const SignUpPage(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                            },
                            style: ButtonStyle(
                              minimumSize:
                                  MaterialStateProperty.all(const Size(200, 50)),
                            ),
                            child: Text(
                              'SIGN UP',
                              style: GoogleFonts.rubik(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checklogin() async {
    final shardpref = await SharedPreferences.getInstance();
    final userloggedin = shardpref.getBool(SAVE_KEY_NAME);
    if (userloggedin == null || userloggedin == false) {
      _startAnimation();
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>  const BottomNavigation()));
    }
  }
}
