// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/online_song_playlist.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/Playlists/local_playlist.dart';

class HomePlaylist extends StatefulWidget {
  const HomePlaylist({super.key});

  @override
  _HomePlaylistState createState() => _HomePlaylistState();
}

class _HomePlaylistState extends State<HomePlaylist> {
  final Playlist = FirebaseFirestore.instance.collection('NewPlaylist');
  bool isPlaylistVisible = true;
  List<List<Widget>> PlayList = [
    [
      Column(
        children: [
          Container(
            height: 150,
            width: 170,
            color: const Color.fromARGB(255, 74, 45, 222),
            child: Image.network(
              'https://imgs.search.brave.com/WeTmFtxOT_ycvbsj9ijBXAVJcfRoRpIN-OkO9KsBUcM/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMudW5zcGxhc2gu/Y29tL3Bob3RvLTE0/OTQyMzI0MTA0MDEt/YWQwMGQ1NDMzY2Zh/P2l4bGliPXJiLTQu/MC4zJml4aWQ9TTN3/eE1qQTNmREI4TUh4/elpXRnlZMmg4Tkh4/OGNHeGhlV3hwYzNS/OFpXNThNSHg4TUh4/OGZEQT0mdz0xMDAw/JnE9ODA.jpeg',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      const Text(
        'Local Playlist',
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Explore',
              style: GoogleFonts.pacifico(color: Colors.white, fontSize: 30),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            'Your Playlist',
            style: GoogleFonts.robotoSlab(
                color: const Color.fromARGB(255, 0, 238, 255),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: PlayList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      print("object");

                      PlayListNavigation(index);
                      //  requestPermission(index);
                    },
                    child: SizedBox(
                      height: 220,
                      width: 180,
                      child: Column(
                        children: PlayList[index],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Online Playlist',
            style: GoogleFonts.robotoSlab(
                color: const Color.fromARGB(255, 0, 238, 255),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 210,
          child: StreamBuilder(
            stream: Playlist.snapshots(),
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
                  'No Playlist found',
                  style: TextStyle(color: Colors.white),
                ));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var document = snapshot.data!.docs[index];
                  var Playlistname = document['title'];
                  var Playlistimage = document['image'];
                  var playlistID = document['playlistID'];

                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        navigateToPlaylistDetails(
                            Playlistname, Playlistimage, playlistID);
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 130,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: Playlistimage,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  Playlistname,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 30.0,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }

  void PlayListNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LocalPlaylist()));
        break;
      case 1:
        break;

      default:
        break;
    }
  }

  void navigateToPlaylistDetails(
      String playlistName, String playlistImage, String playlistID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (playlistName.toLowerCase()) {
            default:
              return Scaffold(
                body: ListOnlineSong(
                  playlistImage: playlistImage,
                  playlistName: playlistName,
                  playlistID: playlistID,
                ),
              );
          }
        },
      ),
    );
  }
}
