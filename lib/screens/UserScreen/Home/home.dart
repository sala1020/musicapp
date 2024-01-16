import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/home_all.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/home_playlist.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool clicked = true;
  bool clicked1 = false;
  List<List<Widget>> myPages = [
    [const HomeAll()],
    [const HomePlaylist()]
  ];
  List<String> choiceChips = ["All", "PlayList"];
  List<Widget> displayedSongs = [];

  bool showSearchTextField = true;

  @override
  void initState() {
    super.initState();
    displayedSongs = myPages[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Color.fromARGB(255, 100, 101, 101),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'SALUZZY',
                        style: GoogleFonts.wallpoet(
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (showSearchTextField)
                      const SizedBox(
                        height: 15,
                      ),
                    Row(
                      children: List.generate(choiceChips.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: ChoiceChip(
                            showCheckmark: false,
                            selectedColor:
                                const Color.fromARGB(255, 33, 222, 243),
                            label: Text(choiceChips[index]),
                            selected: (clicked && index == 0) ||
                                (clicked1 && index == 1),
                            onSelected: (t) {
                              setState(() {
                                clicked = index == 0;
                                clicked1 = index == 1;
                                displayedSongs = myPages[index];
                                showSearchTextField = index == 0;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                    // const Divider(
                    //   thickness: 1,
                    //   color: Color.fromARGB(133, 255, 255, 255),
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: displayedSongs.length,
                itemBuilder: (context, index) {
                  return displayedSongs[index];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
