// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicapp/Model/model/record_model.dart';

void asyncFunction(RecordModel value, BuildContext context) async {
  var recordbox = await Hive.openBox<RecordModel>('record');
  bool isalreadyexist=  recordbox.containsKey(value.id);
  if(!isalreadyexist){
    
  }
}
