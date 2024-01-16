// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/SignInAndSignUp/signin_page.dart';
import 'package:musicapp/screens/refactoring/sign_page.dart';

import 'package:page_transition/page_transition.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController Dobcontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  String Username = '';
  String Dob = '';
  String Email = '';
  String Password = '';
  String imageurl = '';
  String demoimage = 'Assets/profile1.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              height: 800,
              width: double.infinity,
              decoration:  const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  opacity: 0.4,
                  image: AssetImage('Assets/background.png'),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              pageHeading(
                                  head1: 'Sign Up',
                                  head2: 'Discover The Beauty Of Voice',
                                  font1: 'Seymour One',
                                  font2: 'Pacifico'),
                            ],
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(45.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          textField(
                            label: 'Username',
                            controller: usernamecontroller,
                            validator: (value) {
                              String trimmedValue = value?.trim() ?? '';

                              if (trimmedValue.isEmpty) {
                                return 'Please Enter the Username';
                              } 
                              return null;
                            },
                            onchanged: (value) {
                              setState(() {
                                Username = value!.trim();
                              });
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          textField(
                              readonly: true,
                              hinttext: 'DD-MM-YYYY',
                              label: 'DOB',
                              controller: Dobcontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Fill This FIeld';
                                }

                                return null;
                              },
                              onchanged: (value) {
                                setState(() {
                                  Dob = value!;
                                });
                                return null;
                              },
                              ontap: () async {
                                DateTime? Pickedtime = await showDatePicker(
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1995),
                                    lastDate: DateTime(2100));

                                if (Pickedtime != null) {
                                  setState(() {
                                    setState(() {
                                      Dobcontroller.text =
                                          '${Pickedtime.day.toString().padLeft(2, '0')}-${Pickedtime.month.toString().padLeft(2, '0')}-${Pickedtime.year}';
                                    });
                                  });
                                }
                              }),
                          const SizedBox(
                            height: 20,
                          ),
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
                              }
                              return null;
                            },
                            onchanged: (value) {
                              setState(() {
                                Email = value!;
                              });
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          textField(
                            label: 'Password',
                            obscureText: true,
                            controller: passwordcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter the Password';
                              } else if (value.length < 6) {
                                return 'Password should be at least 6 characters';
                              } else if (value.contains(' ')) {
                                return 'Password cannot contain spaces';
                              }
                              return null;
                            },
                            onchanged: (value) {
                              setState(() {
                                Password = value!;
                              });
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                signup();
                              }
                            },
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(120, 50)),
                            ),
                            child: Text(
                              'SIGN UP',
                              style: GoogleFonts.rowdies(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          suggest(
                              ctx: context,
                              firsttext: 'Already Have An Account?',
                              linktext: ' SIGN IN.',
                              page: () => const SignInPage()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  bottomHead(
                      head1: '“If music be the food of love, play on.”',
                      head2: '- William Shakespeare',
                      font: 'Patua One',
                      head1size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (other code remains the same)

  void signup() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: Email,
        password: Password,
      );
      print('User registered: ${userCredential.user!.email}');

      await AddUserDetails(
          usernamecontroller.text.trim(),
          Dobcontroller.text.trim(),
          emailcontroller.text.trim(),
          passwordcontroller.text.trim(),
          imageurl);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Email Already Exist'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ok'))
              ],
            );
          });
    }
  }

  Future<void> AddUserDetails(String Username, String DOB, String Email,
      String Password, String image) async {
    try {
      print('Adding user details to Firestore');
      await FirebaseFirestore.instance.collection('SignUpData').add({
        'Username': Username,
        'DOB': DOB,
        'EmailAddress': Email,
        'Password': Password,
      });
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const SignInPage(),
        ),
      );
      await FirebaseFirestore.instance
          .collection('ProfileImage')
          .add({'image': '', 'UserEmail': Email});
      print('User details added to Firestore successfully');
    } catch (e) {
      print('Error adding user details to Firestore: $e');
    }
  }
}
