// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smproject3/screens/entry/widgets.dart';

final photoUrlProvider = StateProvider<Uint8List>((ref) => Uint8List(0));

class FBAuth {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  singIn(
    String email,
    String password,
    String passwordTwo,
    FirebaseAuth auth,
    GlobalKey<FormState> keyG,
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: SpinKitFadingCube(
            color: Colors.grey,
            size: 50.0,
          ),
        );
      },
    );

    if (password == passwordTwo &&
        keyG.currentState!.validate() &&
        password.isNotEmpty &&
        email.isNotEmpty) {
      try {
        var cred = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        cred.user!.sendEmailVerification();
        UserClass user = UserClass(
          email: email,
          uid: cred.user!.uid,
          photoUrl: "",
          username: "",
          name: "",
          surname: "",
          bio: "",
          friends: [],
          requests: [],
          blocked: [],
          photoPosts: [],
          textPosts: [],
          chats: [],
        );
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        showSnackBarWidget(
            context,
            "Hesabınızın aktifleştirilmesi için\n" +
                "lütfen E-posta adresinizi doğrulayın.");
        auth.signOut();
        Navigator.pushNamed(context, "/");
      } catch (e) {
        showSnackBarWidget(context, "Bu maile sahip bir kullanıcı mevcut.");
      }
    } else if (password.length > 5 &&
        !EmailValidator.validate(email) &&
        passwordTwo.length > 5) {
      showSnackBarWidget(context, "Lütfen mail giriniz.");
    } else if (EmailValidator.validate(email) && passwordTwo.length > 5) {
      showSnackBarWidget(context, "Lütfen şifre giriniz.");
    } else if (EmailValidator.validate(email) &&
        passwordTwo.length <= 5 &&
        password.length <= 5) {
      showSnackBarWidget(context, "Lütfen şifre bölümlerini giriniz.");
    } else if (EmailValidator.validate(email) && password.length > 5) {
      showSnackBarWidget(context, "Lütfen onay şifresi giriniz.");
    } else {
      showSnackBarWidget(context, "Lütfen alanları doğru doldurunuz.");
    }
  }

  googleLogIn(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(cred);

    final DocumentSnapshot userDocument =
        await firestore.collection('users').doc(userCredential.user!.uid).get();
    if (!userDocument.exists) {
      UserClass user = UserClass(
        email: userCredential.user!.email ?? "",
        uid: userCredential.user!.uid,
        photoUrl: "",
        username: "",
        name: "",
        surname: "",
        bio: "",
        friends: [],
        requests: [],
        blocked: [],
        photoPosts: [],
        textPosts: [],
        chats: [],
      );
      firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toJson());
    }
  }

  logIn(
    String email,
    String password,
    FirebaseAuth auth,
    GlobalKey<FormState> keyG,
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: SpinKitFadingCube(
            color: Colors.grey,
            size: 50.0,
          ),
        );
      },
    );

    if (keyG.currentState!.validate() &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      try {
        var cred = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (!cred.user!.emailVerified) {
          FirebaseAuth.instance.signOut();
          showSnackBarWidget(context, "Lütfen E-posta doğrulamasını yapınız.");
        } else {}
      } catch (e) {
        showSnackBarWidget(
            context, "Bu bilgiler sahip bir kullanıcı mevcut değil.");
      }
    } else if (password.length > 5 && !EmailValidator.validate(email)) {
      showSnackBarWidget(context, "Lütfen mail giriniz.");
    } else if (password == "" && EmailValidator.validate(email)) {
      showSnackBarWidget(context, "Lütfen şifre giriniz.");
    } else {
      showSnackBarWidget(context, "Lütfen alanları doğru doldurunuz.");
    }
  }

  userCreate(String uid) async {
    var document = await firestore.collection('users').doc(uid).get();
    var user = UserClass(
      email: document['email'],
      uid: document['uid'],
      photoUrl: document['photoUrl'],
      username: document['username'],
      name: document['name'],
      surname: document['surname'],
      bio: document['bio'],
      friends: List<String>.from(document['friends']),
      requests: List<String>.from(document['requests']),
      blocked: List<String>.from(document['requests']),
      photoPosts: List<PhotoPostClass>.from(document['photoPosts']),
      textPosts: List<TextPostClass>.from(document['textPosts']),
      chats: List<ChatClass>.from(document['chats']),
    );
    return user;
  }
}

class UserClass {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String name;
  final String surname;
  final String bio;
  final List friends;
  final List requests;
  final List blocked;
  final List<PhotoPostClass> photoPosts;
  final List<TextPostClass> textPosts;
  final List<ChatClass> chats;

