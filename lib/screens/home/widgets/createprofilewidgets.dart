import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/providers.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/pages/pagecreateprofile.dart';
import 'package:smproject3/screens/home/providers.dart';

//! Padding kaldır
//! SizedBox ekle
//! MAX uzunlukları belirle

class GeneralTFF extends ConsumerWidget {
  final TextEditingController controller;
  final dynamic provider;
  final String labelText;
  final dynamic icon;
  final dynamic maxLines;
  final double padding;
  final int a;

  const GeneralTFF({
    super.key,
    required this.provider,
    required this.labelText,
    required this.icon,
    required this.maxLines,
    required this.padding,
    required this.a,
    required this.controller,
  }); //return EmailValidator.validate(value!) ? null : "Geçersiz mail"

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (a == 1) {
            if (value!.isEmpty) {
              return null;
            } else {
              return "";
            }
          } else {
            if (value!.isEmpty || value.length > 5) {
              return null;
            } else {
              return "";
            }
          }
        },
        onChanged: (value) {
          if (a == 0) {
            controller.value = controller.value.copyWith(
              text: value.trim(),
              selection: TextSelection.collapsed(offset: value.trim().length),
              composing: TextRange.empty,
            );
            provider.state = value.trim();
          } else {
            provider.state = value;
          }
        },
        cursorColor: Colors.grey,
        cursorWidth: 3,
        cursorRadius: const Radius.circular(10),
        cursorOpacityAnimates: true,
        maxLines: maxLines,
        style: GoogleFonts.nunito(
          color: const Color.fromRGBO(23, 23, 23, 1),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          helperText: a == 0
              ? "En az 6 karakter"
              : a == 2
                  ? "İsteğe bağlı"
                  : "",
          helperStyle: GoogleFonts.nunito(),
          contentPadding: padding == 1 ? const EdgeInsets.only(left: 30) : null,
          errorStyle: const TextStyle(fontSize: 0.01),
          labelText: labelText,
          hintStyle: GoogleFonts.nunito(
            color: a == 0
                ? Colors.grey.shade600
                : const Color.fromRGBO(23, 23, 23, 1),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          labelStyle: GoogleFonts.nunito(
            color: a == 0
                ? Colors.grey.shade600
                : const Color.fromRGBO(23, 23, 23, 1),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: icon,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red.shade300,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red.shade300,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 2,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class EnterButton extends ConsumerWidget {
  //! KODLARI DÜZENLE
  final GlobalKey<FormState> keyG;

  const EnterButton({
    super.key,
    required this.keyG,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
        onPressed: () async {
          if (ref.watch(nameProvider).trim().isNotEmpty &&
              ref.watch(surnameProvider).trim().isNotEmpty) {
            ref.read(pageNoProvider.notifier).state = 0;
            Reference reference = FirebaseStorage.instance
                .ref()
                .child("profilePics")
                .child(ref.watch(auth).currentUser!.uid);

            UploadTask uploadTask =
                reference.putData(ref.watch(photoUrlProvider));

            TaskSnapshot snap = await uploadTask;
            String url = await snap.ref.getDownloadURL();

            UserClass user = UserClass(
              email: ref.watch(auth).currentUser!.email ?? "",
              uid: ref.watch(auth).currentUser!.uid,
              photoUrl: url,
              username: ref.watch(usernameProvider).trim(),
              name: ref.watch(nameProvider).trim(),
              surname: ref.watch(surnameProvider).trim(),
              bio: ref.watch(bioProvider).trim(),
              friends: [],
              requests: [],
              blocked: [],
              photoPosts: [],
              textPosts: [],
              chats: [],
            );
            await FirebaseFirestore.instance
                .collection('users')
                .doc(ref.watch(auth).currentUser!.uid)
                .set(user.toJson());
          } else if (ref.watch(nameProvider).trim().isEmpty &&
              ref.watch(surnameProvider).trim().isNotEmpty) {
            showSnackBarWidget(context, "Lütfen adınızı giriniz.");
          } else if (ref.watch(surnameProvider).trim().isEmpty &&
              ref.watch(nameProvider).trim().isNotEmpty) {
            showSnackBarWidget(context, "Lütfen soyadınızı giriniz.");
          } else {
            keyG.currentState!.validate;
            showSnackBarWidget(context, "Lütfen alanları doldurunuz.");
          }
        },
        style: Designs().buttonStyleBlue(),
        child: Text(
          "Giriş Yap",
          style: GoogleFonts.nunito(
            color: const Color.fromRGBO(237, 237, 237, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class NextButton extends ConsumerWidget {
  //! KODLARI DÜZENLE
  final GlobalKey<FormState> keyG;

  const NextButton({
    super.key,
    required this.keyG,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
        onPressed: () async {
          if (ref.watch(usernameProvider).trim().length > 5 &&
              ref.watch(photoCheckProvider) == 1) {
            QuerySnapshot query = await FirebaseFirestore.instance
                .collection('users')
                .where('username', isEqualTo: ref.watch(usernameProvider))
                .get();

            if (query.docs.isEmpty) {
              ref.watch(pageControl2Provider).nextPage(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutQuart,
                  );
              ref.read(stepProvider.notifier).state++;
            } else {
              // ignore: use_build_context_synchronously
              showSnackBarWidget(context, "Bu ada sahip kullanıcı mevcut.");
            }
          } else if (ref.watch(photoCheckProvider) == 0) {
            // ignore: use_build_context_synchronously
            showSnackBarWidget(context, "Profil fotoğrafı eklenmedi.");
          } else if (ref.watch(usernameProvider).trim().length <= 5 &&
              ref.watch(usernameProvider).trim().isNotEmpty) {
            keyG.currentState!.validate();
            keyG.currentState!.reset();
            // ignore: use_build_context_synchronously
            showSnackBarWidget(
              context,
              "Lütfen kullanıcı adını doğru giriniz.",
            );
          } else {
            // ignore: use_build_context_synchronously
            showSnackBarWidget(context, "Lütfen kullanıcı adı giriniz.");
            keyG.currentState!.validate();
          }
        },
        style: Designs().buttonStyleBlue(),
        child: Text(
          "İleri",
          style: GoogleFonts.nunito(
            color: const Color.fromRGBO(237, 237, 237, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CancelButton extends ConsumerWidget {
  const CancelButton({
    super.key,
    required this.controllers,
  });

  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
        onPressed: () async {
          controllers[0].text = ref.watch(usernameProvider);
          controllers[1].text = ref.watch(nameProvider);
          controllers[2].text = ref.watch(surnameProvider);
          controllers[3].text = ref.watch(bioProvider);
          if (ref.watch(stepProvider) == 1) {
            ref.watch(pageControl2Provider).previousPage(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutQuart,
                );
            ref.read(stepProvider.notifier).state--;
          } else {
            ref.watch(auth).signOut();
          }
        },
        style: Designs().buttonStyleBlue(),
        child: Text(
          "Geri Dön",
          style: GoogleFonts.nunito(
            color: const Color.fromRGBO(237, 237, 237, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
