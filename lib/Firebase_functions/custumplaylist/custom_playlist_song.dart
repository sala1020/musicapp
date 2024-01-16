// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlaylistSongModel {
  final String playlistID;
  final String title;
  final String selectedSong;
  final String image;
  final String userID;

  PlaylistSongModel({
    required this.playlistID,
    required this.title,
    required this.selectedSong,
    required this.image,
    required this.userID,
  });

  factory PlaylistSongModel.fromMap(Map<String, dynamic> map) {
    return PlaylistSongModel(
      playlistID: map['playlistID'] ?? '',
      title: map['title'] ?? '',
      selectedSong: map['Selectedsong'] ?? '',
      image: map['image'] ?? '',
      userID: map['UserID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlistID': playlistID,
      'title': title,
      'Selectedsong': selectedSong,
      'image': image,
      'UserID': userID,
    };
  }
}

void addSongToPlaylist({
  required BuildContext context,
  required String playlistID,
  required String songName,
  required String songUrl,
  required String songImage,
  required String userID,
}) async {
  // Check if the song already exists in the playlist
  QuerySnapshot<Map<String, dynamic>> existingSongs = await FirebaseFirestore
      .instance
      .collection('CustumPlaylistSong')
      .where('UserID', isEqualTo: userID)
      .where('playlistID', isEqualTo: playlistID)
      .where('title', isEqualTo: songName)
      .get();

  // If the song already exists, show a message and return
  if (existingSongs.docs.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Song already exists in the playlist.',
            style: TextStyle(color: Colors.white)),
      ),
    );
    return Navigator.pop(context);
  } else {
    // Add the song details to the "PlaylistSongs" collection
    FirebaseFirestore.instance.collection('CustumPlaylistSong').add(
          PlaylistSongModel(
            playlistID: playlistID,
            title: songName,
            selectedSong: songUrl,
            image: songImage,
            userID: userID,
          ).toMap(),
        );
    // Optionally, you can show a success message or navigate to another screen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Song added to the playlist.',
            style: TextStyle(color: Colors.white)),
      ),
    );
    return Navigator.pop(context);
  }
}
