import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/home/providers.dart';

final choiceProvider = StateProvider((ref) => 0);
final postIndexProvider = StateProvider((ref) => 0);
final selectedUserPostProvider = StateProvider((ref) => UserClass.empty());
final yourCommentProvider = StateProvider((ref) => "");

final class SinglePostView extends ConsumerWidget {
  SinglePostView({super.key});
  final keyG = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final index = ref.watch(postIndexProvider);
    final user = ref.watch(selectedUserPostProvider);

    String formattedDate = DateFormat('dd MMMM HH:mm', 'tr').format(
        DateTime.parse(ref.watch(choiceProvider) == 0
            ? user.photoPosts[index].date
            : user.textPosts[index].date));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade600,
        shadowColor: Colors.transparent,
      ),
      body: Form(
        key: keyG,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(selectedUserProvider.notifier).state.add(user);
                  Navigator.pushNamed(context, '/selecteduser');
                },
                child: Container(
                  width: size.width * 0.85,
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey.shade400,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                // ignore: unnecessary_null_comparison
                                image: NetworkImage(user.photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            user.username,
                            style: GoogleFonts.nunito(
                              color: Colors.grey.shade700,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.nunito(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ref.watch(choiceProvider) == 0
                  ? Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          height: size.width,
                          width: size.width,
                          alignment: Alignment.center,
                          child: Container(
                            height: size.width * 0.9,
                            width: size.width * 0.9,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    user.photoPosts[index].photoUrl),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Container(
                          width: size.width * 0.85,
                          padding: const EdgeInsets.only(
                            bottom: 25,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            user.photoPosts[index].comment,
                            style: GoogleFonts.nunito(
                              color: Colors.grey.shade600,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30, top: 30),
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.textPosts[index].title,
                                style: GoogleFonts.nunito(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                user.textPosts[index].text,
                                style: GoogleFonts.nunito(
                                  color: Colors.grey.shade600,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              YourComment(size: size),
              ShareCommentButton(size: size, keyG: keyG),
              StreamBuilder<List<UserClass>>(
                stream: getUsersStream(
                  ref.watch(choiceProvider) == 0
                      ? user.photoPosts[index].commentersUid
                      : user.textPosts[index].commentersUid,
                  ref.watch(selectedUserPostProvider).uid,
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<List<UserClass>> snapshot) {
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
                            size: 25.0,
                          ),
                        ),
                      ),
                    );
                  } else {
                    List<UserClass> users = snapshot.data ?? [];
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index2) {
                          return Column(
                            children: [
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                child: ListTile(
                                  tileColor:
                                      const Color.fromRGBO(237, 237, 237, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  leading: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: Colors.grey.shade300,
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        // ignore: unnecessary_null_comparison
                                        image: NetworkImage(
                                            users[index2].photoUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    users[index2].username,
                                    style: GoogleFonts.nunito(
                                      color: Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  subtitle: Text(
                                    ref.watch(choiceProvider) == 0
                                        ? user
                                            .photoPosts[index].comments[index2]
                                        : user
                                            .textPosts[index].comments[index2],
                                    style: GoogleFonts.nunito(
                                      color: Colors.grey.shade600,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class YourComment extends ConsumerWidget {
  const YourComment({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(userDocumentProvider).asData!.value!;
    final FocusNode commentFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentFocus.requestFocus();
    });

    return SizedBox(
      width: size.width * 0.9,
      child: TextFormField(
        onChanged: (value) {
          ref.read(yourCommentProvider.notifier).state = value;
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
          contentPadding: const EdgeInsets.only(top: 50),
          hintText: "Yorum ekleyeyin",
          filled: true,
          fillColor: Colors.grey.shade300,
          hintStyle: GoogleFonts.nunito(
            color: Colors.grey.shade600,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Container(
            width: 35,
            height: 35,
            margin: const EdgeInsets.only(right: 20, left: 20),
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.grey.shade400,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                // ignore: unnecessary_null_comparison
                image: NetworkImage(userDocument.photoUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 3,
              color: Colors.white,
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
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class ShareCommentButton extends ConsumerWidget {
  const ShareCommentButton({
    super.key,
    required this.size,
    required this.keyG,
  });

  final Size size;
  final keyG;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(postIndexProvider);
    final user = ref.watch(selectedUserPostProvider);
    final userDocument = ref.watch(userDocumentProvider).asData!.value!;
    return Container(
      width: size.width * 0.9,
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (ref.watch(yourCommentProvider).trim().isNotEmpty) {
            if (ref.watch(choiceProvider) == 0) {
              //! Resim ise
              user.photoPosts[index].comments
                  .add(ref.watch(yourCommentProvider).trim());
              user.photoPosts[index].commentersUid.add(userDocument.uid);
            } else {
              user.textPosts[index].comments
                  .add(ref.watch(yourCommentProvider).trim());
              user.textPosts[index].commentersUid.add(userDocument.uid);
            }
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update(user.toJson());
          }
          ref.read(yourCommentProvider.notifier).state = "";
          keyG.currentState!.reset();
        },
        style: ButtonStyle(
          overlayColor: const MaterialStatePropertyAll(Colors.blue),
          minimumSize: MaterialStatePropertyAll(
              Size(size.width * 0.3, size.height * 0.045)),
          backgroundColor: const MaterialStatePropertyAll(Colors.pink),
          shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        ),
        icon: const Icon(
          Icons.comment,
          size: 20,
        ),
        label: Text(
          "PAYLAŞ",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Stream<List<UserClass>> getUsersStream(
    List<dynamic> commentersUids, String uid) {
  List<String> stringUids = commentersUids.cast<String>();
  Stream<DocumentSnapshot> documentStream =
      FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

  return documentStream.asyncMap(
    (DocumentSnapshot snapshot) async {
      List<UserClass> users = [];
      for (String userId in stringUids) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        users.add(UserClass.fromSnapshot(userSnapshot));
      }
      return users;
    },
  );
}
