// online_song.dart

// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/Firebase_functions/search/search_model.dart';

class OnlineSong extends StatefulWidget {
  const OnlineSong({
    super.key,
  });

  @override
  State<OnlineSong> createState() => _OnlineSongState();
}

class _OnlineSongState extends State<OnlineSong> {
  final songs = FirebaseFirestore.instance.collection('Playlistsong');
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<DocumentSnapshot> songList = [];
  bool isExoanded = true;
  TextEditingController searchcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: searchcontroller,
            textInputAction: TextInputAction.search,
            autocorrect: true,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              prefixIconColor: Colors.white,
              label: Text('SEARCH'),
              floatingLabelStyle: TextStyle(
                color: Color.fromARGB(255, 225, 225, 225),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                borderSide: BorderSide(
                  width: 3,
                  color: Color.fromARGB(174, 255, 255, 255),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                borderSide: BorderSide(width: 3, color: Colors.white),
              ),
            ),
            onChanged: (query) {
              // Update the song list based on the search query
              updateSongList(query);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: searchmodel(
                access: true,
                context: context,
                searchcontroller: searchcontroller),
          )
        ],
      ),
    );
  }

  void updateSongList(String query) {
    // Update the song list based on the search query
    setState(() {
      if (query.isNotEmpty) {
        songList = songList
            .where((document) =>
                document['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        // Reset the song list if the search query is empty
        songList = [];
      }
    });
  }
}
