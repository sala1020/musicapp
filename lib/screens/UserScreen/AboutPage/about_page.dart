// ignore_for_file: unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:musicapp/screens/refactoring/about_textfield.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final data = FirebaseFirestore.instance.collection('SignUpData');
  final profileimage = FirebaseFirestore.instance.collection('ProfileImage');
  String selectedimage = '';

  String demoimage = 'Assets/profile1.png';
  late User _user;
  String Emailaddress = '';
  String Name = '';
  String DOB = '';
  String Id = '';
  String ProfileID = '';
  String imageUrl = '';
  ScaffoldMessengerState? _scaffoldMessengerState;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchUserData();
    _fetchProfileImage();
  }

  Future<void> _fetchUserData() async {
    // Fetch user data using the user's email
    var snapshot =
        await data.where('EmailAddress', isEqualTo: _user.email).get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      String id = doc.id;

      setState(() {
        Emailaddress = doc['EmailAddress'];
        Name = doc['Username'];
        DOB = doc['DOB'];
        Id = id;
      });
    }
  }

  Future<void> _fetchProfileImage() async {
    var snapshot =
        await profileimage.where('UserEmail', isEqualTo: _user.email).get();
    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      ProfileID = doc.id;

      setState(() {
        selectedimage = doc['image'];

        // ProfileID = ID;
        // print('=$ProfileID');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldMessengerState = ScaffoldMessenger.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              profilecontainer(
                showDeatails: showDeatails,
                editdialogue: editdialogue,
                selectedimage: selectedimage,
                demoimage: demoimage,
                name: Name,
                DOB: DOB,
                context: context,
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: aboutDetails(auth: _auth, context: context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return image.path;
    }
    return '';
  }

  void editdialogue() {
    TextEditingController NameController = TextEditingController(text: Name);
    String newimage = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              content: SizedBox(
                  height: 220,
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                 
                          String imagePath = await pickImage();
                     
                          if (imagePath != null) {
                        
                            setState(() {
                              newimage = imagePath;
                            });
                          }
                        },
                        child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: newimage.isEmpty &&
                                    selectedimage.isEmpty
                                ? Image.asset(demoimage).image
                                : newimage.isNotEmpty || selectedimage.isEmpty
                                    ? Image.file(File(newimage)).image
                                    : CachedNetworkImageProvider(
                                        selectedimage)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: NameController,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(seconds: 1),
                        content:
                            Text('Plz Wait The Profile Will be Updated soon')));

                    Navigator.pop(context);

                    if (newimage.isNotEmpty ||
                        selectedimage.isNotEmpty &&
                            NameController.text.isNotEmpty) {
                      bool success = await updateProfileImage(image: newimage);

                      if (success) {
                        updateUserData(NameController.text);
                      } else {
                
                        _scaffoldMessengerState!.showSnackBar(const SnackBar(
                          duration: Duration(seconds: 3),
                          content: Text('Image Update Failed'),
                        ));
                      }
                    } else {
                
                    }
                  },
                  child: const Text('Save'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void showDeatails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          content: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your Details',
                  style: GoogleFonts.muktaMalar(
                      color: const Color.fromARGB(226, 255, 255, 255),
                      fontSize: 30),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text(
                      '     Username: ',
                      style: GoogleFonts.muktaMalar(
                          color: const Color.fromARGB(116, 255, 255, 255),
                          fontSize: 20),
                    ),
                    Text(
                      Name,
                      style: GoogleFonts.muktaMalar(
                          color: const Color.fromARGB(226, 255, 255, 255),
                          fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'DOB: ',
                        style: GoogleFonts.muktaMalar(
                            color: const Color.fromARGB(116, 255, 255, 255),
                            fontSize: 20),
                      ),
                      Text(
                        DOB,
                        style: GoogleFonts.muktaMalar(
                            color: const Color.fromARGB(226, 255, 255, 255),
                            fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Email: ',
                        style: GoogleFonts.muktaMalar(
                            color: const Color.fromARGB(116, 255, 255, 255),
                            fontSize: 20),
                      ),
                      Text(
                        Emailaddress,
                        style: GoogleFonts.muktaMalar(
                            color: const Color.fromARGB(226, 255, 255, 255),
                            fontSize: 20),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateUserData(
    String newName,
  ) async {

     
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId != null) {
    
        await data.doc(Id).update({
          'Username': newName,
        });
        setState(() {
          Name = newName;
        });
      } else {}

  }

  Future<bool> updateProfileImage({required String image}) async {



      Reference referenceRoot = FirebaseStorage.instance.ref();

      // Upload the image to Firebase Storage
      String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference referenceDirImage = referenceRoot.child('images');
      Reference referenceImageToUpload =
          referenceDirImage.child('$imageFileName.jpg');
      await referenceImageToUpload.putFile(File(image));
      imageUrl = await referenceImageToUpload.getDownloadURL();

      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId != null && mounted) {
        await profileimage.doc(ProfileID).update({'image': imageUrl});
        setState(() {
          selectedimage = imageUrl;
        });

        return true;
      }


    return false; // Image update failed
  }
}