  const UserClass({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.name,
    required this.surname,
    required this.bio,
    required this.friends,
    required this.requests,
    required this.blocked,
    required this.photoPosts,
    required this.textPosts,
    required this.chats,
  });

  UserClass.empty()
      : email = '',
        uid = '',
        photoUrl = '',
        username = '',
        name = '',
        surname = '',
        bio = '',
        friends = [],
        requests = [],
        blocked = [],
        photoPosts = [],
        textPosts = [],
        chats = [];

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "bio": bio,
        "email": email,
        "photoUrl": photoUrl,
        "username": username,
        "name": name,
        "surname": surname,
        "friends": friends,
        "requests": requests,
        "blocked": blocked,
        "photoPosts": photoPosts.map((data) => data.toJson()).toList(),
        "textPosts": textPosts.map((data) => data.toJson()).toList(),
        "chats": chats.map((data) => data.toJson()).toList(),
      };

  factory UserClass.fromSnapshot(DocumentSnapshot snapshot) {
    return UserClass(
      email: snapshot['email'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      username: snapshot['username'],
      name: snapshot['name'],
      surname: snapshot['surname'],
      bio: snapshot['bio'],
      friends: List<String>.from(snapshot['friends'] ?? []),
      requests: List<String>.from(snapshot['requests'] ?? []),
      blocked: List<String>.from(snapshot['blocked'] ?? []),
      photoPosts: (snapshot['photoPosts'] as List<dynamic>)
          .map((post) => PhotoPostClass(
                comment: post['comment'],
                commentersUid: post['commentersUid'],
                comments: post['comments'],
                likersUid: post['likersUid'],
                photoUrl: post['photoUrl'],
                date: post['date'],
              ))
          .toList(),
      textPosts: (snapshot['textPosts'] as List<dynamic>)
          .map(
            (post) => TextPostClass(
              commentersUid: post['commentersUid'],
              comments: post['comments'],
              likersUid: post['likersUid'],
              text: post['text'],
              title: post['title'],
              date: post['date'],
            ),
          )
          .toList(),
      chats: (snapshot['chats'] as List<dynamic>)
          .map(
            (post) => ChatClass(
              reciverUid:
                  post['reciverUid'], // 'receiverUid' olarak düzeltilmeli
              message1: (post['message1'] as List<dynamic>)
                  .map(
                    (msg) => MessageClass(
                      text: msg['text'],
                      date: msg['date'],
                    ),
                  )
                  .toList(),
              message2: (post['message2'] as List<dynamic>)
                  .map(
                    (msg) => MessageClass(
                      text: msg['text'],
                      date: msg['date'],
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

class PhotoPostClass {
  final String photoUrl;
  final String comment;
  final String date;
  final List likersUid;
  final List comments;
  final List commentersUid;

  const PhotoPostClass({
    required this.photoUrl,
    required this.comment,
    required this.date,
    required this.likersUid,
    required this.comments,
    required this.commentersUid,
  });

  Map<String, dynamic> toJson() => {
        "photoUrl": photoUrl,
        "comment": comment,
        "date": date,
        "likersUid": likersUid,
        "comments": comments,
        "commentersUid": commentersUid,
      };
}

class TextPostClass {
  final String title;
  final String text;
  final String date;
  final List likersUid;
  final List comments;
  final List commentersUid;

  const TextPostClass({
    required this.title,
    required this.text,
    required this.date,
    required this.likersUid,
    required this.comments,
    required this.commentersUid,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "text": text,
        "date": date,
        "likersUid": likersUid,
        "comments": comments,
        "commentersUid": commentersUid,
      };
}

class ChatClass {
  final String reciverUid;
  final List<MessageClass> message1;
  final List<MessageClass> message2;

  const ChatClass({
    required this.reciverUid,
    required this.message1,
    required this.message2,
  });

  ChatClass.empty()
      : reciverUid = '',
        message1 = [],
        message2 = [];

  Map<String, dynamic> toJson() => {
        "reciverUid": reciverUid,
        "message1": message1.map((data) => data.toJson()).toList(),
        "message2": message2.map((data) => data.toJson()).toList(),
      };

  factory ChatClass.fromSnapshot(DocumentSnapshot snapshot) {
    return ChatClass(
      reciverUid: snapshot['reciverUid'],
      message1: (snapshot['message1'] as List<dynamic>)
          .map(
            (post) => MessageClass(
              text: post['text'],
              date: post['date'],
            ),
          )
          .toList(),
      message2: (snapshot['message2'] as List<dynamic>)
          .map(
            (post) => MessageClass(
              text: post['text'],
              date: post['date'],
            ),
          )
          .toList(),
    );
  }
}

class MessageClass {
  final String text;
  final String date;

  const MessageClass({
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        "text": text,
        "date": date,
      };
}
