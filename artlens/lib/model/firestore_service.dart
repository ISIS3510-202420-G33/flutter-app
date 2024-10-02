import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Function to write a new document to a specified Firestore collection.
  /// [collectionName] is the name of the collection where the document will be written.
  /// [data] is a Map that contains the data to be added as the document body.
  Future<void> addDocument(String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
      print('Document added to $collectionName successfully');
    } catch (e) {
      print('Failed to add document: $e');
    }
  }
}
