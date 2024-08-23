import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smproject3/screens/home/pages/pagehome.dart';
import 'package:smproject3/screens/home/pages/pagemassenger.dart';
import 'package:smproject3/screens/home/pages/pageprofile.dart';
import 'package:smproject3/screens/home/pages/pageshare.dart';
import 'package:smproject3/screens/home/providers.dart';
import 'package:smproject3/screens/home/widgets/navbarwidget.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: Center(
        child: PageView(
          controller: ref.watch(pageControlProvider),
          onPageChanged: (no) {
            ref.read(pageNoProvider.notifier).state = no;
            ref.read(sharedPhotoProvider.notifier).state = Uint8List(0);
            ref.read(changeProvider.notifier).state = 0;
          },
          children: [
            const HomePage(),
            SharePage(),
            const MessangerPage(),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
