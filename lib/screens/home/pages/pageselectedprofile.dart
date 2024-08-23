import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/providers.dart';
import 'package:smproject3/screens/home/widgets/profilewidgets.dart';

class SelectedProfile extends ConsumerWidget {
  const SelectedProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(
        selectedUserProvider)[ref.watch(selectedUserProvider).length - 1];
    final currentUserUid = ref.watch(userDocumentProvider).asData!.value!.uid;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
      // ignore: unnecessary_null_comparison
      body: userDocument != null
          ? Container(
              color: const Color.fromRGBO(237, 237, 237, 1),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
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
                            !userDocument.friends.contains(currentUserUid) &&
                                    userDocument.uid != currentUserUid &&
                                    !userDocument.blocked
                                        .contains(currentUserUid)
                                ? Positioned(
                                    left: size.width * 0.85,
                                    top: size.height * 0.23,
                                    height: size.width * 0.1,
                                    width: size.width * 0.1,
                                    child: FButtonWidget(
                                      userDocument: userDocument,
                                      currentUserUid: currentUserUid,
                                    ),
                                  )
                                : const SizedBox(),
                            Positioned(
                              top: size.height * 0.3 - (size.width * 0.30) / 3,
                              left: size.width * 0.1,
                              child: ProfilePhoto(userDocument: userDocument),
                            ),
                            Positioned(
                              left: size.width * 0.1,
                              top: size.height * 0.12,
                              child: Text(
                                userDocument.username,
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
                                "${userDocument.name} ${userDocument.surname}",
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
                                    SizedBox(width: size.width * 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  ],
                ),
              ),
            )
          : const CostomIndicator(),
    );
  }
}

class FButtonWidget extends StatelessWidget {
  const FButtonWidget({
    super.key,
    required this.userDocument,
    required this.currentUserUid,
  });

  final UserClass userDocument;
  final String currentUserUid;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        BootstrapIcons.person_add,
        color: Colors.white,
        size: 30,
      ),
      onPressed: () async {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocument.uid)
            .get();

        UserClass user = UserClass.fromSnapshot(userSnapshot);
        if (user.requests.contains(currentUserUid)) {
          //* Zaten istek gönderilmiş
          // ignore: use_build_context_synchronously
          showSnackBarWidget(context, "Daha önce istek gönderildi.");
        } else {
          user.requests.add(currentUserUid);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocument.uid)
              .update(user.toJson());
          // ignore: use_build_context_synchronously
          showSnackBarWidget(context, "Arkadaşlık isteği gönderildi.");
        }
      },
    );
  }
}
