// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicapp/screens/MusicPlayer/music_player.dart';

class PlaylistSong extends StatefulWidget {
  String? PlaylistName;
  String? Playlistimage;
  String? PlaylistID;
  PlaylistSong(
      {this.PlaylistID, this.PlaylistName, this.Playlistimage, super.key});

  @override
  State<PlaylistSong> createState() => _PlaylistSongState();
}

class _PlaylistSongState extends State<PlaylistSong> {
  final songs = FirebaseFirestore.instance.collection('CustumPlaylistSong');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  List<DocumentSnapshot> Playlistsong = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: widget.Playlistimage != null
                        ? Image.network(widget.Playlistimage!)
                        : Container(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.PlaylistName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  const Divider(
                    thickness: .5,
                    indent: 30,
                    endIndent: 30,
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: songs
                          .where('UserID', isEqualTo: currentUserId)
                          .where('playlistID', isEqualTo: widget.PlaylistID)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                            'No songs found',
                            style: TextStyle(color: Colors.white),
                          ));
                        }
                        Playlistsong = snapshot.data!.docs;
                        return ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var document = snapshot.data!.docs[index];
                            var songName = document['title'];
                            var songimage = document['image'];
                            //  checkIfSongExistsInPlaylistSongCollection(songName);

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return MusicPlayer(
                                            songList:
                                                Playlistsong, // Pass the entire list of songs
                                            currentIndex: index,
                                            iconNeeded: true,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  splashColor:
                                      const Color.fromARGB(125, 255, 255, 255),
                                  onLongPress: () {
                                    showPopupMenu(context, document);
                                  },
                                  enabled: true,
                                  title: Text(
                                    songName ?? '',
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
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                        height: 90,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider(
                              thickness: 0.5,
                              color: Color.fromARGB(162, 255, 255, 255),
                              indent: 10,
                              endIndent: 10,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPopupMenu(BuildContext context, DocumentSnapshot document) {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      context: context,
      builder: (context) {
        return SizedBox(
          height: 60,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.heart,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                title: const Text('Remove From Playlist'),
                onTap: () {
                  deleteFromCollection(document);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteFromCollection(DocumentSnapshot document) async {
    String documentId = document.id;
    await FirebaseFirestore.instance
        .collection('CustumPlaylistSong')
        .doc(documentId)
        .delete();
  }
}
