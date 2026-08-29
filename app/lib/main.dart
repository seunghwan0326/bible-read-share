import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/bible_service.dart';
import 'services/room_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BibleReadShareApp());
}

class BibleReadShareApp extends StatelessWidget {
  const BibleReadShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final bible = BibleService();
    final rooms = RoomService(storage);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '함께읽는성경',
      theme: buildAppTheme(),
      home: HomeScreen(
        storage: storage,
        bibleService: bible,
        roomService: rooms,
      ),
    );
  }
}
