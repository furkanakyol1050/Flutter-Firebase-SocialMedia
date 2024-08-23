import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/entry/pages/pagelogin.dart';
import 'package:smproject3/screens/entry/providers.dart';
import 'package:smproject3/screens/home/pagemain.dart';
import 'package:smproject3/screens/home/pages/pagecreateprofile.dart';
import 'package:smproject3/screens/home/providers.dart';

//*--------------------------------------------------------
//* Register page

class RegisterText extends StatelessWidget {
  const RegisterText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Designs().textStyle1("Sen de Bize Katıl!", 40),
    );
  }
}

class RegisterButton extends ConsumerWidget {
  final GlobalKey<FormState> keyG;

  const RegisterButton({
    super.key,
    required this.keyG,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
          onPressed: () async {
            FBAuth().singIn(
              ref.watch(mailRegisterProvider),
              ref.watch(passRegisterProvider),
              ref.watch(pass2RegisterProvider),
              ref.watch(auth),
              keyG,
              context,
            );
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: Designs().buttonStyle(),
          child: Designs().textStyle3("Kayıt Ol")),
    );
  }
}

//*--------------------------------------------------------
//* Password Reset page

class SendMail extends ConsumerWidget {
  final GlobalKey<FormState> keyG;

  const SendMail({
    super.key,
    required this.keyG,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
        onPressed: () async {
          if (keyG.currentState!.validate() &&
              ref.watch(mailResetProvider).isNotEmpty) {
            try {
              UserCredential userCredential =
                  await ref.watch(auth).createUserWithEmailAndPassword(
                        email: ref.watch(mailResetProvider),
                        password: '123456',
                      );
              await userCredential.user!.delete();
              // ignore: use_build_context_synchronously
              showSnackBarWidget(
                context,
                "Lütfen kayıtlı bir E-posta giriniz.",
              );
            } catch (e) {
              if (e is FirebaseAuthException &&
                  e.code == 'email-already-in-use') {
                await ref.watch(auth).sendPasswordResetEmail(
                    email: ref.watch(mailResetProvider));
                // ignore: use_build_context_synchronously
                showSnackBarWidget(
                  context,
                  "Lütfen gönderdiğimiz E-postayı kontrol edin.",
                );
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, '/');
              } else {
                // ignore: use_build_context_synchronously
                showSnackBarWidget(
                  context,
                  "Sistem hatası oluştu. Daha sonra tekrar deneyiniz.",
                );
              }
            }
          } else {
            showSnackBarWidget(
              context,
              "Lütfen mail giriniz.",
            );
          }
        },
        style: Designs().buttonStyle(),
        child: Designs().textStyle3("Şifre Yenileme E-postası Gönder"),
      ),
    );
  }
}

//*--------------------------------------------------------
//* Login page

class LoginButton extends ConsumerWidget {
  final GlobalKey<FormState> keyG;

  const LoginButton({
    super.key,
    required this.keyG,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: OutlinedButton(
        onPressed: () async {
          ref.read(stepProvider.notifier).state = 0;
          FBAuth().logIn(
            ref.watch(mailLoginProvider),
            ref.watch(passLoginProvider),
            ref.watch(auth),
            keyG,
            context,
          );
          Navigator.of(context, rootNavigator: true).pop();
        },
        style: Designs().buttonStyle(),
        child: Designs().textStyle3("Giriş Yap"),
      ),
    );
  }
}

class GoogleLoginButton extends ConsumerWidget {
  const GoogleLoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.only(bottom: 20, top: 40),
      child: ElevatedButton.icon(
        onPressed: () async {
          ref.read(stepProvider.notifier).state = 0;
          try {
            await FBAuth().googleLogIn(context);

            // ignore: use_build_context_synchronously
            Navigator.of(context, rootNavigator: true).pop();
          } catch (e) {
            // ignore: use_build_context_synchronously
            Navigator.of(context, rootNavigator: true).pop();
            showSnackBarWidget(
              // ignore: use_build_context_synchronously
              context,
              "Gmail ile giriş yapılamadı.",
            );
          }
        },
        style: Designs().buttonStyleGoogle(),
        icon: const Icon(
          BootstrapIcons.google,
          color: Colors.white,
        ),
        label: Designs().textStyle3("Google Giriş Yap"),
      ),
    );
  }
}

