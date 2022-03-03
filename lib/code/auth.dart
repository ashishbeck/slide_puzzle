import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
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
    final userData = UserData.newUser(
        uid, generateWordPairs(maxSyllables: 4).first.asPascalCase);
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

  submitDummyCommunityScores() {
    final List<ChartData> chartData = [
      ChartData(7, 0),
      ChartData(8, 5),
      ChartData(9, 14),
      ChartData(10, 35),
      ChartData(11, 42),
      ChartData(12, 56),
      ChartData(13, 76),
      ChartData(14, 97),
      ChartData(15, 124),
      ChartData(16, 159),
      ChartData(17, 146),
      ChartData(18, 124),
      ChartData(19, 97),
      ChartData(20, 76),
      ChartData(21, 56),
      ChartData(22, 34),
      ChartData(23, 19),
      ChartData(24, 0),
    ];
    Map<String, int> data = {};
    chartData.forEach((e) => data.addAll(e.toFirestore()));

    _firestore
        .collection("testcommunity")
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

  Stream<List<LeaderboardItem>> fetchLeaderBoards(String grid) {
    var times = _firestore
        .collection("users")
        .orderBy("times.$grid", descending: false)
        .where("times.$grid", isNotEqualTo: 0)
        .limit(20)
        .snapshots()
        .map((event) => event.docs
            .map((e) => LeaderboardItem.fromMap(e.data(), grid))
            .toList());
    return times;
    // var moves =
    //     (await _firestore.collection("testcommunity").doc("moves").get())
    //         .data();
    // times.forEach((element) {
    //   print(element.data());
    // });
  }
}
