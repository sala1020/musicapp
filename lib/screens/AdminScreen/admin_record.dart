import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/AdminScreen/AdminRecord/Lyrics/song_lyrics.dart';
import 'package:musicapp/screens/AdminScreen/AdminRecord/NewSong/new_music.dart';
import 'package:page_transition/page_transition.dart';

class LyricalMusic extends StatefulWidget {
  const LyricalMusic({super.key});

  @override
  State<LyricalMusic> createState() => _LyricalMusicState();
}

class _LyricalMusicState extends State<LyricalMusic> {
  final songs = FirebaseFirestore.instance.collection('NewRecordSong');
  bool isSongLyricsVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                  child: const NewMusic(),
                  type: PageTransitionType.fade,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Color.fromARGB(175, 56, 55, 55)],
              )),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lyrics',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: songs.snapshots(),
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
                      'No songs found',
                      style: TextStyle(color: Colors.white),
                    ));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      var songName = document['title'];
                      var songimage = document['image'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {},
                          child: ListTile(
                            onTap: () {
                              navigateToPlaylistDetails(
                                  songName, songimage, songName);
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
                            trailing: const Icon(
                              Icons.arrow_right_alt,
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
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                            'Are you sure you want to delete the lyrics'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                deleteSong(document);
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

  void deleteSong(QueryDocumentSnapshot document) async {
    String songId = document.id;

    // Check if 'title' field exists in the document
    if (document['title'] != null) {
      // Delete song from SongsLyr collection
      await songs.doc(songId).delete().then((value) {}).catchError((error) {});

      // Delete corresponding lyrics from SongLyrics collection
    } else {
      // Handle the case where 'title' field is absent
    }
  }

  void showEditDialog(BuildContext context, QueryDocumentSnapshot document) {
    String? selectedImage = document['image'];
    String? newSelectedImage;

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
                    ElevatedButton(
                      onPressed: () async {
                        var imageFile = await pickImage();
                        if (imageFile != null) {
                          setState(() {
                            newSelectedImage = imageFile.path;
                            selectedImage = null; // Reset selectedImage
                          });
                        }
                      },
                      child: const Text('Select Image'),
                    ),
                    const SizedBox(height: 10),
                    if (newSelectedImage != null &&
                        newSelectedImage!.isNotEmpty)
                      newSelectedImage!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: newSelectedImage!,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            )
                          : Image.file(
                              File(newSelectedImage!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                    else if (selectedImage != null && selectedImage!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: selectedImage!,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      )
                    else
                      const SizedBox.shrink(),
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
                    if (newSelectedImage != null || selectedImage != null) {
                      editSong(
                        document,
                        newSelectedImage,
                      );
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
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

  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  void editSong(
    QueryDocumentSnapshot document,
    String? newImage,
  ) async {
    String songId = document.id;
    String oldImage = document['image'];

    // Check if newImage is not null before updating
    if (newImage != null) {
      // Delete the old image from Firebase Storage
      await deleteImageFromStorage(oldImage);

      // Upload the new image to Firebase Storage
      String newImageUrl = await uploadImageToStorage(newImage);

      // Update the song details in Firestore
      songs.doc(songId).update({
        'image': newImageUrl,
      }).then((value) {
        // Successfully updated
      }).catchError((error) {
        // Failed to update
      });
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      Reference reference = FirebaseStorage.instance.refFromURL(imageUrl);
      await reference.delete();
      // ignore: empty_catches
    } catch (error) {}
  }

  Future<String> uploadImageToStorage(String imagePath) async {
    try {
      // Generate a unique filename using current timestamp
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();

      // Get a reference to the root of your Firebase Storage
      Reference referenceRoot = FirebaseStorage.instance.ref();

      // Specify the directory (e.g., 'images')
      Reference referenceDirImage = referenceRoot.child('images');

      // Creating a reference to the image file with the generated filename
      Reference referenceImageToUpload = referenceDirImage.child(fileName);

      // Upload the new image to Firebase Storage
      await referenceImageToUpload.putFile(File(imagePath));
      // Get the new image URL
      String newImageUrl = await referenceImageToUpload.getDownloadURL();
      return newImageUrl;
    } catch (error) {
      return '';
    }
  }

  void navigateToPlaylistDetails(
      String songname, String songimage, String songid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (songname.toLowerCase()) {
            default:
              return SongLyrics(
                songid: songid,
                songimage: songimage,
                songname: songname,
              );
          }
        },
      ),
    );
  }
}
