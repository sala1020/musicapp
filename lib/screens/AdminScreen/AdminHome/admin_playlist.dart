// ignore_for_file: non_constant_identifier_names, empty_catches

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/AdminScreen/AdminHome/PLaylists/new_playlist.dart';
import 'package:musicapp/screens/AdminScreen/AdminHome/PLaylists/adding_song.dart';
import 'package:page_transition/page_transition.dart';

class AdminPlaylist extends StatefulWidget {
  const AdminPlaylist({super.key});

  @override
  State<AdminPlaylist> createState() => _AdminPlaylistState();
}

class _AdminPlaylistState extends State<AdminPlaylist> {
  final Playlist = FirebaseFirestore.instance.collection('NewPlaylist');
  String? newselectedimage;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: SpeedDial(
            overlayColor: Colors.black,
            overlayOpacity: 0.5,
            animatedIcon: AnimatedIcons.add_event,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.playlist_add_sharp),
                label: 'Add New Playlist',
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        child: const NewPlaylist(),
                        type: PageTransitionType.fade),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Playlist.snapshots(),
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

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns in the grid
                      crossAxisSpacing: 8.0, // Spacing between columns
                      mainAxisSpacing: 8.0, // Spacing between rows
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      var Playlistname = document['title'];
                      var Playlistimage = document['image'];
                      var playlistID = document['playlistID'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            navigateToPlaylistDetails(
                                Playlistname, Playlistimage, playlistID);
                          },
                          onLongPress: () {
                            showPopupMenu(context, document);
                          },
                          // Your InkWell content goes here
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
                                          fit: BoxFit.cover,
                                          height: 130,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      Playlistname,
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
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
            ),
          ],
        ),
      ),
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

  void showPopupMenu(BuildContext context, QueryDocumentSnapshot document) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 120,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                            'Are you sure you want to delete the lyrics'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                deleteSong(document);
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

  void deleteSong(QueryDocumentSnapshot document) {
    String songId = document.id;
    Playlist.doc(songId).delete().then((value) {
      deleteSongfrmPlaylist(document);
    }).catchError((error) {});
  }

  void navigateToPlaylistDetails(
      String playlistName, String playlistImage, String playlistID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (playlistName.toLowerCase()) {
            default:
              return AddSongPlaylis(
                playlistImage: playlistImage,
                playlistName: playlistName,
                playlistID: playlistID,
              );
          }
        },
      ),
    );
  }

  void showEditDialog(BuildContext context, QueryDocumentSnapshot document) {
    TextEditingController titleController =
        TextEditingController(text: document['title']);
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
                            selectedImage = null;
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
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: 'Song Title'),
                    ),
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
                        titleController.text.trim(),
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

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      Reference reference = FirebaseStorage.instance.refFromURL(imageUrl);
      await reference.delete();
    } catch (error) {}
  }

  void editSong(
    QueryDocumentSnapshot document,
    String newTitle,
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
      Playlist.doc(songId).update({
        'title': newTitle,
        'image': newImageUrl,
      }).then((value) {
        // Successfully updated
      }).catchError((error) {
        // Failed to update
      });
    } else {
      Playlist.doc(songId).update({
        'title': newTitle,
      }).then((value) {
        // Successfully updated
      }).catchError((error) {
        // Failed to update
      });
    }
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

  void deleteSongfrmPlaylist(QueryDocumentSnapshot document) async {
    String playlistID = document[
        'playlistID']; // Assuming you have a field called playlistID in your songs
    String songId = document.id;

    // Fetch all songs belonging to the playlist
    QuerySnapshot songsSnapshot = await FirebaseFirestore.instance
        .collection(
            'Playlistsong') // Change this to your actual collection name for songs
        .where('playlistID', isEqualTo: playlistID)
        .get();

    // Delete each song
    for (QueryDocumentSnapshot songDocument in songsSnapshot.docs) {
      String songIdToDelete = songDocument.id;
      await FirebaseFirestore.instance
          .collection(
              'Playlistsong') // Change this to your actual collection name for songs
          .doc(songIdToDelete)
          .delete();
    }

    // Delete the playlist
    Playlist.doc(songId).delete().then((value) {}).catchError((error) {});
  }
}
