// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:musicapp/screens/MusicPlayer/local_music_player.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LocalPlaylistItems extends StatefulWidget {
  const LocalPlaylistItems({super.key});

  @override
  State<LocalPlaylistItems> createState() => _LocalPlaylistItemsState();
}

class _LocalPlaylistItemsState extends State<LocalPlaylistItems> {
  final _audioQuery = OnAudioQuery();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();

    checkAndRequestPermissions();
  }

  checkAndRequestPermissions({bool retry = false}) async {
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );

    _hasPermission ? setState(() {}) : null;
  }

  @override
  Widget build(BuildContext context) {
    return !_hasPermission
        ? noAccessToLibraryWidget()
        : FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
              sortType: null,
              orderType: OrderType.DESC_OR_GREATER,
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<SongModel> mp3Files = snapshot.data!.where((song) {
                print(song.fileExtension);
                return song.fileExtension.toLowerCase().endsWith('mp3');
              }).toList();

              if (mp3Files.isEmpty) {
                return const Center(
                  child: Text('No mp3 Found',
                      style: TextStyle(color: Colors.white)),
                );
              }

              return ListView.builder(
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return LocalMusicPlayer(songList: mp3Files, currentIndex: index);
                    }));
                  },
                  child: ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(
                      mp3Files[index].title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(mp3Files[index].fileExtension),
                    trailing: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                ),
                itemCount: mp3Files.length,
              );
            },
          );
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => checkAndRequestPermissions(retry: true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}
