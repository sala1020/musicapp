// ignore_for_file: file_names, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/Firebase_functions/search/search_model.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/online_song_playlist.dart';
import 'package:musicapp/screens/UserScreen/SearchPage/searching.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchcontroller = TextEditingController();
  List<DocumentSnapshot> songList = [];
  final playlist = FirebaseFirestore.instance.collection('NewPlaylist');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  //  circleAvatar(circleradius: 50, iconsize: 80),
                  const CircleAvatar(
                    backgroundColor: Color.fromARGB(157, 255, 255, 255),
                    radius: 50,
                    child: Icon(
                      Icons.search_sharp,
                      size: 90,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Find a Song',
                    style: TextStyle(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      onTap: () {
                        // Navigate to SearchingPage when the search field is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Searching(nav: true),
                          ),
                        );
                      },
                      child: const TextField(
                        enabled: false,

                        // expands: true,
                        enableSuggestions: true,

                        textInputAction: TextInputAction.none,
                        autocorrect: true,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            prefixIconColor: Colors.white,
                            label: Text('SEARCH'),
                            floatingLabelStyle: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(color: Colors.grey),
                            // focusedBorder: OutlineInputBorder(
                            //   borderRadius: BorderRadius.all(
                            //     Radius.circular(30),
                            //   ),
                            //   borderSide: BorderSide(
                            //     width: 3,
                            //     color: Color.fromARGB(174, 255, 255, 255),
                            //   ),
                            // ),
                            // enabledBorder: OutlineInputBorder(
                            //   borderRadius: BorderRadius.all(
                            //     Radius.circular(20),
                            //   ),
                            //   borderSide:
                            //       BorderSide(width: 3, color: Colors.white),

                            // ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              borderSide:
                                  BorderSide(width: 2, color: Colors.white),
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
              child: SizedBox(
                height: 230,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Top genres',
                      style: GoogleFonts.roboto(
                          fontSize: 25,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: playlist.snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                              snapshot.data!.docs.isEmpty) {
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
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    navigateToPlaylistDetails(Playlistname,
                                        Playlistimage, playlistID);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
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
                                                    child:
                                                        CircularProgressIndicator(
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
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
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
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Browse All',
                style: GoogleFonts.roboto(
                    fontSize: 25,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 200,
                child: searchmodel(
                    context: context,
                    searchcontroller: searchcontroller,
                    access: false),
              ),
            ),
          ],
        ),
      ),
    );
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
              ));
          }
        },
      ),
    );
  }
}
