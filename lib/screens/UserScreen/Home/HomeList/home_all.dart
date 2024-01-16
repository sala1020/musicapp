import 'package:flutter/material.dart';
import 'package:musicapp/screens/UserScreen/Home/HomeList/online_song_all.dart';

class HomeAll extends StatelessWidget {
  const HomeAll({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: const Padding(
          padding: EdgeInsets.all(15.0),
          child: SizedBox(
              height: 450, width: double.infinity, child: OnlineSong()),
        ),
      ),
    );
  }
}
