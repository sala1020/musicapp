import 'package:flutter/material.dart';

Widget normalTextField(
  // TextEditingController searchcontroller
) {
  return const Padding(
    padding: EdgeInsets.all(20.0),
    child: TextField(
      
      textInputAction: TextInputAction.search,
      autocorrect: true,
      style: TextStyle(color: Colors.white, fontSize: 20),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        prefixIconColor: Colors.white,
        label: Text('SEARCH'),
        floatingLabelStyle: TextStyle(
          color: Colors.blue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          borderSide: BorderSide(
            width: 3,
            color: Color.fromARGB(174, 255, 255, 255),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          borderSide: BorderSide(width: 3, color: Colors.white),
        ),
      ),
    ),
  );
}
