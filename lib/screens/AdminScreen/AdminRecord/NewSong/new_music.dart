// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/AdminScreen/bottomnavigation/bottom_navigation.dart';
import 'package:page_transition/page_transition.dart';

class NewMusic extends StatefulWidget {
  const NewMusic({super.key});

  @override
  State<NewMusic> createState() => _NewMusicState();
}

class _NewMusicState extends State<NewMusic> {
  String selectedsong = '';
  String selectedimage = '';
  String imageurl = '';
  String songurl = '';
  TextEditingController songnamecontroller = TextEditingController();
  bool isAddingSong = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                selectedsong,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                pickImage();
              },
              child: const Text('Select Background Image'),
            ),
            const SizedBox(
              height: 10,
            ),
            selectedimage.isNotEmpty
                ? Image.file(
                    File(selectedimage),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Container(),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: songnamecontroller,
                decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    focusColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.white)),
                    hintText: 'Song Name',
                    hintStyle: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                addSong();
              },
              child: isAddingSong == true
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Add Song',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print('picked');
      try {
        setState(() {
          selectedimage = image.path;
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> addSong() async {
    if (isAddingSong) {
      return;
    }
    if (songnamecontroller.text.trim().isNotEmpty && selectedimage.isNotEmpty) {
      try {
        setState(() {
          isAddingSong = true;
        });
        // Upload the song file to Firebase Storage
        Reference referenceRoot = FirebaseStorage.instance.ref();

        // Upload the image to Firebase Storage
        String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
        Reference referenceDirImage = referenceRoot.child('images');
        Reference referenceImageToUpload =
            referenceDirImage.child('$imageFileName.jpg');
        await referenceImageToUpload.putFile(File(selectedimage));
        imageurl = await referenceImageToUpload.getDownloadURL();

        // Add song details to Firestore
        if (mounted) {
          // Add song details to Firestore
          await addUserDetails(
            songnamecontroller.text.trim(),
            imageurl,
          );
        }
      } catch (e) {
        print('Error during file upload or adding song details: $e');
      } finally {
        setState(() {
          isAddingSong = false;
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Empty Fields'),
            content: const Text('Please fill all the fields.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> addUserDetails(
    String title,
    String imageurll,
  ) async {
    try {
      print('Adding user details to Firestore');
      await FirebaseFirestore.instance.collection('NewRecordSong').add({
        'title': title,
        'image': imageurll,
        // Add the playlistID here
      });
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const AdminBottomNav(),
        ),
      );
      print('Song details added to Firestore successfully');
    } catch (e) {
      print('Error adding song details to Firestore: $e');
    }
  }
}
