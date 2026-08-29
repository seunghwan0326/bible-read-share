import 'package:flutter/material.dart';

import '../models/room_entry.dart';
import '../services/room_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'room_detail_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({
    super.key,
    required this.storage,
    required this.roomService,
  });

  final StorageService storage;
  final RoomService roomService;

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<RoomEntry> rooms = [];
  String? activeId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final loaded = await widget.storage.loadRooms();
    final active = await widget.storage.activeRoomId();
    if (!mounted) return;
    setState(() {
      rooms = loaded;
      activeId = active;
    });
  }

  Future<String?> _ask(String title, String label, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _createRoom() async {
    final roomName = await _ask('새 방 만들기', '방 제목');
    if (roomName == null || roomName.isEmpty) return;
    final displayName = await _ask('새 방 만들기', '내 이름');
    if (displayName == null || displayName.isEmpty) return;
    try {
      final room = await widget.roomService.createRoom(roomName, displayName);
      await _reload();
      if (!mounted) return;
      await _open(room);
    } catch (e) {
      _error(e);
    }
  }

  Future<void> _joinRoom() async {
    final code = await _ask('초대코드로 참여', '8자리 초대코드');
    if (code == null || code.isEmpty) return;
    final displayName = await _ask('초대코드로 참여', '내 이름');
    if (displayName == null || displayName.isEmpty) return;
    try {
      final room = await widget.roomService.joinRoom(code, displayName);
      await _reload();
      if (!mounted) return;
      await _open(room);
    } catch (e) {
      _error(e);
    }
  }

  Future<void> _open(RoomEntry room) async {
    await widget.storage.setActiveRoom(room.roomId);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDetailScreen(
          room: room,
          storage: widget.storage,
          roomService: widget.roomService,
        ),
      ),
    );
    await _reload();
  }

  void _error(Object e) {
    if (!mounted) return;
    final raw = e.toString();
    final message = raw.contains('Failed host lookup') ||
            raw.contains('SocketException') ||
            raw.contains('ClientException')
        ? '인터넷 연결을 확인해 주세요. 계속되면 최신 앱으로 업데이트해 주세요.'
        : '오류: $raw';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 방')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '가족·교회·친구 등 여러 방을 만들 수 있어요. '
            '방마다 멤버와 기도제목은 따로 관리되고, 내 말씀 읽기 진도는 가입한 모든 방에 자동 반영됩니다.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _createRoom,
                  icon: const Icon(Icons.add),
                  label: const Text('새 방'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _joinRoom,
                  icon: const Icon(Icons.login),
                  label: const Text('초대코드 참여'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('내 방 ${rooms.length}개', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (rooms.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('아직 참여한 방이 없습니다.'),
              ),
            ),
          ...rooms.map((room) {
            final active = room.roomId == activeId;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: active ? AppColors.wine : null,
                  foregroundColor: active ? Colors.white : null,
                  child: Icon(active ? Icons.check : Icons.groups),
                ),
                title: Text(room.roomName),
                subtitle: Text('초대코드 ${room.inviteCode} · ${room.displayName}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(room),
              ),
            );
          }),
        ],
      ),
    );
  }
}
