// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/Model/functions/db_functions.dart';
import 'package:musicapp/Model/model/record_model.dart';
import 'package:musicapp/screens/MusicPlayer/record_audio_player.dart';
import 'package:musicapp/screens/UserScreen/RecordPage/RecordScreens/recorded_song.dart';
import 'package:musicapp/screens/refactoring/search_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final songs = FirebaseFirestore.instance.collection('NewRecordSong');
  final recorder = FlutterSoundRecorder();
  TextEditingController namecontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isRecorderReady = false;
  bool recording = false;
  late SharedPreferences _prefs;
  int c = 0;
  final pathtosaveaudio = 'sifbw';
  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    initRecord();
    getAllRecords();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    c = _prefs.getInt('recordCounter') ?? 0;
  }

  Future<void> saveRecordCounter() async {
    await _prefs.setInt('recordCounter', c);
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'hai$c');
    setState(() {
      recording = true;
    });
  }

  Future stop() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();

    setState(() {
      recording = false;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                  controller: namecontroller,
                  decoration: const InputDecoration(
                      label: Text('Record Name'),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please fill the field';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
            TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveRecordedSong(path: path!, name: namecontroller.text);
                    saveRecordCounter();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Audio Saved To Library'),
                          duration: Duration(milliseconds: 700)),
                    );
                  }
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
          ],
        );
      },
    );
  }

  Future<void> initRecord() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('Permission Is not Granted'),
          );
        },
      );
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        color: const Color.fromARGB(111, 0, 0, 0),
        height: 80,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            recording == true
                ? StreamBuilder<RecordingDisposition>(
                    stream: recorder.onProgress,
                    builder: (context, snapshot) {
                      final duration = snapshot.hasData
                          ? snapshot.data!.duration
                          : Duration.zero;

                      String twoDigits(int n) => n.toString().padLeft(2, '0');
                      final twoDigitMinutes =
                          twoDigits(duration.inMinutes.remainder(60));
                      final twoDigitSeconds =
                          twoDigits(duration.inSeconds.remainder(60));

                      return Text(
                        '$twoDigitMinutes:$twoDigitSeconds',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () async {
                c++;
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }
                setState(() {});
              },
              icon: Icon(
                recorder.isRecording ? Icons.stop : Icons.mic,
                color: const Color.fromARGB(255, 0, 0, 0),
                size: 60,
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
              ),
              iconSize: 20,
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'RECORD',
                        style: GoogleFonts.roboto(
                            fontSize: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    circleAvatar(circleradius: 20, iconsize: 30),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                        'Recorded Audio',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 195, 255),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<List<RecordModel>>(
                  valueListenable: recordlistNotifier,
                  builder: (context, value, child) {
                    if (value.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Audio Found',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        final data = value[index];

                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return RecordedPlayer(
                                    path: data.recordPath,
                                    audioname: data.recordName,
                                  );
                                },
                              ),
                            );
                          },
                          title: Text(
                            data.recordName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          leading: SizedBox(
                            width: 60,
                            height: 60,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSt5HwsaeGatj563CgNZDgJuKf36FuJc-wpA&usqp=CAU',
                                height: 90,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                showOption(
                                    audioname: data.recordName,
                                    id: data.id!,
                                    path: data.recordPath,
                                    context: context);
                              },
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              )),
                        );
                      },
                      itemCount: value.length,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'Available Lyrics',
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 195, 255),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                height: 200,
                width: double.infinity,
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
                        'No Lyrics found',
                        style: TextStyle(color: Colors.white),
                      ));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var document = snapshot.data!.docs[index];
                        var songName = document['title'];
                        var songimage = document['image'];
                        return SongTile(
                          songImage: songimage,
                          songName: songName,
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
    );
  }

  void saveRecordedSong({required String path, required String name}) {
    final audio = RecordModel(
      recordName: name,
      recordPath: path,
    );
    recordedSong(audio);
    namecontroller.clear();
  }
}

class SongTile extends StatefulWidget {
  final String? songName;
  final String? songImage;

  const SongTile({super.key, this.songName, this.songImage});

  @override
  _SongTileState createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.only(top: 20),
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = value;
          });
        },
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        maintainState: true,
        leading: SizedBox(
          width: 60,
          height: 60,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: widget.songImage ?? '',
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
        title: Text(
          widget.songName ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        children: [
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: SongLyrics(songId: widget.songName),
            ),
          IconButton(
            onPressed: () {
              setState(
                () {
                  isExpanded = false;
                },
              );
            },
            icon: const Icon(
              Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class SongLyrics extends StatelessWidget {
  final String? songId;

  const SongLyrics({super.key, this.songId});

  @override
  Widget build(BuildContext context) {
    final lyrics = FirebaseFirestore.instance.collection('SongLyrics');

    return StreamBuilder(
      stream: lyrics.where('lyricsID', isEqualTo: songId).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No Lyrics Found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        var document = snapshot.data!.docs.first;
        var songLyrics = document['lyrics'];
        var singerName = document['singername'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '-$singerName',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              songLyrics,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        );
      },
    );
  }
}
