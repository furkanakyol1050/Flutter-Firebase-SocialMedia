import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/home/providers.dart';

final chatProvider = StateProvider((ref) => 0);
final reciverUidProvider = StateProvider((ref) => "");
final reciverProvider = StateProvider((ref) => UserClass.empty());

class MessangerPage extends ConsumerWidget {
  const MessangerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: const Color.fromRGBO(23, 23, 23, 1),
      child: Column(
        children: [
          Container(
            color: const Color.fromRGBO(23, 23, 23, 1),
            height: size.height * 0.15,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: size.height * 0.06,
                  child: Text(
                    "Mesajlar",
                    style: GoogleFonts.nunito(
                      color: const Color.fromRGBO(237, 237, 237, 1),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            height: size.height * 0.85,
            padding: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(237, 237, 237, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showFriendsList(context, ref);
                  },
                  style: ButtonStyle(
                    overlayColor: const MaterialStatePropertyAll(Colors.white),
                    minimumSize: MaterialStatePropertyAll(
                      Size(size.width * 0.8, size.height * 0.055),
                    ),
                    backgroundColor: const MaterialStatePropertyAll(
                      Color.fromRGBO(68, 68, 68, 1),
                    ),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  child: Text(
                    'Arkadaşlar',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                StreamBuilder<List<UserClass>>(
                  stream: getFriendsStream(
                      FirebaseAuth.instance.currentUser!.uid, 1),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<UserClass>> snapshot) {
                    var userDocument =
                        ref.watch(userDocumentProvider).asData?.value;
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        userDocument == null) {
                      return Container(
                        alignment: Alignment.center,
                        height: size.height * 0.3,
                        child: const SpinKitFadingCube(
                          color: Colors.grey,
                          size: 50.0,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<UserClass> users = snapshot.data ?? [];
                      return Container(
                        width: size.width * 0.9,
                        alignment: Alignment.center,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.isEmpty ? 1 : users.length,
                          itemBuilder: (BuildContext context, int index) {
                            return users.isNotEmpty
                                ? Slidable(
                                    startActionPane: ActionPane(
                                      extentRatio: 0.2,
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                            left: 10,
                                          ),
                                          onPressed:
                                              (BuildContext context) async {
                                            userDocument.chats.removeAt(index);
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userDocument.uid)
                                                .update(userDocument.toJson());
                                          },
                                          backgroundColor: Colors.red.shade400,
                                          foregroundColor: const Color.fromRGBO(
                                              237, 237, 237, 1),
                                          icon: Icons.delete,
                                          autoClose: true,
                                        ),
                                      ],
                                    ),
                                    child: FriendsListWidget(
                                      users: users,
                                      userDocument: userDocument,
                                      index: index,
                                      process: 1,
                                    ),
                                  )
                                : Container(
                                    height: 80,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(10),
                                    child: Text(
                                      "Aktif Sohbetin Yok",
                                      style: GoogleFonts.nunito(
                                        color:
                                            const Color.fromRGBO(23, 23, 23, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showFriendsList(BuildContext context, WidgetRef ref) {
  final size = MediaQuery.of(context).size;
  showModalBottomSheet<void>(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder<List<UserClass>>(
        stream: getFriendsStream(FirebaseAuth.instance.currentUser!.uid, 0),
        builder:
            (BuildContext context, AsyncSnapshot<List<UserClass>> snapshot) {
          var userDocument = ref.watch(userDocumentProvider).asData?.value;
          if (snapshot.connectionState == ConnectionState.waiting ||
              userDocument == null) {
            return Container(
              alignment: Alignment.center,
              height: size.height * 0.3,
              child: const SpinKitFadingCube(
                color: Colors.grey,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<UserClass> users = snapshot.data ?? [];
            return ListView.builder(
              shrinkWrap: true,
              itemCount: users.isEmpty ? 1 : users.length,
              itemBuilder: (BuildContext context, int index) {
                return users.isNotEmpty
                    ? FriendsListWidget(
                        users: users,
                        userDocument: userDocument,
                        index: index,
                        process: 0,
                      )
                    : Container(
                        height: 80,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          "Arkadaşın Yok",
                          style: GoogleFonts.nunito(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
              },
            );
          }
        },
      );
    },
  );
}

class FriendsListWidget extends ConsumerWidget {
  const FriendsListWidget({
    super.key,
    required this.users,
    required this.userDocument,
    required this.index,
    required this.process,
  });

  final List<UserClass> users;
  final UserClass? userDocument;
  final int index;
  final int process;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: const Color.fromRGBO(23, 23, 23, 1),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            // ignore: unnecessary_null_comparison
            image: users[index].photoUrl != null
                ? NetworkImage(users[index].photoUrl)
                : const AssetImage("assets/defUser.png") as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        users[index].username,
        style: GoogleFonts.nunito(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      subtitle: process == 0
          ? Text(
              "${users[index].name} ${users[index].surname}",
              style: GoogleFonts.nunito(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            )
          : Container(
              padding: const EdgeInsets.only(right: 150),
              child: Text(
                lastMessage(userDocument!, users, index),
                style: GoogleFonts.nunito(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
      onTap: () {
        bool check = false;
        if (process == 1) {
          for (var element in userDocument!.chats) {
            if (element.reciverUid == users[index].uid) {
              check = true;
              ref.read(chatProvider.notifier).state =
                  userDocument!.chats.indexOf(element);
              break;
            }
          }
          if (check == false) {
            ref.read(chatProvider.notifier).state = -1;
          }
          ref.read(reciverUidProvider.notifier).state = users[index].uid;
          ref.read(reciverProvider.notifier).state = users[index];
          Navigator.pushNamed(context, '/chat');
        } else {
          Navigator.pop(context);
          for (var element in userDocument!.chats) {
            if (element.reciverUid == users[index].uid) {
              check = true;
              ref.read(chatProvider.notifier).state =
                  userDocument!.chats.indexOf(element);
              break;
            }
          }
          if (check == false) {
            ref.read(chatProvider.notifier).state = -1;
          }
          ref.read(reciverUidProvider.notifier).state = users[index].uid;
          Navigator.pushNamed(context, '/chat');
        }
      },
    );
  }
}

String lastMessage(UserClass userDocument, List<UserClass> friends, int index) {
  ChatClass? targetChat;
  for (ChatClass chat in userDocument.chats) {
    if (chat.reciverUid == friends[index].uid) {
      targetChat = chat;
      break;
    }
  }
  if ((targetChat!.message1.isNotEmpty && targetChat.message2.isEmpty) ||
      ((targetChat.message1.isNotEmpty && targetChat.message2.isNotEmpty) &&
          DateTime.parse(targetChat.message1.last.date)
              .isBefore(DateTime.parse(targetChat.message2.last.date)))) {
    return "Siz : ${targetChat.message1.last.text}";
  } else {
    return "Karşı : ${targetChat.message2.last.text}";
  }
}

Stream<List<UserClass>> getFriendsStream(String uid, int process) async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      List<UserClass> users = [];

      if (documentSnapshot.exists && process == 0) {
        List<String> friendUIDs =
            List<String>.from(documentSnapshot['friends'] ?? []);

        List<DocumentSnapshot> friendDocs = await Future.wait(friendUIDs
            .map((friendUID) => FirebaseFirestore.instance
                .collection('users')
                .doc(friendUID)
                .get())
            .toList());

        for (DocumentSnapshot snapshot in friendDocs) {
          users.add(UserClass.fromSnapshot(snapshot));
        }

        yield users;
      } else if (documentSnapshot.exists && process == 1) {
        List<dynamic> chatData = documentSnapshot['chats'] ?? [];
        List<String> receiverUIDs = [];

        for (dynamic chat in chatData) {
          String receiverUID = chat['reciverUid'];
          receiverUIDs.add(receiverUID);
        }
        List<DocumentSnapshot> friendDocs = await Future.wait(receiverUIDs
            .map((receiverUID) => FirebaseFirestore.instance
                .collection('users')
                .doc(receiverUID)
                .get())
            .toList());

        for (DocumentSnapshot snapshot in friendDocs) {
          users.add(UserClass.fromSnapshot(snapshot));
        }

        yield users;
      } else {
        yield [];
      }
    } catch (e) {
      yield [];
    }
  }
}
