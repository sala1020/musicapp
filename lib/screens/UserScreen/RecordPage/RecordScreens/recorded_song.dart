import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:musicapp/Model/functions/db_functions.dart';
import 'package:musicapp/Model/model/record_model.dart';
import 'package:musicapp/screens/MusicPlayer/record_audio_player.dart';

class RecordedAudio extends StatefulWidget {
  const RecordedAudio({super.key});

  @override
  State<RecordedAudio> createState() => _RecordedAudioState();
}

class _RecordedAudioState extends State<RecordedAudio> {
  @override
  void initState() {
    super.initState();
    getAllRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 0, 242, 255)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.7, 1],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 200,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Recorded Audio',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
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
                              Navigator.pop(context);
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
          ],
        ),
      ),
    );
  }
}

void showOption(
    {required String audioname,
    required String id,
    required String path,
    required BuildContext context}) async {
  TextEditingController editedtext = TextEditingController(text: audioname);
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Column(
                        children: [
                          TextField(
                            controller: editedtext,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () {
                                    if (editedtext.text.isNotEmpty) {
                                      RecordModel editedRecord = RecordModel(
                                          id: id,
                                          recordName: editedtext.text,
                                          recordPath: path
                                          // Set other properties accordingly
                                          );
                                      edit(editedRecord);
                                    }
                                    Navigator.pop(
                                        context); // Close the inner dialog
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save')),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              splashColor: Colors.grey[400],
              title: const Text('Edit'),
              trailing: const Icon(Icons.edit),
            ),
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                          'Are you sure you want to delete the audio'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              delete(id);
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
              splashColor: Colors.grey[400],
              title: const Text('Delete'),
              trailing: const Icon(Icons.delete),
            )
          ],
        ),
      );
    },
  );
}
