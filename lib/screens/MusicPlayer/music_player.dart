// ignore_for_file: must_be_immutable, unnecessary_null_comparison, non_constant_identifier_names, use_build_context_synchronously

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MusicPlayer extends StatefulWidget {
  final List<DocumentSnapshot> songList;
  int currentIndex;
  String? idd;
  bool iconNeeded;

  MusicPlayer(
      {super.key,
      this.idd,
      required this.songList,
      required this.currentIndex,
      required this.iconNeeded});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool clicked = false;
  bool isFavourite = true;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController iconcontroller;
  String? current;
  bool isDurationLoaded = false;

  @override
  void dispose() {
    player.dispose();
    iconcontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    iconcontroller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    var currentSong = widget.songList[widget.currentIndex];

    player.setSourceUrl(currentSong['Selectedsong']);
    // player.setSourceDeviceFile(currentSong['Selectedsong']);
    current = currentSong['title'];
    player.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
        isDurationLoaded = true;
      });
    });
    checkingExistence(UserID: currentUserId, name: current);

    player.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        isPlaying = state == PlayerState.playing ? true : false;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        iconcontroller.forward();
        // Automatically play the next song when the current song completes
        // _playNextSong();
      });
      _playNextSong();
    });
  }

  void _playNextSong() async {
    if (widget.currentIndex < widget.songList.length - 1) {
      int nextIndex = widget.currentIndex + 1;
      var nextSong = widget.songList[nextIndex];
      checkingExistence(UserID: currentUserId, name: nextSong['title']);

      await player.stop();
      iconcontroller.forward();
      await player.play(UrlSource(nextSong['Selectedsong']));

      setState(() {
        widget.currentIndex = nextIndex;
      });
    } else {
      var firstSong = widget.songList.first;
      checkingExistence(UserID: currentUserId, name: firstSong['title']);

      await player.stop();
      iconcontroller.forward();
      await player.play(UrlSource(firstSong['Selectedsong']));

      setState(() {
        widget.currentIndex = 0;
      });
    }
  }

  void _playPreviousSong() async {
    if (widget.currentIndex > 0) {
      int previousIndex = widget.currentIndex - 1;
      var previousSong = widget.songList[previousIndex];
      checkingExistence(UserID: currentUserId, name: previousSong['title']);

      await player.stop();
      iconcontroller.forward();
      await player.play(UrlSource(previousSong['Selectedsong']));

      setState(() {
        widget.currentIndex = previousIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPosition = formatDuration(position);
    final formattedDuration = formatDuration(duration);
    var currentSong = widget.songList[widget.currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              colorFilter: ColorFilter.srgbToLinearGamma(),
              image: AssetImage('Assets/musicplayer.webp'),
              fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 40,
                    blurStyle: BlurStyle.normal)
              ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: currentSong['image'],
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentSong['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            widget.iconNeeded == true
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () async {
                            addToFavourite(
                                userid: currentUserId,
                                image: currentSong['image'],
                                title: currentSong['title'],
                                song: currentSong['Selectedsong']);

                          },
                          icon: Icon(
                            clicked == false
                                ? FontAwesomeIcons.heart
                                : Icons.favorite,
                            color: clicked==false?Colors.white:const Color.fromARGB(255, 255, 0, 0),
                          )),
                    ],
                  )
                : const SizedBox.shrink(),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: SliderTheme(
                data: const SliderThemeData(
                  overlayColor: Colors.white,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  min: 0,
                  max: duration.inSeconds
                      .toDouble(), // Set max to the total duration of the song
                  value: position.inSeconds
                      .toDouble()
                      .clamp(0, duration.inSeconds.toDouble()),
                  onChanged: (value) async {
                    final newPosition = Duration(seconds: value.toInt());
                    await player.seek(newPosition);
                    await player.resume();
                    setState(() {
                      iconcontroller.forward();
                    });
                  },
                ),
              ),
            ),
            isDurationLoaded
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedPosition,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    player.seek(Duration(seconds: position.inSeconds - 10));
                    iconcontroller.forward();
                    if (!isPlaying) {
                      player.resume();
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.fast_rewind),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    _playPreviousSong();
                  },
                  icon: const Icon(Icons.skip_previous),
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 20,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () async {
                      if (isPlaying) {
                        iconcontroller.reverse();
                        await player.pause();
                      } else {
                        iconcontroller.forward();
                        await player.play(
                            DeviceFileSource(currentSong['Selectedsong']));
                      }
                    },
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: iconcontroller,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  onPressed: () {
                    _playNextSong();
                  },
                  icon: const Icon(Icons.skip_next),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    player.seek(Duration(seconds: position.inSeconds + 10));
                    iconcontroller.forward();
                    if (!isPlaying) {
                      player.resume();
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.fast_forward),
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    return duration != null
        ? '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
        : '00:00';
  }

  void animatedIcon() {
    setState(() {
      isPlaying = !isPlaying;

      if (isPlaying) {
        iconcontroller.forward();
      } else {
        iconcontroller.reverse();
      }
    });
  }

  void checkingExistence({
    String? name,
    String? UserID,
  }) async {
    QuerySnapshot<Map<String, dynamic>> existingSongs = await FirebaseFirestore
        .instance
        .collection('Favourites')
        .where('title', isEqualTo: name)
        .where('UserID', isEqualTo: UserID)
        .get();

    if (existingSongs.docs.isNotEmpty) {
      setState(() {
        clicked = true;
      });
    } else {
      setState(() {
        clicked = false;
      });
    }
  }

  void addToFavourite({
    String? song,
    String? title,
    String? image,
    String? userid,
  }) async {
    // Check if the song already exists in the "Favourites" collection
    bool songExists = await checkIfSongExists(song: song, userid: userid);

    if (!songExists) {
      // If the song doesn't exist, add it to the "Favourites" collection
      await FirebaseFirestore.instance.collection('Favourites').add({
        'Selectedsong': song,
        'UserID': currentUserId,
        'image': image,
        'title': title,
      });

      setState(() {
        clicked = true;
      });
    } else {
      setState(() {
        clicked = false;
      });

      deleteFromCollection(widget.idd);
    }
  }

  Future<bool> checkIfSongExists({String? song, String? userid}) async {
    QuerySnapshot<Map<String, dynamic>> existingSongs = await FirebaseFirestore
        .instance
        .collection('Favourites')
        .where('Selectedsong', isEqualTo: song)
        .where('UserID', isEqualTo: userid)
        .get();
    if (existingSongs.docs.isNotEmpty) {
      setState(() {
        clicked = true;
      });
    } else {
      setState(() {
        clicked = false;
      });
    }

    return existingSongs.docs.isNotEmpty;
  }

  void deleteFromCollection(String? id) async {

    // Retrieve the document with the given ID from the 'Favourites' collection
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('Favourites').doc(id).get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // The document exists, proceed with deletion
      await FirebaseFirestore.instance
          .collection('Favourites')
          .doc(id)
          .delete();
      setState(() {
        clicked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Song Removed From Favourites'),
            duration: Duration(milliseconds: 700)),
      );
    } else {
      // The document does not exist, handle accordingly (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You Can't Unfavourite From Here"),
            duration: Duration(milliseconds: 700)),
      );
      setState(() {
        clicked = true;
      });
    }
  }
}
