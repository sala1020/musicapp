// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/Firebase_functions/custumplaylist/custom_playlist_song.dart';
import 'package:musicapp/Firebase_functions/custumplaylist/custum_playlist_model.dart';
import 'package:musicapp/screens/UserScreen/Library/CustumPlaylist/playlist_song.dart';

Widget CustumPlaylistModel(
    {BuildContext? context,
    bool? clicked,
    String? songname,
    String? songurl,
    String? Songimage,
    String? PlaylistID}) {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final CustumPlaylist =
      FirebaseFirestore.instance.collection('CustumPlaylist');
  final String? currentUserId = auth.currentUser?.uid;

  return StreamBuilder(
    stream:
        CustumPlaylist.where('UserID', isEqualTo: currentUserId).snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      if (!snapshot.hasData ||
          snapshot.data!.docs.isEmpty && clicked == false) {
        return const Center(
            child: Text(
          'No Playlist found',
          style: TextStyle(color: Colors.white),
        ));
      }

      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          var playlistModel = CustomPlaylistModel.fromMap(
              snapshot.data!.docs[index].id,
              snapshot.data!.docs[index].data() as Map<String, dynamic>);
          var Playlistname = playlistModel.title;
          var Playlistimage = playlistModel.image;
          var playlistID = playlistModel.playlistID;
          var userid = playlistModel.userID;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                if (clicked == true) {
                  navigateToPlaylistDetails(
                    playlistName: Playlistname,
                    playlistImage: Playlistimage,
                    playlistID: playlistID,
                    context: context,
                  );
                } else {
                  addSongToPlaylist(
                    context: context,
                    playlistID: playlistID,
                    songImage: Songimage!,
                    songName: songname!,
                    songUrl: songurl!,
                    userID: userid,
                  );
                }
              },
              onLongPress: () {
                showPopupMenu(context, playlistModel);
              },
              child: ListTile(
                title: Text(
                  Playlistname,
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
                leading: CircleAvatar(
                  radius: 28,
                  // backgroundImage: CachedNetworkImageProvider(
                  //   Playlistimage,
                  //   maxHeight: 90,
                  //   maxWidth: 50,
                  //   scale:30,
                  //   // height: 90,
                  //   // width: 50,
                  //   // fit: BoxFit.cover,
                  //   placeholder: (context, url) => Center(
                  //       child: CircularProgressIndicator(
                  //     color: Colors.white,
                  //   )),
                  // ),
                  child: CachedNetworkImage(
                    imageUrl: Playlistimage,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    fit: BoxFit.cover,
                    height: 90,
                    width: 50,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void navigateToPlaylistDetails({
  required String playlistName,
  required String playlistImage,
  required String playlistID,
  required BuildContext context,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        switch (playlistName.toLowerCase()) {
          default:
            return PlaylistSong(
              PlaylistID: playlistID,
              PlaylistName: playlistName,
              Playlistimage: playlistImage,
            );
        }
      },
    ),
  );
}

void showPopupMenu(BuildContext context, CustomPlaylistModel playlistModel) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SizedBox(
        height: 60,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Remove Playlist'),
              onTap: () {
                Navigator.pop(context);
                deletePlaylist(context, playlistModel);
              },
            ),
          ],
        ),
      );
    },
  );
}

void deletePlaylist(
    BuildContext context, CustomPlaylistModel playlistModel) async {
  var docID = playlistModel.documentID;
  await FirebaseFirestore.instance
      .collection('CustumPlaylist')
      .doc(docID)
      .delete();
}
