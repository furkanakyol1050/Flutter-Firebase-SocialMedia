import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smproject3/firebase_transactions.dart';
import 'package:smproject3/screens/home/providers.dart';
import 'package:smproject3/screens/home/widgets/createprofilewidgets.dart';

final photoCheckProvider = StateProvider((ref) => 0);

class CreateProfile extends ConsumerWidget {
  CreateProfile({super.key});

  final GlobalKey<FormState> keyG1 = GlobalKey<FormState>();
  final GlobalKey<FormState> keyG2 = GlobalKey<FormState>();
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //! YAZI BOYUTLARINI EŞİTLE
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: const Color.fromRGBO(237, 237, 237, 1),
            child: PageView(
              controller: ref.watch(pageControl2Provider),
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                  ),
                  child: Form(
                    key: keyG1,
                    child: Column(
                      children: [
                        //! 1/2 YAZISI
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "1/2",
                            style: GoogleFonts.nunito(
                              color: const Color.fromRGBO(23, 23, 23, 1),
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        //! SAYFA YAZISI
                        Text(
                          "Sana nasıl hitap edelim?",
                          style: GoogleFonts.nunito(
                            color: const Color.fromRGBO(23, 23, 23, 1),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //! RESİM EKLEME
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height:
                                        MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color:
                                            const Color.fromRGBO(23, 23, 23, 1),
                                        strokeAlign:
                                            BorderSide.strokeAlignOutside,
                                      ),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: ref
                                                .watch(photoUrlProvider)
                                                .isEmpty
                                            ? const AssetImage(
                                                "assets/defUser2.png",
                                              ) as ImageProvider
                                            : MemoryImage(
                                                ref.watch(photoUrlProvider)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      XFile? file =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        maxHeight: 1080,
                                        maxWidth: 1080,
                                      );
                                      if (file != null) {
                                        ref
                                            .read(photoUrlProvider.notifier)
                                            .state = await file.readAsBytes();
                                        ref
                                            .read(photoCheckProvider.notifier)
                                            .state = 1;
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add_a_photo,
                                      color: Color.fromRGBO(237, 237, 237, 1),
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              //! KULLANICI ADI TFF
                              GeneralTFF(
                                provider: ref.watch(usernameProvider.notifier),
                                icon: const Icon(
                                  Icons.person_3_outlined,
                                  color: Color.fromRGBO(23, 23, 23, 1),
                                ),
                                labelText: "Kullanıcı Adı",
                                maxLines: 1,
                                padding: 1,
                                a: 0,
                                controller: controller1,
                              ),
                            ],
                          ),
                        ),
                        //! İleri Tuşu
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: NextButton(keyG: keyG1),
                        ),
                        //! Geri Tuşu
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: CancelButton(
                            controllers: [
                              controller1,
                              controller2,
                              controller3,
                              controller4,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: keyG2,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                    ),
                    child: Column(
                      children: [
                        //! 2/2 YAZISI
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "2/2",
                            style: GoogleFonts.nunito(
                              color: const Color.fromRGBO(23, 23, 23, 1),
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        //! SAYFA YAZISI
                        Text(
                          "Hadi biraz kendinden bahset.",
                          style: GoogleFonts.nunito(
                            color: const Color.fromRGBO(23, 23, 23, 1),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          child: Column(
                            children: [
                              //! Ad TFF
                              GeneralTFF(
                                provider: ref.watch(nameProvider.notifier),
                                icon: const Icon(
                                  Icons.person_3_outlined,
                                  color: Color.fromRGBO(23, 23, 23, 1),
                                ),
                                labelText: "Ad",
                                maxLines: 1,
                                padding: 1,
                                a: 1,
                                controller: controller2,
                              ),
                              const SizedBox(height: 40),
                              //! Soyad TFF
                              GeneralTFF(
                                provider: ref.watch(surnameProvider.notifier),
                                icon: const Icon(
                                  Icons.person_3_outlined,
                                  color: Color.fromRGBO(23, 23, 23, 1),
                                ),
                                labelText: "Soyad",
                                maxLines: 1,
                                padding: 1,
                                a: 1,
                                controller: controller3,
                              ),
                              const SizedBox(height: 40),
                              //! Bio TFF
                              Text(
                                "Nasıl birisin?",
                                style: GoogleFonts.nunito(
                                  color: const Color.fromRGBO(23, 23, 23, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GeneralTFF(
                                provider: ref.watch(bioProvider.notifier),
                                icon: const Icon(
                                  Icons.my_library_books_rounded,
                                  color: Color.fromRGBO(23, 23, 23, 1),
                                ),
                                labelText: "",
                                maxLines: 5,
                                padding: 0,
                                a: 2,
                                controller: controller4,
                              ),
                            ],
                          ),
                        ),
                        //! Giriş Tuşu
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: EnterButton(keyG: keyG2),
                        ),
                        //! Geri Tuşu
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: CancelButton(
                            controllers: [
                              controller1,
                              controller2,
                              controller3,
                              controller4,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