class RegisterPageButton extends StatelessWidget {
  const RegisterPageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Bir hesabın yok mu?",
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          TextButton(
            style: const ButtonStyle(
              overlayColor: MaterialStatePropertyAll(Colors.transparent),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: Text(
              "Hemen Kaydol.",
              style: GoogleFonts.nunito(
                color: const Color.fromRGBO(237, 237, 237, 1),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordReset extends StatelessWidget {
  const PasswordReset({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.only(
          top: 10,
        ),
        alignment: Alignment.centerRight,
        child: TextButton(
          style: const ButtonStyle(
            overlayColor: MaterialStatePropertyAll(Colors.transparent),
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/reset');
          },
          child: Text(
            "Şifremi unuttum",
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ));
  }
}

//*--------------------------------------------------------
//* Genel

class MailTFF extends ConsumerWidget {
  final dynamic degisecekProvider;

  const MailTFF({
    super.key,
    required this.degisecekProvider,
  }); //return EmailValidator.validate(value!) ? null : "Geçersiz mail"

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextFormField(
        validator: (value) {
          return (EmailValidator.validate(value!) || value.isEmpty) ? null : "";
        },
        onChanged: (value) {
          degisecekProvider.state = value;
        },
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color.fromRGBO(237, 237, 237, 1),
        cursorErrorColor: const Color.fromRGBO(237, 237, 237, 1),
        cursorWidth: 3,
        cursorRadius: const Radius.circular(10),
        cursorOpacityAnimates: true,
        style: const TextStyle(
          color: Color.fromRGBO(237, 237, 237, 1),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromRGBO(23, 23, 23, 0.5),
          errorStyle: const TextStyle(fontSize: 0.01),
          contentPadding: const EdgeInsets.only(left: 30),
          labelText: "Email",
          labelStyle: GoogleFonts.nunito(
            color: const Color.fromRGBO(237, 237, 237, 1),
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: const Icon(
            Icons.email_rounded,
            color: Color.fromRGBO(237, 237, 237, 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PasswordTFF extends ConsumerWidget {
  final dynamic degisecekProvider;
  final dynamic gorunurlukProvider;
  final dynamic degisecekIkiProvider;
  final dynamic degisken;
  late String labelText; // labelText alanını late olarak işaretliyoruz

  PasswordTFF({
    super.key,
    required this.degisecekProvider,
    required this.gorunurlukProvider,
    required this.degisecekIkiProvider,
    required this.degisken,
    String label = "Şifre",
  }) {
    labelText = label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(
        top: 30,
      ),
      child: TextFormField(
        validator: (value) {
          if (degisken == 1) {
            return (value!.length < 6 && value.isNotEmpty) ||
                    ref.watch(passRegisterProvider).toString() !=
                        ref.watch(pass2RegisterProvider).toString()
                ? ""
                : null;
          } else {
            return (value!.length < 6 && value.isNotEmpty) ? "" : null;
          }
        },
        onChanged: (value) {
          degisecekProvider.state = value;
        },
        keyboardType: TextInputType.visiblePassword,
        obscureText: gorunurlukProvider,
        cursorColor: const Color.fromRGBO(237, 237, 237, 1),
        cursorErrorColor: Colors.white,
        cursorWidth: 3,
        cursorRadius: const Radius.circular(10),
        cursorOpacityAnimates: true,
        style: GoogleFonts.nunito(
          color: const Color.fromRGBO(237, 237, 237, 1),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 4,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromRGBO(23, 23, 23, 0.5),
          errorStyle: const TextStyle(fontSize: 0.01),
          contentPadding: const EdgeInsets.only(left: 30),
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Color.fromRGBO(237, 237, 237, 1),
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
          prefixIcon: const Icon(
            Icons.lock_rounded,
            color: Color.fromRGBO(237, 237, 237, 1),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              gorunurlukProvider ? Icons.visibility_off : Icons.visibility,
              color: const Color.fromRGBO(237, 237, 237, 1),
            ),
            onPressed: () {
              degisecekIkiProvider.state = gorunurlukProvider ? false : true;
            },
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color.fromRGBO(237, 237, 237, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

Widget check(BuildContext context) {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.active) {
        var user = snapshot.data;
        if (user != null) {
          return StreamBuilder<ConnectivityResult>(
            stream: Connectivity().onConnectivityChanged,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                var connectivityResult = snapshot.data;
                if (connectivityResult == ConnectivityResult.none) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color.fromRGBO(23, 23, 23, 1),
                    ),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Center(
                        child: Text(
                          'İnternet Bağlantısı Yok',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      content: const Text(
                        'Lütfen internet bağlantınızı kontrol edin.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                } else {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        var userData =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        var username = userData?['username'] as String?;
                        if (username != null &&
                            username.isNotEmpty &&
                            username != "") {
                          return const MainPage();
                        } else {
                          return CreateProfile();
                        }
                      } else {
                        return const CostomIndicator();
                      }
                    },
                  );
                }
              } else {
                return const CostomIndicator();
              }
            },
          );
        } else {
          return LoginPage();
        }
      } else {
        return const CostomIndicator();
      }
    },
  );
}

class CostomIndicator extends StatelessWidget {
  const CostomIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color.fromRGBO(23, 23, 23, 1),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCube(
              color: Colors.white,
              size: 50.0,
            ),
            SizedBox(height: 20),
            Text(
              "Lütfen bekleyin...",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                decorationColor: Color.fromRGBO(68, 68, 68, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showSnackBarWidget(BuildContext context, String yazi) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black87,
      content: Center(
        child: Text(
          yazi,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}

class Designs {
  dynamic background(Color colorX, Color colorY, Color colorZ) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colorX, colorY, colorZ],
      ),
    );
  }

  dynamic aLogo(double height, double width) {
    return Image.asset(
      'assets/logo.png',
      height: height,
      width: width,
    );
  }

  dynamic textStyle1(String text, double size) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        color: const Color.fromRGBO(23, 23, 23, 1),
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
    );
  }

  dynamic textStyle2(String text, double size) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        color: const Color.fromRGBO(23, 23, 23, 1),
        fontSize: size,
      ),
    );
  }

  dynamic textStyle3(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        color: const Color.fromRGBO(237, 237, 237, 1),
        fontWeight: FontWeight.bold,
        fontSize: 20,
        letterSpacing: 1,
      ),
    );
  }

  dynamic buttonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color.fromRGBO(237, 237, 237, 1),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(
        color: Colors.white,
        width: 2,
      ),
    );
  }

  dynamic buttonStyleGreen() {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: const Color.fromRGBO(237, 237, 237, 1),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(
        color: Color.fromRGBO(237, 237, 237, 1),
        width: 2,
      ),
    );
  }

  dynamic buttonStyleBlue() {
    return ButtonStyle(
      overlayColor: const MaterialStatePropertyAll(
        Color.fromRGBO(237, 237, 237, 1),
      ),
      backgroundColor: const MaterialStatePropertyAll(
        Color.fromRGBO(68, 68, 68, 1),
      ),
      foregroundColor: const MaterialStatePropertyAll(
        Color.fromRGBO(237, 237, 237, 1),
      ),
      minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      side: const MaterialStatePropertyAll(
        BorderSide(
          color: Color.fromRGBO(237, 237, 237, 1),
          width: 2,
        ),
      ),
    );
  }

  dynamic buttonStyleGoogle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(23, 23, 23, 0.5),
      foregroundColor: const Color.fromRGBO(237, 237, 237, 1),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: const BorderSide(
        color: Color.fromRGBO(237, 237, 237, 1),
        width: 2,
      ),
    );
  }
}
