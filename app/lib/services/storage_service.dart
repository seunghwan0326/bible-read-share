import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/bible_meta.dart';
import '../models/room_entry.dart';

class StorageService {
  static const _progressKey = 'read_chapters_v1';
  static const _lastBookKey = 'last_book';
  static const _lastChapterKey = 'last_chapter';
  static const _textSizeKey = 'bible_text_size';
  static const _roomsKey = 'room_list_json_v134';
  static const _activeRoomKey = 'active_room_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<bool>> loadProgress() async {
    final prefs = await _prefs;
    final bits = List<bool>.filled(BibleMeta.totalChapters, false);
    final encoded = prefs.getString(_progressKey);
    if (encoded == null || encoded.isEmpty) return bits;
    try {
      final bytes = base64Decode(encoded);
      for (var i = 0; i < BibleMeta.totalChapters; i++) {
        final byteIndex = i >> 3;
        final bit = i & 7;
        if (byteIndex < bytes.length) {
          bits[i] = (bytes[byteIndex] & (1 << bit)) != 0;
        }
      }
    } catch (_) {}
    return bits;
  }

  Future<void> saveProgress(List<bool> bits) async {
    final prefs = await _prefs;
    final bytes = Uint8List((BibleMeta.totalChapters + 7) ~/ 8);
    for (var i = 0; i < BibleMeta.totalChapters; i++) {
      if (bits[i]) {
        bytes[i >> 3] |= 1 << (i & 7);
      }
    }
    var last = bytes.length - 1;
    while (last >= 0 && bytes[last] == 0) {
      last--;
    }
    final compact = last < 0 ? Uint8List(0) : Uint8List.sublistView(bytes, 0, last + 1);
    await prefs.setString(_progressKey, base64Encode(compact));
  }

  String encodeProgress(List<bool> bits) {
    final bytes = Uint8List((BibleMeta.totalChapters + 7) ~/ 8);
    for (var i = 0; i < BibleMeta.totalChapters; i++) {
      if (bits[i]) bytes[i >> 3] |= 1 << (i & 7);
    }
    var last = bytes.length - 1;
    while (last >= 0 && bytes[last] == 0) {
      last--;
    }
    final compact = last < 0 ? Uint8List(0) : Uint8List.sublistView(bytes, 0, last + 1);
    return base64Encode(compact);
  }

  Future<int> loadLastBook() async => (await _prefs).getInt(_lastBookKey) ?? 0;
  Future<int> loadLastChapter() async => (await _prefs).getInt(_lastChapterKey) ?? 1;

  Future<void> saveLastPosition(int book, int chapter) async {
    final prefs = await _prefs;
    await prefs.setInt(_lastBookKey, book);
    await prefs.setInt(_lastChapterKey, chapter);
  }

  Future<double> loadTextSize() async => (await _prefs).getDouble(_textSizeKey) ?? 18.0;
  Future<void> saveTextSize(double size) async => (await _prefs).setDouble(_textSizeKey, size);

  Future<List<RoomEntry>> loadRooms() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_roomsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(RoomEntry.fromMap)
          .where((e) => e.roomId.isNotEmpty && e.memberToken.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRooms(List<RoomEntry> rooms) async {
    final prefs = await _prefs;
    await prefs.setString(_roomsKey, jsonEncode(rooms.map((e) => e.toMap()).toList()));
  }

  Future<void> upsertRoom(RoomEntry room) async {
    final rooms = await loadRooms();
    final index = rooms.indexWhere((e) => e.roomId == room.roomId);
    if (index >= 0) {
      rooms[index] = room;
    } else {
      rooms.add(room);
    }
    await saveRooms(rooms);
    await setActiveRoom(room.roomId);
  }

  Future<String?> activeRoomId() async => (await _prefs).getString(_activeRoomKey);

  Future<void> setActiveRoom(String roomId) async {
    await (await _prefs).setString(_activeRoomKey, roomId);
  }

  Future<RoomEntry?> activeRoom() async {
    final id = await activeRoomId();
    final rooms = await loadRooms();
    if (rooms.isEmpty) return null;
    if (id != null) {
      for (final room in rooms) {
        if (room.roomId == id) return room;
      }
    }
    await setActiveRoom(rooms.first.roomId);
    return rooms.first;
  }
}
