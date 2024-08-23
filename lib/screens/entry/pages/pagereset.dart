import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smproject3/screens/entry/widgets.dart';
import 'package:smproject3/screens/entry/providers.dart';

class PasswordResPage extends ConsumerWidget {
  PasswordResPage({super.key});

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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/bg3.png"),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      alignment: Alignment.centerRight,
                      child: Designs().aLogo(100, 100),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Designs().textStyle1("Şifreni mi unuttun?", 30),
                          Designs().textStyle2(
                            "\n       Hesabınıza yeniden giriş\nsağlamak için şifrenizi yenileyin.\n",
                            20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 60),
                            child: MailTFF(
                              degisecekProvider:
                                  ref.watch(mailResetProvider.notifier),
                            ),
                          ),
                          SendMail(keyG: keyG),
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
