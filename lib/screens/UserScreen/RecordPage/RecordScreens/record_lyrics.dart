// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


Widget lyrics(String? SongID) {
  final Lyrics = FirebaseFirestore.instance.collection('SongLyrics');

  return Expanded(
    child: StreamBuilder(
      stream: Lyrics.where('lyricsID', isEqualTo: SongID).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.white,
          ));
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
            'No Lyrics Found',
            style: TextStyle(color: Colors.white),
          ));
        }

        return ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              var SongLyrics = document['lyrics'];
              var singername = document['singername'];

              return Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 100,
                              '-$singername',
                              style: const TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, left: 30),
                        child: Text(
                          SongLyrics,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      )
                    ],
                  ));
            });
      },
    ),
  );
}


