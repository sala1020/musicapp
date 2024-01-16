// ignore_for_file: non_constant_identifier_names, empty_catches, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/AdminScreen/bottomnavigation/bottom_navigation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class SongSelectionPlaylist extends StatefulWidget {
  final String? PlaylistID;

  const SongSelectionPlaylist({super.key, this.PlaylistID});

  @override
  State<SongSelectionPlaylist> createState() => _SongSelectionPlaylistState();
}

class _SongSelectionPlaylistState extends State<SongSelectionPlaylist> {
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  selectsong();
                },
                child: const Text('Select Song'),
              ),
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
                          borderSide:
                              BorderSide(width: 1, color: Colors.white)),
                      hintText: 'Song Name',
                      hintStyle: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  AddSong(); // Start adding the song
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
      ),
    );
  }

  Future<void> selectsong() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null) {
        String filePath = result.files.single.path!;
        setState(() {
          selectedsong = filePath;
        });
      } else {
        // User canceled the picker
      }
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        setState(() {
          selectedimage = image.path;
        });
      } catch (e) {}
    }
  }

  Future<void> AddSong() async {
    if (isAddingSong) {
      return;
    }
    if (selectedsong.isNotEmpty &&
        songnamecontroller.text.trim().isNotEmpty &&
        selectedimage.isNotEmpty) {
      try {
        setState(() {
          isAddingSong = true;
        });
        // Upload the song file to Firebase Storage
        String songFileName = DateTime.now().microsecondsSinceEpoch.toString();
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirSong = referenceRoot.child('songs');
        Reference referenceSongToUpload =
            referenceDirSong.child('$songFileName.mp3');
        await referenceSongToUpload.putFile(File(selectedsong));
        songurl = await referenceSongToUpload.getDownloadURL();

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
          await AddUserDetails(
            songurl,
            songnamecontroller.text.trim(),
            imageurl,
            widget.PlaylistID!,
          );
        }
      } catch (e) {
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

  Future<void> AddUserDetails(String selectedsong, String title,
      String imageurll, String playlistID) async {
    try {
      await FirebaseFirestore.instance.collection('Playlistsong').add({
        'Selectedsong': selectedsong,
        'title': title,
        'image': imageurll,
        'playlistID': playlistID, // Add the playlistID here
      });
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: const AdminBottomNav(),
        ),
      );
    } catch (e) {}
  }
}
