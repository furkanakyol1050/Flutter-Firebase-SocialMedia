import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/home/pages/pagesinglepostview.dart';
import 'package:smproject3/screens/home/providers.dart';

final homePageUsersProvider = StateProvider<List<UserClass>>((ref) => []);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocument = ref.watch(userDocumentProvider).asData?.value;

    final size = MediaQuery.of(context).size;
    return userDocument != null
        ? SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(23, 23, 23, 1),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(23, 23, 23, 1),
                    ),
                    height: size.height * 0.15,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: size.height * 0.06,
                          child: Text(
                            "Ana Sayfa",
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                        const SearchTFF(),
                        (userDocument.friends.isNotEmpty)
                            ? FutureBuilder<List>(
                                future: fetchUsers(userDocument.friends, ref),
                                builder: (BuildContext context,
                                    AsyncSnapshot<List> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Center(
                                        child: Container(
                                          margin: const EdgeInsets.all(26),
                                          width: size.width * 0.8,
                                          height: size.height * 0.6,
                                          child: const SpinKitFadingCube(
                                            color:
                                                Color.fromRGBO(68, 68, 68, 1),
                                            size: 50.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    List? posts = snapshot.data;
                                    return posts != null
                                        ? PostViewWidget(
                                            posts: posts, size: size)
                                        : Container(
                                            height: size.height * 0.8,
                                            width: size.width * 0.6,
                                            alignment: Alignment.center,
                                            child: const SpinKitFadingCube(
                                              color:
                                                  Color.fromRGBO(23, 23, 23, 1),
                                              size: 50.0,
                                            ),
                                          );
                                  }
                                },
                              )
                            : Container(
                                width: size.width,
                                height: size.height * 0.75,
                                alignment: Alignment.center,
                                child: Container(
                                  width: size.width * 0.7,
                                  height: size.width * 0.3,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Henüz kimseyi arkadaş\n   olarak eklemediniz.",
                                    style: GoogleFonts.nunito(
                                      color:
                                          const Color.fromRGBO(23, 23, 23, 1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : const CostomIndicator();
  }
}

class PostViewWidget extends StatelessWidget {
  const PostViewWidget({
    super.key,
    required this.posts,
    required this.size,
  });

  final List posts;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.isEmpty ? 1 : posts.length,
      itemBuilder: (BuildContext context, int index) {
        if (posts.isNotEmpty) {
          if (posts[index] is PhotoPostClass) {
            return PhotoPostWidget(
              posts: posts,
              index: index,
            );
          } else {
            return TextPostWidget(
              posts: posts,
              index: index,
            );
          }
        } else {
          return Container(
            width: size.width,
            height: size.height * 0.75,
            alignment: Alignment.center,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.3,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Text(
                "  Arkadaşlarının sana\ngösterecek birşeyi yok.",
                style: GoogleFonts.nunito(
                  color: const Color.fromRGBO(23, 23, 23, 1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class TextPostWidget extends ConsumerWidget {
  final List posts;
  final int index;
  const TextPostWidget({
    super.key,
    required this.posts,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String formattedDate = DateFormat('dd MMMM HH:mm', 'tr')
        .format(DateTime.parse(posts[index].date));
    final userDocument = ref.watch(userDocumentProvider).asData!.value!;
    final size = MediaQuery.of(context).size;
    final List<UserClass> users = ref.watch(homePageUsersProvider);
    final UserClass user = users.firstWhere((user) =>
        user.textPosts.indexWhere((post) => post.text == posts[index].text) >=
        0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(selectedUserProvider.notifier).state.add(user);
              Navigator.pushNamed(context, '/selecteduser');
            },
            child: Container(
              width: size.width * 0.9,
              padding: const EdgeInsets.only(
                bottom: 10,
                top: 10,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
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
                            color: Colors.black,
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
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    posts[index].title,
                    style: GoogleFonts.nunito(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    posts[index].text,
                    style: GoogleFonts.nunito(
                      letterSpacing: 1,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: size.width * 0.9,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LikeButton(
                  padding: const EdgeInsets.all(10),
                  bubblesColor: const BubblesColor(
                    dotPrimaryColor: Color.fromRGBO(23, 23, 23, 1),
                    dotSecondaryColor: Color.fromRGBO(68, 68, 68, 1),
                  ),
                  likeCount: posts[index].likersUid.length,
                  isLiked: posts[index].likersUid.contains(userDocument.uid),
                  onTap: (isLiked) async {
                    if (!isLiked) {
                      user.textPosts[user.textPosts.indexOf(posts[index])]
                          .likersUid
                          .add(userDocument.uid);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update(user.toJson());
                    } else {
                      user.textPosts[user.textPosts.indexOf(posts[index])]
                          .likersUid
                          .remove(userDocument.uid);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update(user.toJson());
                    }
                    return !isLiked;
                  },
                ),
                TextButton.icon(
                  style: const ButtonStyle(
                    overlayColor: MaterialStatePropertyAll(
                      Color.fromRGBO(237, 237, 237, 1),
                    ),
                  ),
                  onPressed: () {
                    ref.read(postIndexProvider.notifier).state =
                        user.textPosts.indexOf(posts[index]);
                    ref.read(choiceProvider.notifier).state = 1;
                    ref.read(selectedUserPostProvider.notifier).state = user;
                    Navigator.pushNamed(context, '/postview');
                  },
                  icon: Icon(
                    Icons.comment,
                    color: Colors.grey.shade700,
                  ),
                  label: Text(
                    "Yorumlar",
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoPostWidget extends ConsumerWidget {
  final List posts;
  final int index;
  const PhotoPostWidget({
    super.key,
    required this.posts,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String formattedDate = DateFormat('dd MMMM HH:mm', 'tr')
        .format(DateTime.parse(posts[index].date));
    final userDocument = ref.watch(userDocumentProvider).asData!.value!;
    final size = MediaQuery.of(context).size;
    final List<UserClass> users = ref.watch(homePageUsersProvider);
    final UserClass user = users.firstWhere((user) =>
        user.photoPosts
            .indexWhere((post) => post.photoUrl == posts[index].photoUrl) >=
        0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(selectedUserProvider.notifier).state.add(user);
              Navigator.pushNamed(context, '/selecteduser');
            },
            child: Container(
              width: size.width * 0.9,
              padding: const EdgeInsets.only(
                bottom: 10,
                top: 10,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
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
                            color: Colors.black,
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
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formattedDate,
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: size.width * 0.9,
            width: size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: SizedBox(
              child: Image.network(
                posts[index].photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: size.width * 0.9,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LikeButton(
                  padding: const EdgeInsets.all(10),
                  bubblesColor: const BubblesColor(
                    dotPrimaryColor: Color.fromRGBO(23, 23, 23, 1),
                    dotSecondaryColor: Color.fromRGBO(68, 68, 68, 1),
                  ),
                  likeCount: posts[index].likersUid.length,
                  isLiked: posts[index].likersUid.contains(userDocument.uid),
                  onTap: (isLiked) async {
                    if (!isLiked) {
                      user.photoPosts[user.photoPosts.indexOf(posts[index])]
                          .likersUid
                          .add(userDocument.uid);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update(user.toJson());
                    } else {
                      user.photoPosts[user.photoPosts.indexOf(posts[index])]
                          .likersUid
                          .remove(userDocument.uid);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update(user.toJson());
                    }
                    return !isLiked;
                  },
                ),
                TextButton.icon(
                  style: const ButtonStyle(
                    overlayColor: MaterialStatePropertyAll(
                      Color.fromRGBO(237, 237, 237, 1),
                    ),
                  ),
                  onPressed: () {
                    ref.read(postIndexProvider.notifier).state =
                        user.photoPosts.indexOf(posts[index]);
                    ref.read(choiceProvider.notifier).state = 0;
                    ref.read(selectedUserPostProvider.notifier).state = user;
                    Navigator.pushNamed(context, '/postview');
                  },
                  icon: Icon(
                    Icons.comment,
                    color: Colors.grey.shade700,
                  ),
                  label: Text(
                    "Yorumlar",
                    style: GoogleFonts.nunito(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchTFF extends ConsumerWidget {
  const SearchTFF({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchController searchController = SearchController();
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: size.width * 0.92,
        height: size.width * 0.16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color.fromRGBO(68, 68, 68, 1),
        ),
        child: Container(
          alignment: Alignment.center,
          width: size.width * 0.90,
          height: size.width * 0.15,
          child: SearchAnchor.bar(
            viewHeaderHintStyle: GoogleFonts.nunito(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            viewHeaderTextStyle: GoogleFonts.nunito(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            viewLeading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).requestFocus(FocusNode());
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            onChanged: (value) async {
              if (value.length > 1) {
                QuerySnapshot query = await FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isGreaterThanOrEqualTo: value)
                    .where('username', isLessThan: '${value}z')
                    .get();
                ref.read(searchListProvider.notifier).state = query.docs
                    .where((doc) =>
                        doc['uid'] !=
                        ref.watch(userProvider).asData!.value!.uid)
                    .map((doc) => UserClass.fromSnapshot(doc))
                    .toList();
              } else {
                ref.read(searchListProvider.notifier).state = [];
              }
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              return List<ListTile>.generate(
                ref.watch(searchListProvider).length,
                (int index) {
                  final item = ref.watch(searchListProvider)[index];
                  return ListTile(
                    title: Text(
                      item.username,
                      style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    leading: Container(
                      width: size.width * 0.10,
                      height: size.width * 0.10,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: const Color.fromRGBO(23, 23, 23, 1),
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          // ignore: unnecessary_null_comparison
                          image: item.photoUrl != null
                              ? NetworkImage(item.photoUrl)
                              : const AssetImage("assets/defUser.png")
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      "${item.name} ${item.surname}",
                      style: GoogleFonts.nunito(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () {
                      ref.read(selectedUserProvider.notifier).state.add(item);
                      //controller.closeView(item.username);//! HATALI
                      Navigator.pushNamed(context, '/selecteduser');
                    },
                  );
                },
              );
            },
            searchController: searchController,
            textCapitalization: TextCapitalization.sentences,
            barHintText: "Arkadaşlarını Ara",
            barShape: MaterialStateProperty.resolveWith<OutlinedBorder>(
              (Set<MaterialState> states) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color.fromRGBO(23, 23, 23, 1),
                    width: 3,
                  ),
                );
              },
            ),
            barTextStyle: MaterialStatePropertyAll(
              GoogleFonts.nunito(
                color: const Color.fromRGBO(23, 23, 23, 1),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<List> fetchUsers(List friends, WidgetRef ref) async {
  //* kullanıcılar -> bütün postlar -> sıralama
  List<UserClass> users = [];
  List posts = [];
  for (String userId in friends) {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    users.add(UserClass.fromSnapshot(snapshot));
  }
  for (UserClass user in users) {
    posts.addAll(user.photoPosts);
    posts.addAll(user.textPosts);
  }
  //DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDateString);
  ref.read(homePageUsersProvider.notifier).state = users;
  posts.sort((a, b) => a.date.compareTo(b.date));
  return posts.reversed.toList();
}
