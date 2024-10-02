import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Function to write a new document to a specified Firestore collection.
  /// Returns the document ID as a String.
  Future<String> addDocument(String collectionName, Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _firestore.collection(collectionName).add(data);
      print('Document added to $collectionName with ID: ${docRef.id}');
      return docRef.id;  // Return the document ID as String
    } catch (e) {
      print('Failed to add document: $e');
      rethrow;
    }
  }

  /// Function to delete a document from a specified Firestore collection by its document ID.
  Future<void> deleteDocument(String collectionName, String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
      print('Document with ID: $documentId deleted from $collectionName');
    } catch (e) {
      print('Failed to delete document: $e');
    }
  }
}
