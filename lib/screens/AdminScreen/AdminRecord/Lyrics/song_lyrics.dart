// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:musicapp/screens/AdminScreen/AdminRecord/Lyrics/add_lyrics.dart';
import 'package:page_transition/page_transition.dart';

class SongLyrics extends StatefulWidget {
  final String? songname;
  final String? songimage;
  final String? songid;

  const SongLyrics({
    super.key,
    this.songname,
    this.songimage,
    this.songid,
  });

  @override
  State<SongLyrics> createState() => _SongLyricsState();
}

class _SongLyricsState extends State<SongLyrics> {
  final Lyrics = FirebaseFirestore.instance.collection('SongLyrics');
  String singer = '';
  TextEditingController singerNameController = TextEditingController();
  TextEditingController lyricsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: SpeedDial(
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        animatedIcon: AnimatedIcons.add_event,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.music_note),
            label: 'Upload New Song',
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: AddLyrics(songid: widget.songid),
                  type: PageTransitionType.fade,
                ),
              );
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text(
          'Lyrics',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the desired color for the back button
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          widget.songimage != null
              ? CachedNetworkImage(
                  imageUrl: widget.songimage!,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                )
              : Container(),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.songname ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(singer),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: StreamBuilder(
              stream: Lyrics.where('lyricsID', isEqualTo: widget.songid)
                  .snapshots(),
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
                      child: InkWell(
                        onLongPress: () {
                          showPopupMenu(context, document);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '-${singername}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 100,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, left: 30),
                              child: Text(
                                SongLyrics,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          ],
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
    );
  }

  void showPopupMenu(BuildContext context, QueryDocumentSnapshot document) {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 0, 229, 255),
      context: context,
      builder: (context) {
        return SizedBox(
          height: 120,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  showEditDialog(context, document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  deleteSong(document);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteSong(QueryDocumentSnapshot document) {
    String LyricsID = document.id;
    Lyrics.doc(LyricsID).delete().then((value) {
      print('Song deleted successfully');
    }).catchError((error) {
      print('Error deleting song: $error');
    });
  }

  void showEditDialog(BuildContext context, QueryDocumentSnapshot document) {
    String? singername = document['singername'];
    String? Lyrics = document['lyrics'];

    singerNameController.text = singername ?? '';
    lyricsController.text = Lyrics ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit Song'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: const Color.fromARGB(255, 0, 0, 0),
                        controller: singerNameController,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                        decoration: const InputDecoration(
                            label: Text('SingerName'),
                            labelStyle:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        cursorColor: const Color.fromARGB(255, 0, 0, 0),
                        controller: lyricsController,
                        minLines: 1,
                        maxLines: 100,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                        decoration: const InputDecoration(
                            label: Text('Lyrics'),
                            labelStyle:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    editSong(
                      document,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editSong(QueryDocumentSnapshot document) {
    String lyricsID = document.id;

    Lyrics.doc(lyricsID).update({
      'singername': singerNameController.text,
      'lyrics': lyricsController.text,
    }).then((value) {
      print('Song details updated successfully');
    }).catchError((error) {
      print('Error updating song details: $error');
    });
  }
}
