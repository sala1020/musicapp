// ignore_for_file: non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/SignInAndSignUp/splash.dart';
import 'package:musicapp/screens/UserScreen/AboutPage/About/about.dart';
import 'package:musicapp/screens/UserScreen/AboutPage/PrivacyPolicy/privacy_policy.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget aboutTextfield({
  String? label,
  bool? readonly,
}) {
  return TextField(
    readOnly: readonly!,
    decoration: InputDecoration(
        label: Text(
      label!,
      style: const TextStyle(color: Colors.white),
    )),
  );
}

Widget aboutContainer({
  required IconData icon,
  required String text,
}) {
  return Container(
    height: 60,
    width: 300,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Color.fromARGB(255, 0, 0, 0),
      boxShadow: [
        BoxShadow(
            color: Color.fromARGB(145, 112, 113, 112),
            blurRadius: 10,
            offset: Offset(5, 5)),
        BoxShadow(
            color: Color.fromARGB(111, 112, 113, 113),
            blurRadius: 10,
            offset: Offset(-5, -5))
      ],
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        Icon(
          icon,
          size: 40,
          color: const Color.fromARGB(191, 255, 255, 255),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          text,
          style: GoogleFonts.muktaMalar(
              color: const Color.fromARGB(226, 255, 255, 255), fontSize: 24),
        )
      ],
    ),
  );
}

Widget profilecontainer({
  required Function showDeatails,
  required Function editdialogue,
  required String selectedimage,
  required String demoimage,
  required String name,
  required String DOB,
  required BuildContext context,
}) {
  String checkedName;
  if (name.length >= 6) {
    checkedName = "${name.substring(0, 4)}.....";
  } else {
    checkedName = name;
  }
  return SizedBox(
    height: 220,
    width: double.infinity,
    // color: Colors.blue,
    child: GestureDetector(
      onTap: () {
        showDeatails();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 150,
            width: 300,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              color: Color.fromARGB(255, 0, 0, 0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(255, 73, 72, 57),
                    blurRadius: 10,
                    offset: Offset(5, 5)),
                BoxShadow(
                    color: Color.fromARGB(255, 14, 217, 232),
                    blurRadius: 10,
                    offset: Offset(0, 0))
              ],
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  child: selectedimage.isEmpty
                      ? ClipOval(
                        child: Image.asset(
                            demoimage, fit: BoxFit.cover,
                            width: 100, // Adjust the width as needed
                            height: 100,
                          ),
                      )
                      : CachedNetworkImage(
                          imageUrl: selectedimage,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 50,
                            backgroundImage: imageProvider,
                          ),
                        ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 31,
                      width: 90,
                      child: Text(
                        checkedName,
                        style: GoogleFonts.muktaMalar(
                            color: const Color.fromARGB(224, 255, 255, 255),
                            fontSize: 30),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      DOB,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
                const SizedBox(
                  width: 13,
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        editdialogue();
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget aboutDetails(
    {required BuildContext context, required FirebaseAuth auth}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'About',
            style: GoogleFonts.yantramanav(color: Colors.white, fontSize: 30),
          ),
        ],
      ),
      const SizedBox(
        height: 30,
      ),
      GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const About(),
                ));
          },
          child: aboutContainer(icon: Icons.info_outline, text: 'About Us')),
      const SizedBox(
        height: 30,
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicy(),
              ));
        },
        child: aboutContainer(icon: Icons.privacy_tip, text: 'Privacy Policy'),
      ),
      const SizedBox(
        height: 30,
      ),
      GestureDetector(
          onTap: () {
            Share.share('haii');
          },
          child: aboutContainer(icon: Icons.share, text: 'Share')),
      const SizedBox(
        height: 30,
      ),
      OutlinedButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: const Color.fromARGB(255, 184, 183, 183),
                titleTextStyle:
                    GoogleFonts.padauk(color: Colors.black, fontSize: 25),
                title: const Text('Are You Sure You Want To LogOut'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('No')),
                  TextButton(
                      onPressed: () async {
                        final shardpref = await SharedPreferences.getInstance();
                        shardpref.clear();
                        auth.signOut();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const SplashPage()),
                          (route) => false,
                        );
                      },
                      child: const Text('Yes')),
                ],
              );
            },
          );
        },
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shadowColor: const MaterialStatePropertyAll(
            Color.fromARGB(255, 255, 255, 255),
          ),
          backgroundColor:
              const MaterialStatePropertyAll(Color.fromARGB(255, 0, 0, 0)),
          minimumSize: MaterialStateProperty.all(const Size(120, 50)),
        ),
        child: Text(
          'Log Out',
          style: GoogleFonts.sniglet(
              color: const Color.fromARGB(255, 209, 207, 207), fontSize: 25),
        ),
      )
    ],
  );
}
