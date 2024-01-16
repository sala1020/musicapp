import 'package:flutter/material.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/Playlists/local_playlist_items.dart';

class LocalPlaylist extends StatefulWidget {
  const LocalPlaylist({super.key});

  @override
  State<LocalPlaylist> createState() => _LocalPlaylistState();
}

class _LocalPlaylistState extends State<LocalPlaylist> {
  // ignore: non_constant_identifier_names
  TextEditingController PlaylistsearchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.7, 1],
          colors: [Colors.black, Color.fromARGB(255, 0, 242, 255)],
        )),
        child: const Column(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Your Songs',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: LocalPlaylistItems(),
            ),
          ],
        ),
      )),
    );
  }
}
