import 'package:cloud_firestore/cloud_firestore.dart';


class CloudDb {
  // final FirebaseFirestore db = FirebaseFirestore.instance;
  // Lazy initialization - only access Firestore when db is first accessed
  FirebaseFirestore get db => FirebaseFirestore.instance;
}
