// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicapp/Firebase_functions/custumplaylist/custum_playlist.dart';
import 'package:musicapp/screens/MusicPlayer/music_player.dart';

Widget searchmodel({
  TextEditingController? searchcontroller,
  bool? access,
  BuildContext? context,
}) {
  final songs = FirebaseFirestore.instance.collection('Playlistsong');
  List<DocumentSnapshot> songList = [];
  return StreamBuilder(
    stream: songs.snapshots(),
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

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text(
            'No songs found',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      if (searchcontroller!.text.isNotEmpty) {
        songList = snapshot.data!.docs
            .where(
              (document) => document['title'].toLowerCase().contains(
                    searchcontroller.text.toLowerCase(),
                  ),
            )
            .toList();
      } else {
        songList = snapshot.data!.docs;
      }

      return songList.isEmpty
          ? const Center(
              child: Text(
                'No songs found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.separated(
              itemCount: songList.length,
              itemBuilder: (context, index) {
                var document = songList[index];
                var songname = document['title'];
                String songimage = document['image'];
                String id = document.id;

                return InkWell(
                  child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return MusicPlayer(
                                songList: songList,
                                currentIndex: index,
                                idd: id,
                                iconNeeded: true,
                              );
                            },
                          ),
                        );
                      },
                      visualDensity: const VisualDensity(
                        horizontal: 0.9,
                        vertical: 0.9,
                      ),
                      splashColor: const Color.fromARGB(125, 255, 255, 255),
                      enabled: true,
                      title: Text(
                        songname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipOval(
                            child: CachedNetworkImage(
                          imageUrl: songimage,
                          height: 90,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white,)),
                        )),
                      ),
                      trailing: access == true
                          ? IconButton(
                              onPressed: () {
                                showPopupMenu(context, document);
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ))
                          : const SizedBox.shrink()),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
            );
    },
  );
}

void showPopupMenu(BuildContext context, DocumentSnapshot document) {
  String? songImage = document['image'];
  String? songUrl = document['Selectedsong'];
  String? songName = document['title'];
  // String? PlaylistID = document['playlistID'];
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  showModalBottomSheet(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    context: context,
    builder: (context) {
      return SizedBox(
        height: 120,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.heart,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              title: const Text('Add TO Favourite'),
              onTap: () {
                addToFavourite(
                    image: songImage,
                    name: songName,
                    song: songUrl,
                    UserID: currentUserId,
                    context: context);
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.heart,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              title: const Text('Add TO Playlist'),
              onTap: () {
                Navigator.pop(context);
                navigateToCustomPlaylist(
                    context: context,
                    imageurl: songImage,
                    songname: songName,
                    songurl: songUrl);
              },
            ),
          ],
        ),
      );
    },
  );
}

void navigateToCustomPlaylist(
    {required BuildContext context,
    String? songurl,
    String? imageurl,
    String? songname}) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Center(
                child: Text(
              'Playlists',
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            )),
            backgroundColor: const Color.fromARGB(139, 0, 0, 0),
            content: SizedBox(
              height: 200, // Set your desired height
              width: 300, // Set your desired width
              child: CustumPlaylistModel(
                  clicked: false,
                  Songimage: imageurl,
                  songname: songname,
                  songurl: songurl),
            ),
          );
        },
      );
    },
  );
}

void addToFavourite({
  String? image,
  String? song,
  String? name,
  String? UserID,
  BuildContext? context,
}) async {
  // Check if the song already exists in the "Favourites" collection
  QuerySnapshot<Map<String, dynamic>> existingSongs = await FirebaseFirestore
      .instance
      .collection('Favourites')
      .where('title', isEqualTo: name)
      .where('UserID', isEqualTo: UserID)
      .get();

  // If the song already exists, show a message and return
  if (existingSongs.docs.isNotEmpty) {
    ScaffoldMessenger.of(context!).showSnackBar(
      const SnackBar(
        content: Text('Song already exists in the favourites.',
            style: TextStyle(color: Colors.white)),
      ),
    );
    return Navigator.pop(context);
  } else {
    await FirebaseFirestore.instance.collection('Favourites').add({
      'image': image,
      'title': name,
      'Selectedsong': song,
      'UserID': UserID,
    });

    // Optionally, you can show a success message or perform other actions.
    ScaffoldMessenger.of(context!).showSnackBar(
      const SnackBar(
        content: Text('Song added to favourites.',
            style: TextStyle(color: Colors.white)),
      ),
    );
    Navigator.pop(context);
  }

  // If the song doesn't exist, add it to the "Favourites" collection
}
