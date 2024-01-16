// ignore_for_file: use_build_context_synchronously, avoid_print, non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/UserScreen/Library/library.dart';
import 'package:musicapp/screens/refactoring/bottom_navigation.dart';
import 'package:page_transition/page_transition.dart';



class NewCustumPlaylist extends StatefulWidget {
  const NewCustumPlaylist({super.key});

  @override
  State<NewCustumPlaylist> createState() => _NewCustumPlaylistState();
}

class _NewCustumPlaylistState extends State<NewCustumPlaylist> {
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  String selectedimage = '';
  String imageurl = '';
  bool isAddingPlaylist = false;
  TextEditingController custumplaylistnmamecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              pickImage();
            },
            child: const Text('Select Playlist Image'),
          ),
          const SizedBox(
            height: 20,
          ),
          selectedimage.isNotEmpty
              ? Image.file(
                  File(selectedimage),
                  height: 100,
                  width: 100,
                )
              : Container(),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: TextField(
              controller: custumplaylistnmamecontroller,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                focusColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.white),
                ),
                hintText: 'Playlist Name',
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              AddPlaylist(); // Start adding the song
            },
            child: isAddingPlaylist == true
                ? const CircularProgressIndicator()
                : const Text(
                    'Add Playlist',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
          ),
        ],
      )),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        setState(
          () {
            selectedimage = image.path;
          },
        );
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  Future<void> AddPlaylist() async {
    if (isAddingPlaylist) {
      return;
    }
    if (custumplaylistnmamecontroller.text.trim().isNotEmpty &&
        selectedimage.isNotEmpty) {
      try {
        setState(() {
          isAddingPlaylist = true;
        });

        // Check if a playlist with the same name already exists
        bool playlistExists = await checkPlaylistExistence(
            playlistName: custumplaylistnmamecontroller.text.trim(),
            userId: currentUserId);

        if (playlistExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A playlist with the same name already exists.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Continue with adding the playlist if it doesn't exist
          Reference referenceRoot = FirebaseStorage.instance.ref();

          // Upload the image to Firebase Storage
          String imageFileName =
              DateTime.now().microsecondsSinceEpoch.toString();
          Reference referenceDirImage = referenceRoot.child('images');
          Reference referenceImageToUpload =
              referenceDirImage.child('$imageFileName.jpg');
          await referenceImageToUpload.putFile(File(selectedimage));
          imageurl = await referenceImageToUpload.getDownloadURL();

          // Add playlist details to Firestore
          await AddPlaylistDetails(
            custumplaylistnmamecontroller.text.trim(),
            imageurl,
          );
        }
      } catch (e) {
        print('Error during file upload or adding playlist details: $e');
      } finally {
        setState(() {
          isAddingPlaylist = false;
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

  Future<bool> checkPlaylistExistence(
      {String? playlistName, String? userId}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('CustumPlaylist')
          .where('title', isEqualTo: playlistName)
          .where('UserID', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking playlist existence: $e');
      return false;
    }
  }

  Future<void> AddPlaylistDetails(String title, String imageurll) async {
    try {
      print('Adding Playlist details to Firestore');

      // Get the current user's ID from Firebase Authentication
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserId != null) {
        // Add playlist details to Firestore with the current user's ID
        await FirebaseFirestore.instance.collection('CustumPlaylist').add({
          'title': title,
          'image': imageurll,
          'playlistID': title,
          'UserID': currentUserId,
        });

        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const BottomNavigation(),
            childCurrent: const LibraryPage(),
          ),
        );

        print('Playlist details added to Firestore successfully');
      } else {
        print('Current user is null. Ensure the user is authenticated.');
      }
    } catch (e) {
      print('Error adding playlist details to Firestore: $e');
    }
  }
}
