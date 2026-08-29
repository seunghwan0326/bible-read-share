import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../data/bible_meta.dart';
import '../models/room_entry.dart';
import 'storage_service.dart';

class RoomService {
  RoomService(this.storage);

  final StorageService storage;

  static const supabaseUrl = 'https://fwvsospcusbuksdihcbs.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3dnNvc3BjdXNidWtzZGloY2JzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU1NTI0ODYsImV4cCI6MjEwMTEyODQ4Nn0._49qF_8NsbXMsyjrYhvTDzrY2iTq_nplh4uKTqMdZNo';

  String newMemberToken() => const Uuid().v4().replaceAll('-', '') + const Uuid().v4().replaceAll('-', '');

  Future<dynamic> _rpc(String function, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/$function'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      },
      body: jsonEncode(body),
    );

    final text = response.body;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final err = jsonDecode(text) as Map<String, dynamic>;
        throw Exception('${err['message'] ?? text}');
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) rethrow;
        throw Exception(text.isEmpty ? 'HTTP ${response.statusCode}' : text);
      }
    }
    if (text.trim().isEmpty) return null;
    return jsonDecode(text);
  }

  Future<RoomEntry> createRoom(String roomName, String displayName) async {
    final token = newMemberToken();
    final data = await _rpc('bible_v13_create_room', {
      'p_room_name': roomName.trim(),
      'p_display_name': displayName.trim(),
      'p_member_token': token,
    }) as Map<String, dynamic>;

    final room = RoomEntry(
      roomId: '${data['room_id']}',
      roomName: '${data['room_name']}',
      inviteCode: '${data['invite_code']}',
      memberId: '${data['member_id']}',
      memberToken: token,
      displayName: displayName.trim(),
    );
    await storage.upsertRoom(room);
    return room;
  }

  Future<RoomEntry> joinRoom(String inviteCode, String displayName) async {
    final token = newMemberToken();
    final data = await _rpc('bible_v13_join_room', {
      'p_invite_code': inviteCode.trim().toUpperCase(),
      'p_display_name': displayName.trim(),
      'p_member_token': token,
    }) as Map<String, dynamic>;

    final room = RoomEntry(
      roomId: '${data['room_id']}',
      roomName: '${data['room_name']}',
      inviteCode: '${data['invite_code']}',
      memberId: '${data['member_id']}',
      memberToken: token,
      displayName: displayName.trim(),
    );
    await storage.upsertRoom(room);
    return room;
  }

  Future<Map<String, dynamic>> getRoom(RoomEntry room) async {
    final data = await _rpc('bible_v13_get_room', {
      'p_room_id': room.roomId,
      'p_member_token': room.memberToken,
    });
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> syncProgress(
    RoomEntry room,
    List<bool> progress,
    int lastBook,
    int lastChapter,
  ) async {
    final readCount = progress.where((e) => e).length;
    await _rpc('bible_v13_sync_progress', {
      'p_room_id': room.roomId,
      'p_member_token': room.memberToken,
      'p_progress_base64': storage.encodeProgress(progress),
      'p_read_count': readCount.clamp(0, BibleMeta.totalChapters),
      'p_last_book': lastBook.clamp(0, 65),
      'p_last_chapter': lastChapter.clamp(1, 150),
    });
  }

  Future<void> syncAllRooms(
    List<bool> progress,
    int lastBook,
    int lastChapter,
  ) async {
    final rooms = await storage.loadRooms();
    for (final room in rooms) {
      try {
        await syncProgress(room, progress, lastBook, lastChapter);
      } catch (_) {
        // One unavailable room must not block syncing the others.
      }
    }
  }

  Future<void> addPrayer(RoomEntry room, String body) async {
    await _rpc('bible_v13_add_prayer', {
      'p_room_id': room.roomId,
      'p_member_token': room.memberToken,
      'p_body': body.trim(),
    });
  }

  Future<void> setPrayerAnswered(RoomEntry room, String prayerId, bool answered) async {
    await _rpc('bible_v13_set_prayer_answered', {
      'p_room_id': room.roomId,
      'p_member_token': room.memberToken,
      'p_prayer_id': prayerId,
      'p_answered': answered,
    });
  }

  Future<void> deletePrayer(RoomEntry room, String prayerId) async {
    await _rpc('bible_v13_delete_prayer', {
      'p_room_id': room.roomId,
      'p_member_token': room.memberToken,
      'p_prayer_id': prayerId,
    });
  }
}
