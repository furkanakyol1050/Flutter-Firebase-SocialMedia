import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:smproject3/screens/home/providers.dart';

class NavBar extends ConsumerWidget {
  const NavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            tabBorderRadius: 20,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: const Color.fromARGB(255, 17, 14, 14),
            iconSize: 18,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            tabs: [
              GButton(
                icon: BootstrapIcons.house,
                iconSize: 20,
                text: 'Ana Sayfa',
                textStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              GButton(
                backgroundGradient: const LinearGradient(
                  colors: [Colors.pink, Colors.red],
                ),
                icon: BootstrapIcons.plus_lg,
                iconSize: 20,
                iconActiveColor: Colors.white,
                text: 'Paylaş',
                textStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              GButton(
                icon: BootstrapIcons.chat_text,
                iconSize: 20,
                text: 'Mesajlar',
                textStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              GButton(
                icon: BootstrapIcons.person,
                iconSize: 20,
                text: 'Profil',
                textStyle: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
            selectedIndex: ref.watch(pageNoProvider),
            onTabChange: (index) {
              ref.read(pageNoProvider.notifier).state = index;
              ref.watch(pageControlProvider).animateToPage(
                    index,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.ease,
                  );
            },
          ),
        ),
      ),
    );
  }
}

/*
onTap: (index) {
        ref.read(pageNoProvider.notifier).state = index;
        ref.watch(pageControlProvider).animateToPage(
              index,
              duration: const Duration(milliseconds: 1),
              curve: Curves.decelerate,
            );
      },
*/