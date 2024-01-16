import 'package:flutter/material.dart';

class GridViewList extends StatelessWidget {
  const GridViewList({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 10 / 4,
          mainAxisSpacing: 5,
          crossAxisSpacing: 15),
      padding: const EdgeInsets.only(
        top: 10,
        right: 10,
        left: 10,
      ),
      children: [
        InkWell(
          child: gridview(
            text: 'POP',
          ),
        ),
        InkWell(
          child: gridview(
            text: 'Trance',
          ),
        ),
        InkWell(
          child: gridview(
            text: 'Local',
          ),
        ),
        InkWell(
          child: gridview(
            text: 'Melody',
          ),
        ),
        InkWell(
          child: gridview(
            text: 'Lofi',
          ),
        ),
        InkWell(
          child: gridview(
            text: 'Favorite',
          ),
        ),
      ],
    );
  }
}

Widget gridview({String? text}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
            fit: BoxFit.cover,
            opacity: 0.9,
            image: NetworkImage(
                'https://img.freepik.com/free-photo/acoustic-guitar-chair-close-up-brown-guitar-black-wall_1150-21884.jpg?size=626&ext=jpg&ga=GA1.1.795691753.1701772169&semt=sph'))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          text!,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 22, color: Colors.white),
        ),
      ],
    ),
  );
}
