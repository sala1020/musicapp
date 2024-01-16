// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/main.dart';
import 'package:musicapp/screens/AdminScreen/AdminHome/admin_all.dart';
import 'package:musicapp/screens/AdminScreen/AdminHome/admin_playlist.dart';
import 'package:musicapp/screens/SignInAndSignUp/signin_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int c = 0;
  Icon icon = const Icon(
    FontAwesomeIcons.plus,
    size: 40,
  );
  bool clicked = true;
  bool clicked1 = false;
  List<List<Widget>> mySongs = [
    [
      const AdminAll(),
    ],
    [
      const AdminPlaylist(),
    ]
  ];
  List<String> choiceChips = ["All", "PlayList"];

  List<Widget> displayedSongs = [];

  @override
  void initState() {
    super.initState();

    displayedSongs = mySongs[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    adminlogout();
                  },
                  child: Text(
                    'Log Out',
                    style: GoogleFonts.abel(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(choiceChips.length, (index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    showCheckmark: false,
                    selectedColor: const Color.fromARGB(255, 41, 215, 246),
                    label: SizedBox(
                        height: 40,
                        width: 120,
                        child: Center(
                            child: Text(
                          choiceChips[index],
                          style: const TextStyle(fontSize: 30),
                        ))),
                    selected:
                        (clicked && index == 0) || (clicked1 && index == 1),
                    onSelected: (t) {
                      setState(() {
                        clicked = index == 0;
                        clicked1 = index == 1;
                        displayedSongs = mySongs[index];
                      });
                    },
                  ),
                );
              }),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
   
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedSongs.length,
              itemBuilder: (context, index) {
                return displayedSongs[index];
              },
            ),
          )
        ],
      )),
    );
  }

  Future<void> adminlogout() async {
    // final shardpref = await SharedPreferences.getInstance();
    // shardpref.setBool(SAVE_KEY_NAME, true);
    // ignore: use_build_context_synchronously
    // Navigator.pushReplacement(
    //   context,
    //   PageTransition(
    //     child: const signinpage(),
    //     type: PageTransitionType.fade,
    //   ),
    // );
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Do You Really Want To Logout'),
            actions: [
              TextButton(
                  onPressed: () async {
                    final shardpref = await SharedPreferences.getInstance();
                    shardpref.setBool(SAVE_KEY_NAME, true);

                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: const SignInPage(),
                        type: PageTransitionType.fade,
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Succesfully LogOut From AdminScreen'),
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'))
            ],
          );
        });
  }
}
