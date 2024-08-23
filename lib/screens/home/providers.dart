import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/providers.dart';
import 'package:smproject3/screens/home/pages/pagehome.dart';
import 'package:smproject3/screens/home/pages/pageshare.dart';
import 'package:smproject3/screens/home/pages/pageprofile.dart';
import 'package:smproject3/screens/home/pages/pagemassenger.dart';

final selectedUserProvider = StateProvider<List<UserClass>>((ref) => []);

final searchListProvider = StateProvider<List<UserClass>>((ref) => []);

final userProvider = StreamProvider<User?>((ref) {
  return ref.watch(auth).authStateChanges();
});

final userDocumentProvider = StreamProvider<UserClass?>(
  (ref) {
    var uid = ref.watch(userProvider).value!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserClass.fromSnapshot(snapshot));
  },
);

final pageNoProvider = StateProvider((ref) => 0);

final sharedChangeProvider = StateProvider((ref) => 0);

final pageControlProvider = Provider(
  (ref) => PageController(
    initialPage: 0,
    keepPage: true,
  ),
);

final pageControl2Provider = Provider(
  (ref) => PageController(
    initialPage: 0,
    keepPage: true,
  ),
);

final pagesProvider = Provider(
  (ref) => [
    const HomePage(),
    SharePage(),
    const MessangerPage(),
    const ProfilePage(),
  ],
);

class DesignsHome {
  List bNbColor = [
    Colors.blueGrey,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.indigo,
  ];

  List bNbIcon = [
    Icons.home,
    Icons.search_outlined,
    Icons.add_circle_outline,
    Icons.message_outlined,
    Icons.person_3_outlined,
  ];

  List<Widget> bNBButtons() {
    return List.generate(
      5,
      (index) => Icon(
        bNbIcon[index],
        color: bNbColor[index],
        size: 25,
      ),
    );
  }
}

final usernameProvider = StateProvider((ref) => "");
final nameProvider = StateProvider((ref) => "");
final surnameProvider = StateProvider((ref) => "");

final bioProvider = StateProvider((ref) => "");

final stepProvider = StateProvider((ref) => 0);
final pageControllerProvider = StateProvider((ref) => PageController());
