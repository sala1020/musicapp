import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicapp/screens/MusicPlayer/music_player.dart';

class Favourite extends StatefulWidget {
  const Favourite({super.key});

  @override
  State<Favourite> createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  List<DocumentSnapshot> songList = [];

  final likedsong = FirebaseFirestore.instance.collection('Favourites');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.7, 1],
              colors: [Colors.black, Color.fromARGB(255, 0, 242, 255)],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 200,
                width: double.infinity,
                // ignore: prefer_const_constructors
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        'Liked Song',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: StreamBuilder(
                stream: likedsong
                    .where('UserID', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    // If there is no data, return a loading indicator or empty widget
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                      'No songs found',
                      style: TextStyle(color: Colors.white),
                    ));
                  }
                  songList = snapshot.data!.docs;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      String songname = document['title'];
                      // String songurl = document['Selectedsong'];
                      String songimage = document['image'];

                      return Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            child: ListTile(
                              splashColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MusicPlayer(
                                        songList: songList,
                                        currentIndex: index,
                                        idd: document.id,
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
                              onLongPress: () {
                                showPopupMenu(context, document);
                              },
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
                                    placeholder: (context, url) => const Center(
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
                        ],
                      );
                    },
                    itemCount: snapshot.data!.docs.length,
                  );
                },
              ))
            ],
          )),
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
                title: const Text('Remove From Favourite'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                            'Are you sure you want to Remove From the Favourites'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                deleteFromCollection(document);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Yes')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'))
                        ],
                      );
                    },
                  );
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
        .collection('Favourites')
        .doc(documentId)
        .delete();
  }
}
