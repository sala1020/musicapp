// ignore_for_file: avoid_print, non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/screens/AdminScreen/bottomnavigation/bottom_navigation.dart';
import 'package:page_transition/page_transition.dart';

class AddLyrics extends StatefulWidget {
  final String? songid;

  const AddLyrics({super.key, this.songid});

  @override
  State<AddLyrics> createState() => _AddLyricsState();
}

class _AddLyricsState extends State<AddLyrics> {
  bool isaddinglyrics = false;
  TextEditingController singername = TextEditingController();
  TextEditingController lyrics = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: Colors.white,
                        controller: singername,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        decoration: const InputDecoration(
                            label: Text('SingerName'),
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: Colors.white,
                        controller: lyrics,
                        minLines: 1,
                        maxLines: 100,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        decoration: const InputDecoration(
                            label: Text('Lyrics'),
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        addLyrics(); // Start adding the song
                      },
                      child: isaddinglyrics == true
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addLyrics() async {
    if (isaddinglyrics) {
      return;
    }

    if (widget.songid == null ||
        singername.text.trim().isEmpty ||
        lyrics.text.trim().isEmpty) {
      print(widget.songid);
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
      return;
    }

    try {
      setState(() {
        isaddinglyrics = true;
      });

      // Add song details to Firestore
      if (mounted) {
        await AddUserDetails(
            singername.text.trim(), lyrics.text.trim(), widget.songid!);
      }
    } catch (e) {
      print('Error during adding lyrics: $e');
    } finally {
      setState(() {
        isaddinglyrics = false;
      });
    }
  }

  Future<void> AddUserDetails(
    String singername,
    String lyrics,
    String songid,
  ) async {
    try {
      print('Checking for existing documents in Firestore');
      QuerySnapshot<Map<String, dynamic>> existingDocs = await FirebaseFirestore
          .instance
          .collection('SongLyrics')
          .where('lyricsID', isEqualTo: songid)
          .get();

      // Delete existing documents
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in existingDocs.docs) {
        await doc.reference.delete();
        print('Deleted existing document: ${doc.id}');
      }

      print('Adding user details to Firestore');
      await FirebaseFirestore.instance.collection('SongLyrics').add({
        'lyrics': lyrics,
        'singername': singername,
        'lyricsID': songid,
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
      print('Error adding/updating song details in Firestore: $e');
    }
  }
}
