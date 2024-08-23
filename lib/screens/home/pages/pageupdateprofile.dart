import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/providers.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/providers.dart';
import 'package:smproject3/screens/home/widgets/createprofilewidgets.dart';

final newNameProvider = StateProvider((ref) => "");
final newSurnameProvider = StateProvider((ref) => "");
final newAboutProvider = StateProvider((ref) => "");

final newProfilePhotoProvider = StateProvider<XFile>((ref) => XFile(""));

class UpdatePage extends ConsumerWidget {
  UpdatePage({super.key});
  final GlobalKey<FormState> keyG = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(userDocumentProvider).asData?.value;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
      body: SingleChildScrollView(
        child: Form(
          key: keyG,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(23, 23, 23, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                height: size.height * 0.33,
                width: size.width,
                alignment: Alignment.center,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: size.height * 0.1,
                      child: Text(
                        "Profil Ayarları",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.2,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.36,
                        height: MediaQuery.of(context).size.width * 0.36,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 5,
                            color: const Color.fromRGBO(237, 237, 237, 1),
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ref
                                .watch(newProfilePhotoProvider)
                                .path
                                .isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(ref.watch(newProfilePhotoProvider).path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipOval(
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(userDocument!.photoUrl),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.32,
                      child: IconButton(
                        onPressed: () async {
                          XFile? file = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxHeight: 1080,
                            maxWidth: 1080,
                          );
                          if (file != null) {
                            ref.read(photoUrlProvider.notifier).state =
                                await file.readAsBytes();
                            ref.read(newProfilePhotoProvider.notifier).state =
                                file;
                          }
                        },
                        icon: const Icon(
                          Icons.add_a_photo,
                          color: Color.fromRGBO(23, 23, 23, 1),
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 90),
                child: GeneralTFF(
                  provider: ref.read(newNameProvider.notifier),
                  labelText: userDocument!.name,
                  icon: Icon(
                    Icons.person_3_outlined,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  padding: 10,
                  a: 1,
                  controller: TextEditingController(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: GeneralTFF(
                  provider: ref.read(newSurnameProvider.notifier),
                  labelText: userDocument.surname,
                  icon: Icon(
                    Icons.person_3_outlined,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  padding: 10,
                  a: 1,
                  controller: TextEditingController(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: GeneralTFF(
                  provider: ref.read(newAboutProvider.notifier),
                  labelText: "Hakkında",
                  icon: Icon(
                    Icons.my_library_books_rounded,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 5,
                  padding: 10,
                  a: 1,
                  controller: TextEditingController(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: OutlinedButton(
                    onPressed: () async {
                      if (keyG.currentState!.validate()) {
                        var urlcheck = 0;
                        var name = 0;
                        var surname = 0;
                        var about = 0;
                        var url = "";

                        if (ref
                            .watch(newProfilePhotoProvider)
                            .path
                            .isNotEmpty) {
                          Reference reference = FirebaseStorage.instance
                              .ref()
                              .child("profilePics")
                              .child(ref.watch(auth).currentUser!.uid);

                          UploadTask uploadTask =
                              reference.putData(ref.watch(photoUrlProvider));

                          TaskSnapshot snap = await uploadTask;
                          url = await snap.ref.getDownloadURL();
                          urlcheck = 1;
                        }
                        if (ref.watch(newNameProvider).isNotEmpty) name = 1;
                        if (ref.watch(newSurnameProvider).isNotEmpty) {
                          surname = 1;
                        }
                        if (ref.watch(newAboutProvider).isNotEmpty) about = 1;
                        UserClass user = UserClass(
                          email: userDocument.email,
                          uid: userDocument.uid,
                          photoUrl: urlcheck == 1 ? url : userDocument.photoUrl,
                          username: userDocument.username,
                          name: name == 1
                              ? ref.watch(newNameProvider)
                              : userDocument.name,
                          surname: surname == 1
                              ? ref.watch(newSurnameProvider)
                              : userDocument.surname,
                          bio: about == 1
                              ? ref.watch(newAboutProvider)
                              : userDocument.bio,
                          friends: userDocument.friends,
                          requests: userDocument.requests,
                          blocked: userDocument.blocked,
                          photoPosts: userDocument.photoPosts,
                          textPosts: userDocument.textPosts,
                          chats: userDocument.chats,
                        );
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(ref.watch(auth).currentUser!.uid)
                            .set(user.toJson());
                        if (about == 1 ||
                            name == 1 ||
                            surname == 1 ||
                            urlcheck == 1) {
                          // ignore: use_build_context_synchronously
                          showSnackBarWidget(context, "Değişiklik kaydedildi.");
                        } else {
                          // ignore: use_build_context_synchronously
                          showSnackBarWidget(context, "Değişiklik yapılmadı.");
                        }
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      } else {
                        showSnackBarWidget(
                          context,
                          "Alanların uzunluğu 0'dan büyük\n" +
                              "          4'ten küçük olamaz.",
                        );
                      }
                    },
                    style: Designs().buttonStyleBlue(),
                    child: Text(
                      "Kaydet",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
