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

  submitDummyCommunityScores(List<ChartData> chartData) {
    Map<String, int> data = {};
    chartData.forEach((e) => data.addAll(e.toFirestore()));

    _firestore
        .collection("community")
        .doc("times")
        .set({"three": data}, SetOptions(merge: true));
  }

  Future<CommunityScores> fetchCommunityScores() async {
    var times =
        (await _firestore.collection("community").doc("times").get()).data();
    var moves =
        (await _firestore.collection("community").doc("moves").get()).data();
    Map<String, List<ChartData>> newMoves = {};
    Map<String, List<ChartData>> newTimes = {};
    moves!.forEach((key1, value1) {
      Map<String, int> values = Map<String, int>.from(value1);
      List<ChartData> data = [];
      values.forEach((key2, value2) {
        data.add(ChartData.fromFirestore({key2: value2}));
      });
      newMoves.addAll({key1: data});
    });
    times!.forEach((key1, value1) {
      Map<String, int> values = Map<String, int>.from(value1);
      List<ChartData> data = [];
      values.forEach((key2, value2) {
        data.add(ChartData.fromFirestore({key2: value2}));
      });
      newTimes.addAll({key1: data});
    });
    CommunityScores scores = CommunityScores(
      moves: newMoves,
      times: newTimes,
    );
    return scores;
  }
}
