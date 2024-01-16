// ignore_for_file: file_names, empty_catches

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/screens/MusicPlayer/music_player.dart';

class AdminAll extends StatefulWidget {
  const AdminAll({super.key});

  @override
  State<AdminAll> createState() => _AdminAllState();
}

class _AdminAllState extends State<AdminAll> {
  final songs = FirebaseFirestore.instance.collection('Playlistsong');
  List<DocumentSnapshot> songList = [];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
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
                  songList = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      var songName = document['title'];
                      var songimage = document['image'];
                      // String songimage = document['selected image'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MusicPlayer(
                                          songList: songList,
                                          currentIndex: index,
                                          iconNeeded: false),
                                    ));
                              },
                              visualDensity: const VisualDensity(
                                horizontal: 0.9,
                                vertical: 0.9,
                              ),
                              splashColor:
                                  const Color.fromARGB(125, 255, 255, 255),
                              enabled: true,
                              title: Text(
                                songName,
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
                              trailing: IconButton(
                                  onPressed: () {
                                    showPopupMenu(context, document);
                                  },
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ))),
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
    songs.doc(songId).delete().then((value) {}).catchError((error) {});
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
