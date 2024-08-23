import 'dart:math';
import 'dart:typed_data';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/providers.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/providers.dart';

final changeProvider = StateProvider((ref) => 0);

final photoChangeProvider = StateProvider((ref) => 0);

final imageCommentProvider = StateProvider((ref) => "");

final textPostProvider = StateProvider((ref) => "");

final textPostTitleProvider = StateProvider((ref) => "");

final imageProvider = StateProvider((ref) => "assets/def.png");

final processingProvider = StateProvider((ref) => false);

final sharedPhotoProvider = StateProvider<Uint8List>((ref) => Uint8List(0));

class SharePage extends ConsumerWidget {
  SharePage({super.key});

  final GlobalKey keyF = GlobalKey();
  final GlobalKey<FormFieldState> _textField1Key = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _textField2Key = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _textField3Key = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Form(
      key: keyF,
      child: Container(
        color: const Color.fromRGBO(237, 237, 237, 1),
        child: SingleChildScrollView(
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
                height: size.height * 0.2,
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: size.height * 0.06,
                      child: Text(
                        "Paylaş",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: size.height * 0.15,
                      child: const Buttons(),
                    ),
                  ],
                ),
              ),
              ref.watch(changeProvider) == 0
                  ? Column(
                      children: [
                        const SizedBox(height: 40),
                        ImageContainer(size: size),
                        AddPhotoButton(size: size),
                        ImageComment(size: size, textField1Key: _textField1Key),
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 60),
                        TitleWriting(size: size, textField2Key: _textField2Key),
                        TextWriting(size: size, textField3Key: _textField3Key),
                      ],
                    ),
              ShareButton(
                size: size,
                key1: _textField1Key,
                key2: _textField2Key,
                key3: _textField3Key,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextWriting extends ConsumerWidget {
  const TextWriting({
    super.key,
    required this.size,
    required this.textField3Key,
  });

  final Size size;
  final GlobalKey textField3Key;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: size.width * 0.85,
      child: TextFormField(
        key: textField3Key,
        onChanged: (value) {
          ref.read(textPostProvider.notifier).state = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return '';
          }
          return null;
        },
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.grey,
        cursorWidth: 3,
        cursorRadius: const Radius.circular(10),
        maxLength: 150,
        minLines: 10,
        maxLines: 20,
        cursorOpacityAnimates: true,
        style: GoogleFonts.nunito(
          color: Colors.grey.shade600,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          hintText: "Bizimle düşüncelerini paylaş!",
          hintStyle: GoogleFonts.nunito(
            color: Colors.grey.shade600,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(
            Icons.double_arrow_rounded,
            color: Colors.grey.shade600,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class TitleWriting extends ConsumerWidget {
  const TitleWriting({
    super.key,
    required this.size,
    required this.textField2Key,
  });

  final Size size;
  final GlobalKey textField2Key;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: size.width * 0.85,
      child: TextFormField(
        key: textField2Key,
        onChanged: (value) {
          ref.read(textPostTitleProvider.notifier).state = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return '';
          }
          return null;
        },
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.grey,
        cursorWidth: 3,
        cursorRadius: const Radius.circular(10),
        maxLength: 40,
        maxLines: 1,
        cursorOpacityAnimates: true,
        style: GoogleFonts.nunito(
          color: Colors.grey.shade600,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          hintText: "Başlık",
          hintStyle: GoogleFonts.nunito(
            color: Colors.grey.shade600,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(
            Icons.text_fields_rounded,
            color: Colors.grey.shade600,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class ImageContainer extends ConsumerWidget {
  const ImageContainer({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: size.width * 0.7,
      height: size.width * 0.7,
      margin: const EdgeInsets.only(top: 30, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        image: DecorationImage(
          image: ref.watch(sharedPhotoProvider).isEmpty
              ? AssetImage(ref.watch(imageProvider)) as ImageProvider
              : MemoryImage(ref.watch(sharedPhotoProvider)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class AddPhotoButton extends ConsumerWidget {
  const AddPhotoButton({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ElevatedButton.icon(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            builder: (context) {
              return Container(
                margin: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined, size: 20),
                      title: Text(
                        'Kamera',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        XFile? file = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                          maxHeight: 1080,
                          maxWidth: 1080,
                        );
                        if (file != null) {
                          ref.read(sharedPhotoProvider.notifier).state =
                              await file.readAsBytes();
                          ref.read(photoChangeProvider.notifier).state = 1;
                        } else {
                          // ignore: use_build_context_synchronously
                          showSnackBarWidget(context, "Resim eklenemedi.");
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.image_search_rounded, size: 20),
                      title: Text(
                        'Galeri',
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        XFile? file = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxHeight: 1080,
                          maxWidth: 1080,
                        );
                        if (file != null) {
                          ref.read(sharedPhotoProvider.notifier).state =
                              await file.readAsBytes();
                          ref.read(photoChangeProvider.notifier).state = 1;
                        } else {
                          // ignore: use_build_context_synchronously
                          showSnackBarWidget(context, "Resim eklenemedi.");
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        style: ButtonStyle(
          overlayColor: const MaterialStatePropertyAll(Colors.pink),
          minimumSize: MaterialStatePropertyAll(
              Size(size.width * 0.4, size.height * 0.045)),
          backgroundColor: const MaterialStatePropertyAll(
            Color.fromRGBO(23, 23, 23, 1),
          ),
          shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        ),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: Text(
          "Resim Ekle",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class ImageComment extends ConsumerWidget {
  const ImageComment({
    super.key,
    required this.size,
    required this.textField1Key,
  });

  final Size size;
  final GlobalKey textField1Key;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FocusNode focus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focus.requestFocus();
    });
    return SizedBox(
      width: size.width * 0.85,
      child: TextFormField(
        key: textField1Key,
        onChanged: (value) {
          ref.read(imageCommentProvider.notifier).state = value;
        },
        validator: (value) {
          if (value!.isEmpty || value.trim() == '') {
            return '';
          }
          return null;
        },
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.grey,
        cursorWidth: 3,
        cursorRadius: const Radius.circular(10),
        maxLength: 75,
        minLines: 1,
        maxLines: 6,
        cursorOpacityAnimates: true,
        style: GoogleFonts.nunito(
          color: Colors.grey.shade600,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          hintText: "Buradan açıklama ekleyebilirsiniz",
          hintStyle: GoogleFonts.nunito(
            color: Colors.grey.shade600,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(
            Icons.double_arrow_rounded,
            color: Colors.grey.shade600,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class ShareButton extends ConsumerWidget {
  const ShareButton({
    super.key,
    required this.size,
    required this.key1,
    required this.key2,
    required this.key3,
  });

  final Size size;
  final GlobalKey<FormFieldState> key1;
  final GlobalKey<FormFieldState> key2;
  final GlobalKey<FormFieldState> key3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isProcessing = ref.watch(processingProvider);
    return ElevatedButton(
      onPressed: isProcessing
          ? null
          : () async {
              ref.read(processingProvider.notifier).state = true;
              var uid = ref.watch(auth).currentUser?.uid;

              if (ref.watch(changeProvider) == 0 && uid != null) {
                if (ref.watch(imageCommentProvider).trim().isEmpty) {
                  ref.read(imageCommentProvider.notifier).state = "";
                  key1.currentState!.reset();
                }
                if (ref.watch(photoChangeProvider) == 1 &&
                    key1.currentState!.validate()) {
                  Reference reference = FirebaseStorage.instance
                      .ref()
                      .child("illustratedPosts")
                      .child(uid)
                      .child((Random().nextInt(10000000) + 1234).toString() +
                          (Random().nextInt(10000000) + 1234).toString());
                  UploadTask uploadTask =
                      reference.putData(ref.watch(sharedPhotoProvider));
                  TaskSnapshot snap = await uploadTask;
                  String url = await snap.ref.getDownloadURL();
                  PhotoPostClass imagePost = PhotoPostClass(
                    photoUrl: url,
                    comment: ref.watch(imageCommentProvider).trim(),
                    likersUid: [],
                    comments: [],
                    commentersUid: [],
                    date: DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(DateTime.now()),
                  );
                  var variable =
                      ref.watch(userDocumentProvider).asData!.value!.photoPosts;
                  variable.add(imagePost);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update(
                    {
                      'photoPosts':
                          variable.map((data) => data.toJson()).toList(),
                    },
                  );
                  ref.read(sharedPhotoProvider.notifier).state = Uint8List(0);
                  ref.read(imageCommentProvider.notifier).state = "";
                  key1.currentState!.reset();
                  ref.read(photoChangeProvider.notifier).state = 0;
                  // ignore: use_build_context_synchronously
                  showSnackBarWidget(context, "Paylaşıldı.");
                } else if (ref.watch(photoChangeProvider) == 0) {
                  showSnackBarWidget(context, "Resim ekleyiniz.");
                } else {
                  showSnackBarWidget(context, "Resim açıklaması ekleyiniz.");
                }
              } else if (ref.watch(changeProvider) == 1) {
                if (ref.watch(textPostTitleProvider).trim().isEmpty) {
                  ref.read(textPostTitleProvider.notifier).state = "";
                  key2.currentState!.reset();
                }
                if (ref.watch(textPostProvider).trim().isEmpty) {
                  ref.read(textPostProvider.notifier).state = "";
                  key3.currentState!.reset();
                }
                if (key2.currentState!.validate() &&
                    key3.currentState!.validate()) {
                  TextPostClass textPost = TextPostClass(
                    title: ref.watch(textPostTitleProvider).trim(),
                    text: ref.watch(textPostProvider).trim(),
                    likersUid: [],
                    comments: [],
                    commentersUid: [],
                    date: DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(DateTime.now()),
                  );
                  var variable =
                      ref.watch(userDocumentProvider).asData!.value!.textPosts;
                  variable.add(textPost);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update(
                    {
                      'textPosts':
                          variable.map((data) => data.toJson()).toList(),
                    },
                  );
                  ref.read(textPostTitleProvider.notifier).state = "";
                  ref.read(textPostProvider.notifier).state = "";
                  key2.currentState!.reset();
                  key3.currentState!.reset();
                  // ignore: use_build_context_synchronously
                  showSnackBarWidget(context, "Paylaşıldı.");
                } else if (!key2.currentState!.validate()) {
                  showSnackBarWidget(context, "Yazı başlığı ekleyiniz.");
                } else {
                  showSnackBarWidget(context, "Yazı ekleyiniz.");
                }
              }
              ref.read(processingProvider.notifier).state = false;
            },
      style: ButtonStyle(
        overlayColor: const MaterialStatePropertyAll(Colors.blue),
        minimumSize: MaterialStatePropertyAll(
          Size(size.width * 0.6, size.height * 0.045),
        ),
        backgroundColor: isProcessing
            ? const MaterialStatePropertyAll(Colors.grey)
            : const MaterialStatePropertyAll(Colors.pink),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      child: Text(
        isProcessing ? 'YÜKLENİYOR' : 'PAYLAŞ',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 25,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class Buttons extends ConsumerWidget {
  const Buttons({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(23, 23, 23, 1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        height: size.width * 0.17,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(237, 237, 237, 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              style: ButtonStyle(
                fixedSize: MaterialStatePropertyAll(
                  Size.fromWidth(size.width * 0.3),
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                overlayColor: const MaterialStatePropertyAll(Colors.white38),
              ),
              onPressed: () => ref.read(changeProvider.notifier).state = 0,
              icon: Icon(
                BootstrapIcons.camera_fill,
                color: ref.watch(changeProvider) == 0
                    ? Colors.black
                    : Colors.grey.shade600,
                size: 20,
              ),
              label: Text(
                "Resim",
                style: GoogleFonts.nunito(
                  color: ref.watch(changeProvider) == 0
                      ? Colors.black
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            TextButton.icon(
              style: ButtonStyle(
                fixedSize: MaterialStatePropertyAll(
                  Size.fromWidth(size.width * 0.3),
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                overlayColor: const MaterialStatePropertyAll(Colors.white38),
              ),
              onPressed: () => ref.read(changeProvider.notifier).state = 1,
              icon: Icon(
                BootstrapIcons.chat_left_text_fill,
                color: ref.watch(changeProvider) == 1
                    ? Colors.black
                    : Colors.grey.shade600,
                size: 20,
              ),
              label: Text(
                "Yazı",
                style: GoogleFonts.nunito(
                  color: ref.watch(changeProvider) == 1
                      ? Colors.black
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
