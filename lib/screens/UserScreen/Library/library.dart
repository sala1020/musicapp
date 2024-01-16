// ignore_for_file: file_names, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/Firebase_functions/custumplaylist/custum_playlist.dart';
import 'package:musicapp/screens/UserScreen/Library/CustumPlaylist/newcustumplaylist.dart';
import 'package:musicapp/screens/UserScreen/Library/favourite.dart';
import 'package:musicapp/screens/UserScreen/RecordPage/RecordScreens/recorded_song.dart';
import 'package:page_transition/page_transition.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int c = 0;
  bool clicked = true;
  bool clicked1 = false;
  List<List<Widget>> mySongs = [
    [],
  ];
  List<String> choiceChips = ["all"];
  List<Widget> displayedSongs = [];

  @override
  void initState() {
    super.initState();

    displayedSongs = mySongs[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        animatedIcon: AnimatedIcons.add_event,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.playlist_add),
            label: 'Create New Playlist',
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: const NewCustumPlaylist(),
                  type: PageTransitionType.fade,
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Color.fromARGB(255, 100, 101, 101),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Text(
                        'Library',
                        style: GoogleFonts.wallpoet(
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const Favourite();
                      },
                    ));
                  },
                  title: const Text(
                    'Liked Songs',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  leading: const CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://imgs.search.brave.com/YjgFpiL1-zBwwNDGeh_vOgGl1l2Fh8Yd0co8iv76O_c/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9wbHVz/LnVuc3BsYXNoLmNv/bS9wcmVtaXVtX3Bo/b3RvLTE2NzE1Nzgz/MjQ1MTUtYjdjM2E2/OGMwMDAyP3E9ODAm/dz0xMDAwJmF1dG89/Zm9ybWF0JmZpdD1j/cm9wJml4bGliPXJi/LTQuMC4zJml4aWQ9/TTN3eE1qQTNmREI4/TUh4elpXRnlZMmg4/TVROOGZHaGxZWEow/YzN4bGJud3dmSHd3/Zkh4OE1BPT0.jpeg',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const RecordedAudio();
                      },
                    ));
                  },
                  title: const Text(
                    'Recorded Voice',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  leading: const CircleAvatar(
                    radius: 30,
                    backgroundImage: CachedNetworkImageProvider(
                      'https://imgs.search.brave.com/WBJOt_SLpXzAaLfPso4UzeCIukxbyR7mtaNrZYJD4_s/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9jZG4u/cGl4YWJheS5jb20v/cGhvdG8vMjAxNi8x/MS8yMS8xMS8zMi9h/dWRpby0xODQ0Nzk4/XzY0MC5qcGc',
                      scale: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: CustumPlaylistModel(context: context, clicked: true))
          ],
        ),
      ),
    );
  }
}
