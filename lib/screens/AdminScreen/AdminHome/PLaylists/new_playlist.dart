// ignore_for_file: non_constant_identifier_names, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/AdminScreen/AdminHome/admin_playlist.dart';
import 'package:musicapp/screens/AdminScreen/bottomnavigation/bottom_navigation.dart';
import 'package:page_transition/page_transition.dart';

class NewPlaylist extends StatefulWidget {
  const NewPlaylist({super.key});

  @override
  State<NewPlaylist> createState() => _NewPlaylistState();
}

class _NewPlaylistState extends State<NewPlaylist> {
  TextEditingController PlaylistNameController = TextEditingController();
  String selectedimage = '';
  String imageurl = '';
  bool isAddingPlaylist = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                controller: PlaylistNameController,
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
        ),
      ),
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
    if (PlaylistNameController.text.trim().isNotEmpty &&
        selectedimage.isNotEmpty) {
      try {
        setState(() {
          isAddingPlaylist = true;
        });

        // Check if a playlist with the same name already exists
        bool playlistExists = await checkPlaylistExistence(
          PlaylistNameController.text.trim(),
        );

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
            PlaylistNameController.text.trim(),
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

  Future<bool> checkPlaylistExistence(String playlistName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('NewPlaylist')
          .where('title', isEqualTo: playlistName)
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
      await FirebaseFirestore.instance.collection('NewPlaylist').add({
        'title': title,
        'image': imageurll,
        "playlistID": title,
      });
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const AdminBottomNav(),
          childCurrent: const AdminPlaylist(),
        ),
      );
      print('Song details added to Firestore successfully');
    } catch (e) {
      print('Error adding song details to Firestore: $e');
    }
  }
}
