// ignore_for_file: empty_catches

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/AdminScreen/AdminHome/PLaylists/song_selection.dart';
import 'package:page_transition/page_transition.dart';

class AddSongPlaylis extends StatefulWidget {
  final String? playlistName;
  final String? playlistImage;
  final String? playlistID;

  const AddSongPlaylis({
    super.key,
    this.playlistName,
    this.playlistImage,
    this.playlistID,
  });

  @override
  State<AddSongPlaylis> createState() => _AddSongPlaylisState();
}

class _AddSongPlaylisState extends State<AddSongPlaylis> {
  final songs = FirebaseFirestore.instance.collection('Playlistsong');

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
                  child: SongSelectionPlaylist(PlaylistID: widget.playlistID),
                  type: PageTransitionType.fade,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      opacity: 0.6,
                      image: AssetImage('Assets/playlistbackgroundog.png'),
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
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            fit: BoxFit.cover,
                          )
                        : Container(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.playlistName ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          // gradient: LinearGradient(
                          //   begin: Alignment.bottomCenter,
                          //   end: Alignment.topCenter,
                          //   stops: [0.7, 1],
                          //   colors: [Colors.black, Color.fromARGB(83, 0, 13, 255)],
                          // ),
                          ),
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

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
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
                                  child: ListTile(
                                    splashColor: const Color.fromARGB(
                                        125, 255, 255, 255),
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
                                          fit: BoxFit.cover,
                                          height: 90,
                                          width: 50,
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
          height: 120,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  showEditDialog(context, document);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
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
    String playlistId = document['playlistID'];

    // Delete the song from Playlistsong collection
    songs.doc(songId).delete().then((value) {
      // Successfully deleted from Playlistsong

      // Now, delete the song from custumplaylistsong collection
      deleteSongFromCustomPlaylists(playlistId, songId);

      // Also, delete the song from the favourites collection
      deleteSongFromFavourites(songId);
    }).catchError((error) {
      // Handle error
    });
  }

  void deleteSongFromCustomPlaylists(String playlistId, String songId) {
    try {
      // Get a reference to the custumplaylistsong collection
      CollectionReference customPlaylistsongs =
          FirebaseFirestore.instance.collection('custumplaylistsong');

      // Delete the song from custumplaylistsong collection
      customPlaylistsongs
          .where('playlistID', isEqualTo: playlistId)
          .where('songID', isEqualTo: songId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete().then((value) {
            // Successfully deleted from custumplaylistsong
          }).catchError((error) {
            // Handle error
          });
        }
      }).catchError((error) {
        // Handle error
      });
    } catch (error) {
      // Handle error
    }
  }

  void deleteSongFromFavourites(String songId) {
    try {
      // Get a reference to the favourites collection
      CollectionReference favourites =
          FirebaseFirestore.instance.collection('favourites');

      // Delete the song from the favourites collection
      favourites.where('songID', isEqualTo: songId).get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete().then((value) {
            // Successfully deleted from favourites
          }).catchError((error) {
            // Handle error
          });
        }
      }).catchError((error) {
        // Handle error
      });
    } catch (error) {
      // Handle error
    }
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
                          ? Image.network(
                              newSelectedImage!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(newSelectedImage!),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                    else if (selectedImage != null && selectedImage!.isNotEmpty)
                      Image.network(
                        selectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
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
      songs.doc(songId).update({
        'title': newTitle,
        'image': newImageUrl,
      }).then((value) {
        // Successfully updated
      }).catchError((error) {
        // Failed to update
      });
    } else {
      songs.doc(songId).update({
        'title': newTitle,
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
}
