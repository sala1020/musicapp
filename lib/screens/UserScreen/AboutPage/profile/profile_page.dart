// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/refactoring/about_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Widget sizedBox = const SizedBox(height: 10);

  TextEditingController namecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'About',
          style: GoogleFonts.aBeeZee(color: Colors.white, fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.black,
              ),
            ),
            sizedBox,
            aboutTextfield(label: 'NAme', readonly: true),
            sizedBox,
            aboutTextfield(label: 'PhoneNumber', readonly: true),
            sizedBox,
            aboutTextfield(label: 'EmailAddress', readonly: true),
            sizedBox,
            aboutTextfield(label: 'DOB', readonly: true),
            sizedBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(120, 50)),
                  ),
                  child: Text(
                    'EDIT PROFILE',
                    style:
                        GoogleFonts.rowdies(color: Colors.black, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
