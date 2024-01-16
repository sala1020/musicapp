// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LocalMusicPlayer extends StatefulWidget {
  final List<SongModel> songList;
  int currentIndex;

  LocalMusicPlayer({
    super.key,
    required this.songList,
    required this.currentIndex,
  });

  @override
  State<LocalMusicPlayer> createState() => _LocalMusicPlayerState();
}

class _LocalMusicPlayerState extends State<LocalMusicPlayer>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  late AnimationController iconcontroller;

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
    player.setSourceUrl(currentSong.data);
    // player.setSourceDeviceFile(currentSong['Selectedsong']);

    player.onDurationChanged.listen((Duration d) {
      setState(() {
        duration = d;
      });
    });

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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedPosition = formatDuration(position);
    final formattedDuration = formatDuration(duration);
    var currentSong = widget.songList[widget.currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://imgs.search.brave.com/8drk8xl5gApjJsbqjemH8BHv6sf9p4Ya9jppWHgr8d8/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9jZG4u/cGl4YWJheS5jb20v/cGhvdG8vMjAxNS8w/My8wOC8xNy8yNS9t/dXNpY2lhbi02NjQ0/MzJfNjQwLmpwZw',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                currentSong.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: SliderTheme(
                  data: const SliderThemeData(
                    overlayColor: Colors.white,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    thumbColor: Colors.white,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
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
              Padding(
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
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      player.seek(Duration(seconds: position.inSeconds - 4));
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
                          await player.play(DeviceFileSource(currentSong.data));
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
                      player.seek(Duration(seconds: position.inSeconds + 4));
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
}
