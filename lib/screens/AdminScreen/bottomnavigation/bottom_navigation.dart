import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp/screens/AdminScreen/admin.dart';
import 'package:musicapp/screens/AdminScreen/admin_record.dart';

class AdminBottomNav extends StatefulWidget {
  const AdminBottomNav({super.key});

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav> {
  int _selectedIndex = 0;
  final _pages = [const Admin(), const LyricalMusic()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.white,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          enableFeedback: false,
          selectedFontSize: 15,
          selectedLabelStyle: GoogleFonts.aBeeZee(),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedIconTheme: const IconThemeData(size: 30),
          unselectedItemColor: const Color.fromARGB(255, 33, 222, 243),
          unselectedFontSize: 15,
          unselectedIconTheme: const IconThemeData(size: 20),
          unselectedLabelStyle: GoogleFonts.novaSlim(),
          currentIndex: _selectedIndex,
          onTap: (newindex) {
            setState(() {
              _selectedIndex = newindex;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.music), label: 'Record'),
          ]),
    );
  }
}
