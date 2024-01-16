
import 'package:hive/hive.dart';
part 'record_model.g.dart';

@HiveType(typeId: 1)
class RecordModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  final String recordName;

  @HiveField(2)
  final String recordPath;

  RecordModel({required this.recordName, required this.recordPath, this.id});
}
