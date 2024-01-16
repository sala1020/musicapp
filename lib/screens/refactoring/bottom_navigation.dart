import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/UserScreen/AboutPage/about_page.dart';
import 'package:musicapp/screens/UserScreen/Library/library.dart';
import 'package:musicapp/screens/UserScreen/RecordPage/record_page.dart';
import 'package:musicapp/screens/UserScreen/SearchPage/search_page.dart';
import 'package:musicapp/screens/UserScreen/Home/home.dart';
import 'package:musicapp/screens/UserScreen/SearchPage/searching.dart';

class MiniplayerVisibility extends ValueNotifier<bool> {
  MiniplayerVisibility(super.value);
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  bool clicked = true;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const Home(),
      const LibraryPage(),
      clicked ? const SearchPage() : Searching(nav: false),
      const RecordPage(),
      const AboutPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: const Color.fromARGB(197, 0, 255, 255),
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        enableFeedback: false,
        selectedFontSize: 15,
        selectedLabelStyle: GoogleFonts.aBeeZee(),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedItemColor: Colors.white,
        unselectedFontSize: 15,
        unselectedIconTheme: const IconThemeData(size: 20),
        unselectedLabelStyle: GoogleFonts.novaSlim(),
        currentIndex: _selectedIndex,
        onTap: (newindex) {
          if (_selectedIndex == newindex) {
            switch (newindex) {
              case 2:
                setState(() {
                  clicked = !clicked;
                });
                break;
            }
          } else {
            setState(() {
              _selectedIndex = newindex;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.music), label: 'Library'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size: 25,
              ),
              label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.mic,
              ),
              label: 'Record'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'About'),
        ],
      ),
    );
  }
}
