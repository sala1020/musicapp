import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  String about='''

About Our Music Player App

Welcome to Saluzzy, your go-to destination for a personalized and immersive music experience. We've curated a vast collection of online music, diverse playlists, and innovative features to make your musical journey truly one-of-a-kind.

Key Features:

🎵 Extensive Music Library: Explore a rich and diverse library of songs spanning various genres, ensuring there's something for every musical taste.

🎧 Create Your Playlists: Unleash your creativity by crafting custom playlists tailored to your mood, occasion, or favorite artists. Build your musical world with just a few taps.

🔀 Collaborative Playlists: Collaborate with friends and other music enthusiasts to create playlists that reflect a shared musical vibe. Add and discover new tracks together.

🎤 Practice Mode: Elevate your musical skills with our unique Practice Mode. Access lyrics for selected songs, record your rendition, and save your creations for future playback.

📱 Recorded Audio Library: Your recorded masterpieces are stored in a dedicated folder within your library, making it easy to revisit and share your musical journey.

How It Works:

Explore: Dive into our extensive music catalog or discover handcrafted playlists to find your next favorite track.

Create: Build personalized playlists effortlessly. Add or remove songs, rearrange the order, and make each playlist uniquely yours.

Collaborate: Share your playlists with friends and invite them to contribute. Collaborate in real-time to curate the perfect collection.

Practice: Hone your singing skills with the Practice Mode. Access lyrics, record your performance, and enjoy a new dimension of musical expression.

Record & Save: Capture your musical moments by recording your renditions. Your recordings are neatly organized in the Recorded Audio Library for easy access.

Discover, create, and experience music like never before with Saluzzy. Download now and let the music play!
''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'About Us',
            style: GoogleFonts.muktaMalar(
                color: const Color.fromARGB(226, 255, 255, 255), fontSize: 24),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              about,
              style: GoogleFonts.muktaMalar(
                  color: const Color.fromARGB(226, 255, 255, 255), fontSize: 20),
            ),
          ),
        ));
  }
}
