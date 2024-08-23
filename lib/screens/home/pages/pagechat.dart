import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_fonts/google_fonts.dart';
import 'package:smproject3/screens/home/pages/pagemassenger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smproject3/screens/home/providers.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';

final messageProvider = StateProvider((ref) => "");

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatWidget extends ConsumerStatefulWidget {
  const ChatWidget({super.key});

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  static List<types.Message> _messages = [];
  late types.User _user;

  @override
  void initState() {
    super.initState();
    _messages = [];
    _user = types.User(
      id: ref.read(userDocumentProvider).asData!.value!.uid,
    );
    if (ref.read(chatProvider) != -1) {
      List<MessageClass> list1 = ref
          .read(userDocumentProvider)
          .asData!
          .value!
          .chats[ref.read(chatProvider)]
          .message1;

      List<MessageClass> list2 = ref
          .read(userDocumentProvider)
          .asData!
          .value!
          .chats[ref.read(chatProvider)]
          .message2;

      List<MessageClass> combinedList = [...list1, ...list2];

      Map<DateTime, MessageClass> mappedList = {};
      for (var message in combinedList) {
        DateTime parsedDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(message.date);
        mappedList[parsedDate] = message;
      }

      List<DateTime> sortedDates = mappedList.keys.toList()..sort();

      List<MessageClass> sortedMessages =
          sortedDates.map((date) => mappedList[date]!).toList();

      for (MessageClass message in sortedMessages) {
        _messages.insert(
          0,
          types.TextMessage(
            author: ref
                    .read(userDocumentProvider)
                    .asData!
                    .value!
                    .chats[ref.read(chatProvider)]
                    .message1
                    .contains(message)
                ? _user
                : types.User(id: ref.read(reciverUidProvider)),
            createdAt: DateFormat('yyyy-MM-dd HH:mm:ss')
                .parse(message.date)
                .millisecondsSinceEpoch,
            id: randomString(),
            text: message.text,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(23, 23, 23, 1),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                ref.watch(reciverProvider).photoUrl,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: [
                  Text(
                    ref.watch(reciverProvider).username,
                    style: GoogleFonts.nunito(
                      color: const Color.fromRGBO(237, 237, 237, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${ref.watch(reciverProvider).name} ${ref.watch(reciverProvider).surname}",
                    style: GoogleFonts.nunito(
                      color: const Color.fromRGBO(237, 237, 237, 1),
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
          backgroundColor: const Color.fromRGBO(237, 237, 237, 1),
          primaryColor: Colors.blue,
          inputBackgroundColor: const Color.fromRGBO(23, 23, 23, 1),
          inputTextColor: const Color.fromRGBO(237, 237, 237, 1),
          secondaryColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    DocumentSnapshot snapshot1 = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    UserClass currentUser2 = UserClass.fromSnapshot(snapshot1);
    MessageClass message1 = MessageClass(
      text: message.text,
      date: DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime.now(),
      ),
    );
    if (ref.watch(chatProvider) == -1) {
      //? İlk Konuşma
      currentUser2.chats.add(
        ChatClass(
          reciverUid: ref.watch(reciverUidProvider),
          message1: [message1],
          message2: [],
        ),
      );
    } else {
      //? Konuşma var
      currentUser2.chats[ref.watch(chatProvider)].message1.add(message1);
    }
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(ref.watch(reciverUidProvider))
        .get();
    UserClass reciverUser = UserClass.fromSnapshot(snapshot);
    int uidIndex = reciverUser.chats
        .indexWhere((element) => element.reciverUid == currentUser2.uid);
    if (uidIndex < 0) {
      reciverUser.chats.add(
        ChatClass(
          reciverUid: currentUser2.uid,
          message1: [],
          message2: [message1],
        ),
      );
    } else {
      reciverUser.chats[uidIndex].message2.add(message1);
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(ref.watch(reciverUidProvider))
        .update(
      {
        'chats': reciverUser.chats.map((data) => data.toJson()).toList(),
      },
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser2.uid)
        .update(
      {
        'chats': currentUser2.chats.map((data) => data.toJson()).toList(),
      },
    );
    if (ref.watch(chatProvider) == -1) {
      ref.read(chatProvider.notifier).state = currentUser2.chats.length - 1;
    }
    _addMessage(textMessage);
  }
}
