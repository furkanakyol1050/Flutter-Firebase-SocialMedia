import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/entry/providers.dart';

class RegisterPage extends ConsumerWidget {
  RegisterPage({super.key});

  final keyG = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(passVisibilityProvider.notifier).state = true;
        ref.read(visibilityProvider.notifier).state = true;
        ref.read(visibility2Provider.notifier).state = true;
        ref.read(mailRegisterProvider.notifier).state = "";
        ref.read(passRegisterProvider.notifier).state = "";
        ref.read(pass2RegisterProvider.notifier).state = "";
        ref.read(mailResetProvider.notifier).state = "";
        return true;
      },
      child: Scaffold(
        body: Form(
          key: keyG,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/bg2.png"),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: Designs().aLogo(100, 100),
                    ),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const RegisterText(),
                              MailTFF(
                                degisecekProvider:
                                    ref.read(mailRegisterProvider.notifier),
                              ),
                              PasswordTFF(
                                degisecekProvider:
                                    ref.read(passRegisterProvider.notifier),
                                gorunurlukProvider:
                                    ref.watch(visibilityProvider),
                                degisecekIkiProvider:
                                    ref.read(visibilityProvider.notifier),
                                degisken: 0,
                              ),
                              PasswordTFF(
                                degisecekProvider:
                                    ref.read(pass2RegisterProvider.notifier),
                                gorunurlukProvider:
                                    ref.watch(visibility2Provider),
                                degisecekIkiProvider:
                                    ref.read(visibility2Provider.notifier),
                                degisken: 1,
                                label: "Onay Şifresi",
                              ),
                            ],
                          ),
                          RegisterButton(keyG: keyG),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
