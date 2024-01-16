// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/Firebase_functions/search/search_model.dart';

class Searching extends StatefulWidget {
  bool? nav;
  Searching({this.nav, super.key});

  @override
  State<Searching> createState() => _SearchingState();
}

class _SearchingState extends State<Searching> {
  TextEditingController searchcontroller = TextEditingController();
  List<DocumentSnapshot> songList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          controller: searchcontroller,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
              hintText: 'SEARCH HERE',
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              // enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
              enabled: true,
              hintStyle: TextStyle(color: Colors.white)),
          onChanged: (value) {
            updateSongList(value);
          },
        ),
        leading: widget.nav == true
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : const SizedBox.shrink(),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: searchmodel(
                access: false,
                context: context,
                searchcontroller: searchcontroller),
          ),
        ],
      ),
    );
  }

  void updateSongList(String query) {
    setState(() {
      if (query.isNotEmpty) {
        songList = songList
            .where((document) =>
                document['title'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
      
        songList = [];
      }
    });
  }
}
