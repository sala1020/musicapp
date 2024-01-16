// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:musicapp/Model/model/record_model.dart';

ValueNotifier<List<RecordModel>> recordlistNotifier = ValueNotifier([]);

void recordedSong(RecordModel value) async {
  final recordDB = await Hive.openBox<RecordModel>('record_db');
  // final int id = await recordDB.add(value);
  final timekey = DateTime.now().millisecondsSinceEpoch.toString();
  value.id = timekey;
  // recordlistNotifier.value.add(value);
  recordDB.put(timekey, value);
  recordlistNotifier.notifyListeners();
}

Future<void> getAllRecords() async {
  final recordDB = await Hive.openBox<RecordModel>('record_db');
  recordlistNotifier.value.clear();
  recordlistNotifier.value.addAll(recordDB.values);
  recordlistNotifier.notifyListeners();
}

Future<void> delete(String id) async {
  final recordDB = await Hive.openBox<RecordModel>('record_db');
  await recordDB.delete(id);
  getAllRecords();
}

void edit(RecordModel value) async {
  final recordDB = await Hive.openBox<RecordModel>('record_db');
  await recordDB.put(value.id!, value);

  int index =
      recordlistNotifier.value.indexWhere((element) => element.id == value.id);
  recordlistNotifier.value[index] = value;

  recordlistNotifier.notifyListeners();
  getAllRecords();
}
