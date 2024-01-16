import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicapp/screens/MusicPlayer/music_player.dart';

class ListOnlineSong extends StatefulWidget {
  final String? playlistName;
  final String? playlistImage;
  final String? playlistID;

  const ListOnlineSong({
    super.key,
    this.playlistName,
    this.playlistImage,
    this.playlistID,
  });

  @override
  State<ListOnlineSong> createState() => _ListOnlineSongState();
}

class _ListOnlineSongState extends State<ListOnlineSong> {
  final songs = FirebaseFirestore.instance.collection('Playlistsong');
  List<DocumentSnapshot> onlinesong = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      opacity: 0.8,
                      image: AssetImage('Assets/userplaylistbackground.png'),
                      fit: BoxFit.cover)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: widget.playlistImage != null
                        ? CachedNetworkImage(
                            imageUrl: widget.playlistImage!,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.playlistName!.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: songs
                          .where('playlistID', isEqualTo: widget.playlistID)
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
                        onlinesong = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var document = snapshot.data!.docs[index];
                            var songName = document['title'];
                            var songimage = document['image'];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                child: ListTile(
                                  splashColor:
                                      const Color.fromARGB(125, 255, 255, 255),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return MusicPlayer(
                                            songList:
                                                onlinesong, // Pass the entire list of songs
                                            currentIndex: index,
                                            iconNeeded: true,
                                          );
                                        },
                                      ),
                                    );
                                  },
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

  void showPopupMenu(BuildContext context, QueryDocumentSnapshot document) {
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
                title: const Text('Add TO Favourite'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
