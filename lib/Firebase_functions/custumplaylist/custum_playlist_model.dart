class CustomPlaylistModel {
  final String documentID; // Added field for document ID
  final String playlistID;
  final String title;
  final String image;
  final String userID;

  CustomPlaylistModel({
    required this.documentID,
    required this.playlistID,
    required this.title,
    required this.image,
    required this.userID,
  });

  factory CustomPlaylistModel.fromMap(
      String documentID, Map<String, dynamic> map) {
    return CustomPlaylistModel(
      documentID: documentID,
      playlistID: map['playlistID'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      userID: map['UserID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlistID': playlistID,
      'title': title,
      'image': image,
      'UserID': userID,
    };
  }
}