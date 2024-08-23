import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/entry/providers.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final keyG = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: keyG,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/bg1.png"),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Designs().aLogo(200, 200),
                  Column(
                    children: [
                      MailTFF(
                        degisecekProvider: ref.read(mailLoginProvider.notifier),
                      ),
                      PasswordTFF(
                        degisecekProvider: ref.read(passLoginProvider.notifier),
                        gorunurlukProvider: ref.watch(passVisibilityProvider),
                        degisecekIkiProvider:
                            ref.read(passVisibilityProvider.notifier),
                        degisken: 0,
                      ),
                      const PasswordReset(),
                    ],
                  ),
                  Column(children: [
                    const GoogleLoginButton(),
                    LoginButton(keyG: keyG)
                  ]),
                  const RegisterPageButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
