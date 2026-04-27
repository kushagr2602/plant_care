import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersCollection => _db.collection('users');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) => usersCollection.doc(uid);

  CollectionReference<Map<String, dynamic>> plantsCollection(String userId) =>
      userDoc(userId).collection('plants');

  DocumentReference<Map<String, dynamic>> plantDoc(String userId, String plantId) =>
      plantsCollection(userId).doc(plantId);

  DocumentReference<Map<String, dynamic>> healthDoc(String userId, String plantId) =>
      plantDoc(userId, plantId).collection('meta').doc('health');

  CollectionReference<Map<String, dynamic>> tasksCollection(String userId) =>
      userDoc(userId).collection('tasks');

  CollectionReference<Map<String, dynamic>> diagnosesCollection(String userId) =>
      userDoc(userId).collection('diagnoses');
}
