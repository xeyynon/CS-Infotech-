import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  // The first frame is the loading animation; the saved preferences are read
  // behind it (see Bootstrap).
  runApp(const Bootstrap());
}
