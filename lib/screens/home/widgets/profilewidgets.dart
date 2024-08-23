import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/pages/pagesinglepostview.dart';
import 'package:smproject3/screens/home/providers.dart';

class Share extends ConsumerWidget {
  final UserClass? userDocument;

  const Share({
    super.key,
    required this.userDocument,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    if (ref.watch(sharedChangeProvider) == 0) {
      if (userDocument!.photoPosts.isEmpty) {
        return Container(
          alignment: Alignment.center,
          height: size.height * 0.05,
          width: size.width * 0.90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromRGBO(23, 23, 23, 1),
          ),
          child: Text(
            "Herhangi bir paylaşım yok.",
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      } else {
        return GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.only(left: 15, right: 15),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            userDocument!.photoPosts.length,
            (index) {
              return GestureDetector(
                onLongPress: () {
                  modalBottomSheetDelete(context, userDocument!, ref, index, 1);
                },
                onTap: () {
                  ref.read(postIndexProvider.notifier).state = index;
                  ref.read(choiceProvider.notifier).state = 0;
                  ref.read(selectedUserPostProvider.notifier).state =
                      userDocument!;
                  Navigator.pushNamed(context, '/postview');
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(
                        userDocument!.photoPosts[index].photoUrl,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: const EdgeInsets.all(10),
                ),
              );
            },
          ),
        );
      }
    } else {
      if (userDocument!.textPosts.isEmpty) {
        return Container(
          alignment: Alignment.center,
          height: size.height * 0.05,
          width: size.width * 0.90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromRGBO(23, 23, 23, 1),
          ),
          child: Text(
            "Herhangi bir paylaşım yok.",
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        );
      } else {
        return SizedBox(
          width: size.width * 0.9,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemCount: userDocument!.textPosts.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTileCard(
                    baseColor: Colors.grey[200],
                    expandedColor: Colors.grey[200],
                    expandedTextColor: const Color.fromRGBO(23, 23, 23, 1),
                    leading: const Icon(
                      Icons.text_fields_rounded,
                      size: 30,
                    ),
                    title: Text(
                      userDocument!.textPosts[index].title,
                      style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      userDocument!.textPosts[index].date,
                      style: GoogleFonts.nunito(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    children: [
                      const Divider(
                        thickness: 1.0,
                        height: 1.0,
                        endIndent: 15,
                        indent: 15,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            userDocument!.textPosts[index].text,
                            style: GoogleFonts.nunito(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          LikeButton(
                            padding: const EdgeInsets.all(10),
                            likeCount:
                                userDocument!.textPosts[index].likersUid.length,
                            isLiked: userDocument!.textPosts[index].likersUid
                                .contains(
                                    FirebaseAuth.instance.currentUser!.uid),
                            onTap: (isLiked) async {
                              if (!isLiked) {
                                userDocument!.textPosts[index].likersUid.add(
                                    FirebaseAuth.instance.currentUser!.uid);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userDocument!.uid)
                                    .update(userDocument!.toJson());
                              } else {
                                userDocument!.textPosts[index].likersUid.remove(
                                    FirebaseAuth.instance.currentUser!.uid);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userDocument!.uid)
                                    .update(userDocument!.toJson());
                              }
                              return !isLiked;
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(postIndexProvider.notifier).state =
                                  index;
                              ref.read(choiceProvider.notifier).state = 1;
                              ref
                                  .read(selectedUserPostProvider.notifier)
                                  .state = userDocument!;
                              Navigator.pushNamed(context, '/postview');
                            },
                            child: const Icon(
                              Icons.comment,
                              color: Colors.black,
                            ),
                          ),
                          userDocument!.uid ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? TextButton(
                                  onPressed: () {
                                    modalBottomSheetDelete(
                                        context, userDocument!, ref, index, 0);
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }
}

Future<dynamic> modalBottomSheetDelete(BuildContext context,
    UserClass userDocument, WidgetRef ref, int index, int x) {
  return showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.only(top: 30, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Silmek istediğine emin misin?",
                style: GoogleFonts.nunito(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              label: Text(
                "Sil",
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              icon: const Icon(
                BootstrapIcons.x,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () async {
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                showSnackBarWidget(context, "Paylaşım silindi.");
                if (x == 0) {
                  userDocument.textPosts.removeAt(index);
                } else {
                  userDocument.photoPosts.removeAt(index);
                }
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userDocument.uid)
                    .update(userDocument.toJson());
              },
            )
          ],
        ),
      );
    },
  );
}

class Buttons extends ConsumerWidget {
  const Buttons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            "Paylaşımlar",
            style: GoogleFonts.nunito(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          child: IconButton(
            onPressed: () {
              ref.read(sharedChangeProvider.notifier).state = 0;
            },
            icon: Icon(
              BootstrapIcons.columns_gap,
              color: ref.watch(sharedChangeProvider) == 0
                  ? Colors.black
                  : Colors.grey,
              size: 20,
            ),
          ),
        ),
        SizedBox(
          child: IconButton(
            onPressed: () {
              ref.read(sharedChangeProvider.notifier).state = 1;
            },
            icon: Icon(
              BootstrapIcons.card_text,
              color: ref.watch(sharedChangeProvider) == 1
                  ? Colors.black
                  : Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class NumericValues extends ConsumerWidget {
  final UserClass? userDocument;
  const NumericValues({
    super.key,
    required this.userDocument,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return userDocument != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: size.width * 0.17,
                width: size.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(68, 68, 68, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        (userDocument!.photoPosts.length +
                                userDocument!.textPosts.length)
                            .toString(),
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Paylaşım",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.05),
              GestureDetector(
                onTap: () {
                  modalBottomSheet(context, ref);
                },
                child: Container(
                  height: size.width * 0.17,
                  width: size.width * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromRGBO(68, 68, 68, 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          userDocument!.friends.length.toString(),
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Arkadaşlar",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: size.width * 0.05),
            ],
          )
        : Container();
  }

  Future<dynamic> modalBottomSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return FutureBuilder<List<UserClass>>(
          future: fetchUsers2(userDocument!.friends),
          builder:
              (BuildContext context, AsyncSnapshot<List<UserClass>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(26),
                    width: 20,
                    height: 20,
                    child: const SpinKitFadingCube(
                      color: Colors.black,
                      size: 20.0,
                    ),
                  ),
                ),
              );
            } else {
              List<UserClass> users = snapshot.data!;
              return users.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
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
                                    : const AssetImage("assets/defUser.png")
                                        as ImageProvider,
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
                          subtitle: Text(
                            "${users[index].name} ${users[index].surname}",
                            style: GoogleFonts.nunito(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: userDocument!.uid ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    UnfriendButtonWidget(
                                      userDocument: userDocument,
                                      users: users,
                                      index: index,
                                    ),
                                    const SizedBox(width: 10),
                                    BlockedButtonWidget(
                                      userDocument: userDocument,
                                      users: users,
                                      index: index,
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          onTap: () {
                            Navigator.pop(context);
                            ref
                                .read(selectedUserProvider.notifier)
                                .state
                                .add(users[index]);
                            Navigator.pushNamed(context, '/selecteduser');
                          },
                        );
                      },
                    )
                  : Container(
                      height: 80,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        "Hiç Arkadaş Yok",
                        style: GoogleFonts.nunito(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
            }
          },
        );
      },
    );
  }
}

class BlockedButtonWidget extends ConsumerWidget {
  const BlockedButtonWidget({
    super.key,
    required this.userDocument,
    required this.users,
    required this.index,
  });

  final UserClass? userDocument;
  final List<UserClass> users;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {},
      onLongPress: () async {
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showSnackBarWidget(context, "Engellendi.");
        int chatIndex = -1;
        for (ChatClass chat in userDocument!.chats) {
          if (chat.reciverUid == users[index].uid) {
            chatIndex = userDocument!.chats.indexOf(chat);
            break;
          }
        }
        if (chatIndex != -1) {
          userDocument!.chats.removeAt(chatIndex);
        }
        chatIndex = -1;
        for (ChatClass chat in users[index].chats) {
          if (chat.reciverUid == userDocument!.uid) {
            chatIndex = users[index].chats.indexOf(chat);
            break;
          }
        }
        if (chatIndex != -1) {
          users[index].chats.removeAt(chatIndex);
        }
        userDocument!.friends.remove(users[index].uid);
        userDocument!.blocked.add(users[index].uid);
        users[index].friends.remove(userDocument!.uid);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocument!.uid)
            .update(userDocument!.toJson());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(users[index].uid)
            .update(users[index].toJson());
      },
      label: Text(
        "Engelle",
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      icon: const Icon(
        Icons.do_not_disturb_on_total_silence,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class UnfriendButtonWidget extends ConsumerWidget {
  const UnfriendButtonWidget({
    super.key,
    required this.userDocument,
    required this.users,
    required this.index,
  });

  final UserClass? userDocument;
  final List<UserClass> users;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {},
      onLongPress: () async {
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showSnackBarWidget(context, "Arkadaşlıktan çıkarıldı.");
        int chatIndex = -1;
        for (ChatClass chat in userDocument!.chats) {
          if (chat.reciverUid == users[index].uid) {
            chatIndex = userDocument!.chats.indexOf(chat);
            break;
          }
        }
        if (chatIndex != -1) {
          userDocument!.chats.removeAt(chatIndex);
        }
        chatIndex = -1;
        for (ChatClass chat in users[index].chats) {
          if (chat.reciverUid == userDocument!.uid) {
            chatIndex = users[index].chats.indexOf(chat);
            break;
          }
        }
        if (chatIndex != -1) {
          users[index].chats.removeAt(chatIndex);
        }
        userDocument!.friends.remove(users[index].uid);

        users[index].friends.remove(userDocument!.uid);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocument!.uid)
            .update(userDocument!.toJson());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(users[index].uid)
            .update(users[index].toJson());
      },
      label: Text(
        "Çıkart",
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      icon: const Icon(
        Icons.delete_outline_outlined,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class ProfilePhoto extends ConsumerWidget {
  final UserClass? userDocument;
  const ProfilePhoto({
    super.key,
    required this.userDocument,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.25,
      height: size.width * 0.25,
      decoration: BoxDecoration(
        border: Border.all(
          width: 5,
          color: const Color.fromRGBO(237, 237, 237, 1),
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: userDocument?.photoUrl != null
              ? NetworkImage(userDocument!.photoUrl)
              : const AssetImage("assets/defUser.png") as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

Future<List<UserClass>> fetchUsers(List requests) async {
  List<UserClass> users = [];
  for (String userId in requests) {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    users.add(UserClass.fromSnapshot(snapshot));
  }
  return users;
}

Future<List<UserClass>> fetchUsers2(List friends) async {
  List<UserClass> users = [];
  for (String userId in friends) {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    users.add(UserClass.fromSnapshot(snapshot));
  }
  return users;
}

Future<List<UserClass>> fetchUsersBlock(List blockeds) async {
  List<UserClass> users = [];
  for (String userId in blockeds) {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    users.add(UserClass.fromSnapshot(snapshot));
  }
  return users;
}

class BioWidget extends StatelessWidget {
  final UserClass userDocument;
  const BioWidget({
    super.key,
    required this.size,
    required this.userDocument,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    if (userDocument.bio != "") {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            alignment: Alignment.center,
            child: Text(
              "Hakkında",
              style: GoogleFonts.nunito(
                letterSpacing: 1,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20, left: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              userDocument.bio,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
}
