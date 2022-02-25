import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slide_puzzle/code/models.dart';

class AuthService {
  // static final AuthService instance = AuthService._init();
  // AuthService._init();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?>? user;

  AuthService() {
    user = _auth.authStateChanges();
  }

  signInAnonymously() async {
    print("signing in");
    UserCredential userCredential = await _auth.signInAnonymously();
    if (userCredential.additionalUserInfo!.isNewUser) {
      DatabaseService.instance.createUser(userCredential.user!.uid);
    } else {
      DatabaseService.instance.updateLastSeen(userCredential.user!.uid);
    }
    return userCredential;
  }
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  createUser(String uid) {
    print("creating user");
    final userData = UserData.newUser(uid);
    // UserData(uid: uid, move3: 0, time3: 0, lastSeen: Timestamp.now());
    _firestore.collection("users").doc(uid).set(userData.toMap());
  }

  updateUserData(UserData userData) {
    _firestore.collection("users").doc(userData.uid).set(userData.toMap());
  }

  updateLastSeen(String uid) {
    _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "lastSeen": Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<UserData?> currentUser(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((event) => UserData.fromMap((event.data()!)));
  }
}
