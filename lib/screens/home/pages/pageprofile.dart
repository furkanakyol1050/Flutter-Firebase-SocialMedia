import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/providers.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/providers.dart';
import 'package:smproject3/screens/home/widgets/profilewidgets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(userDocumentProvider).asData?.value;
    final size = MediaQuery.of(context).size;
    return userDocument != null
        ? Container(
            color: const Color.fromRGBO(237, 237, 237, 1),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  UpperProfileWidget(size: size, userDocument: userDocument),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    child: NumericValues(userDocument: userDocument),
                  ),
                  Container(
                    width: size.width * 0.90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(23, 23, 23, 1),
                    ),
                    child: BioWidget(size: size, userDocument: userDocument),
                  ),
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.only(top: 20),
                    child: const Buttons(),
                  ),
                  Share(userDocument: userDocument),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          )
        : const CostomIndicator();
  }
}

class UpperProfileWidget extends StatelessWidget {
  const UpperProfileWidget({
    super.key,
    required this.size,
    required this.userDocument,
  });

  final Size size;
  final UserClass? userDocument;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(237, 237, 237, 1),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(23, 23, 23, 1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        height: size.height * 0.3,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: size.height * 0.3 - (size.width * 0.30) / 3,
              left: size.width * 0.1,
              child: ProfilePhoto(userDocument: userDocument),
            ),
            Positioned(
              left: size.width * 0.1,
              top: size.height * 0.12,
              child: Text(
                userDocument!.username,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: size.width * 0.1,
              top: size.height * 0.17,
              child: Text(
                "${userDocument!.name} ${userDocument!.surname}",
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.05,
              child: SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: size.width * 0.1),
                    Container(
                      alignment: Alignment.center,
                      width: size.width * 0.75,
                      child: Text(
                        "Profil",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SettingsButton(
                      size: size,
                      userDocument: userDocument!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsButton extends ConsumerWidget {
  const SettingsButton({
    super.key,
    required this.size,
    required this.userDocument,
  });

  final Size size;
  final UserClass userDocument;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: size.width * 0.1,
      child: IconButton(
        onPressed: () {
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            context: context,
            builder: (context) {
              return Container(
                margin: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(BootstrapIcons.gear_fill, size: 20),
                      title: Text(
                        'Profil Ayarları',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/update');
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.do_not_disturb_on_total_silence,
                      ),
                      title: Text(
                        'Engellenenler',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        modalBottomSheetBlock(context, userDocument, ref);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite_border_sharp),
                      title: Text(
                        'İstekler',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        modalBottomSheet(context, userDocument, ref);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: Text(
                        'Çıkış',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.watch(auth).signOut();
                        ref.read(pageNoProvider.notifier).state = 0;
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(
          BootstrapIcons.list,
          color: Colors.white,
        ),
      ),
    );
  }
}

Future<dynamic> modalBottomSheet(
    BuildContext context, UserClass userDocument, WidgetRef ref) {
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
        future: fetchUsers(userDocument.requests),
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
                  child: const CircularProgressIndicator(
                    strokeAlign: 2,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            List<UserClass> users = snapshot.data!;
            return users.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 20, left: 10),
                    child: ListView.builder(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  showSnackBarWidget(
                                      context, "İstek kabul edildi.");
                                  userDocument.requests
                                      .remove(users[index].uid);
                                  userDocument.friends.add(users[index].uid);
                                  users[index]
                                      .requests
                                      .remove(userDocument.uid);
                                  users[index].friends.add(userDocument.uid);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userDocument.uid)
                                      .update(userDocument.toJson());
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(users[index].uid)
                                      .update(users[index].toJson());
                                },
                                label: Text(
                                  "Kabul Et",
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  showSnackBarWidget(
                                      context, "İstek reddedildi.");
                                  userDocument.requests
                                      .remove(users[index].uid);
                                  users[index]
                                      .requests
                                      .remove(userDocument.uid);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userDocument.uid)
                                      .update(userDocument.toJson());
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(users[index].uid)
                                      .update(users[index].toJson());
                                },
                                label: Text(
                                  "Reddet",
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
                              ),
                            ],
                          ),
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
                    ),
                  )
                : Container(
                    height: 80,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      "Arkadaşlık İsteğiniz Yok",
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

Future<dynamic> modalBottomSheetBlock(
    BuildContext context, UserClass userDocument, WidgetRef ref) {
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
        future: fetchUsers(userDocument.blocked),
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
                  child: const CircularProgressIndicator(
                    strokeAlign: 2,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            List<UserClass> users = snapshot.data!;
            return users.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.only(top: 20, left: 10),
                    child: ListView.builder(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(23, 23, 23, 1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  // ignore: use_build_context_synchronously
                                  showSnackBarWidget(
                                      context, "Engel kaldırıldı.");
                                  userDocument.blocked.remove(users[index].uid);
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userDocument.uid)
                                      .update(userDocument.toJson());
                                },
                                label: Text(
                                  "Engeli Kaldır",
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.do_not_disturb_off_sharp,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
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
                    ),
                  )
                : Container(
                    height: 80,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      "Engellenen Kimse Yok",
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
