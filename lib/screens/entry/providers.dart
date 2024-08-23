import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//*--------------------------------------------------------
//* Register page

final mailRegisterProvider = StateProvider((ref) => "");

final passRegisterProvider = StateProvider((ref) => "");

final visibilityProvider = StateProvider((ref) => true);

final pass2RegisterProvider = StateProvider((ref) => "");

final visibility2Provider = StateProvider((ref) => true);

//*--------------------------------------------------------
//* Password Reset page

final mailResetProvider = StateProvider((ref) => "");

//*--------------------------------------------------------
//* Login page

final passVisibilityProvider = StateProvider((ref) => true);

final auth = StateProvider((ref) => FirebaseAuth.instance);

final mailLoginProvider = StateProvider((ref) => "");

final passLoginProvider = StateProvider((ref) => "");
