import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/bible_meta.dart';
import '../models/room_entry.dart';
import '../services/room_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({
    super.key,
    required this.room,
    required this.storage,
    required this.roomService,
  });

  final RoomEntry room;
  final StorageService storage;
  final RoomService roomService;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  Map<String, dynamic>? state;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      final progress = await widget.storage.loadProgress();
      final book = await widget.storage.loadLastBook();
      final chapter = await widget.storage.loadLastChapter();
      await widget.roomService.syncProgress(widget.room, progress, book, chapter);
      final data = await widget.roomService.getRoom(widget.room);
      if (!mounted) return;
      setState(() {
        state = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      final raw = e.toString();
      final message = raw.contains('Failed host lookup') ||
              raw.contains('SocketException') ||
              raw.contains('ClientException')
          ? '인터넷 연결을 확인해 주세요. 계속되면 최신 앱으로 업데이트해 주세요.'
          : '방 불러오기 실패: $raw';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _addPrayer() async {
    final controller = TextEditingController();
    final body = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기도제목 등록'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 1000,
          decoration: const InputDecoration(
            hintText: '함께 기도할 내용을 적어주세요.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('등록'),
          ),
        ],
      ),
    );
    if (body == null || body.isEmpty) return;
    try {
      await widget.roomService.addPrayer(widget.room, body);
      await _refresh();
    } catch (e) {
      _error(e);
    }
  }

  Future<void> _togglePrayer(Map<String, dynamic> prayer) async {
    try {
      await widget.roomService.setPrayerAnswered(
        widget.room,
        '${prayer['id']}',
        !(prayer['is_answered'] == true),
      );
      await _refresh();
    } catch (e) {
      _error(e);
    }
  }

  Future<void> _deletePrayer(Map<String, dynamic> prayer) async {
    try {
      await widget.roomService.deletePrayer(widget.room, '${prayer['id']}');
      await _refresh();
    } catch (e) {
      _error(e);
    }
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
    final roomState = state?['room'] as Map<String, dynamic>?;
    final members = (state?['members'] as List<dynamic>? ?? []);
    final prayers = (state?['prayers'] as List<dynamic>? ?? []);
    final myMemberId = '${state?['me_member_id'] ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(roomState?['name']?.toString() ?? widget.room.roomName),
        actions: [
          IconButton(
            tooltip: '초대',
            onPressed: () {
              Share.share(
                '📖 함께읽는성경 방에 초대합니다.\n'
                '방: ${widget.room.roomName}\n'
                '초대코드: ${widget.room.inviteCode}\n\n'
                '앱에서 「초대코드 참여」를 눌러 입력해 주세요.',
              );
            },
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPrayer,
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('기도제목'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        '초대코드 ${roomState?['invite_code'] ?? widget.room.inviteCode}\n'
                        '이 방의 멤버별 말씀 읽기 진도와 기도제목을 함께 봅니다.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('📖 함께 읽기 진도', style: Theme.of(context).textTheme.titleLarge),
                  const Text('멤버별 읽은 장 수·진행률·최근 읽은 위치가 각각 표시됩니다.'),
                  const SizedBox(height: 8),
                  ...members.map((raw) {
                    final m = (raw as Map).cast<String, dynamic>();
                    final read = (m['read_count'] as num?)?.toInt() ?? 0;
                    final percent = read / BibleMeta.totalChapters;
                    final book = ((m['last_book'] as num?)?.toInt() ?? 0).clamp(0, 65).toInt();
                    final chapter = (m['last_chapter'] as num?)?.toInt() ?? 1;
                    final owner = '${m['role']}' == 'owner';
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${m['name'] ?? '이름 없음'}${owner ? ' · 방장' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '읽기 $read / ${BibleMeta.totalChapters}장 · '
                              '${(percent * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: AppColors.wineDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            LinearProgressIndicator(value: percent.clamp(0.0, 1.0).toDouble()),
                            const SizedBox(height: 7),
                            Text('최근 위치 · ${BibleMeta.bookNames[book]} $chapter장'),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text('🙏 방 기도제목', style: Theme.of(context).textTheme.titleLarge),
                  const Text('각 멤버가 여러 기도제목을 올릴 수 있고 같은 방 사람 모두가 함께 봅니다.'),
                  const SizedBox(height: 8),
                  if (prayers.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('아직 등록된 기도제목이 없습니다.'),
                      ),
                    ),
                  ...prayers.map((raw) {
                    final prayer = (raw as Map).cast<String, dynamic>();
                    final mine = '${prayer['author_member_id']}' == myMemberId;
                    final answered = prayer['is_answered'] == true;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${prayer['author_name'] ?? '이름 없음'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (answered)
                                  const Chip(
                                    avatar: Icon(Icons.check, size: 16),
                                    label: Text('응답됨'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${prayer['body'] ?? ''}'),
                            if (mine) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _togglePrayer(prayer),
                                    child: Text(answered ? '기도중으로' : '응답됨 ✓'),
                                  ),
                                  TextButton(
                                    onPressed: () => _deletePrayer(prayer),
                                    child: const Text('삭제'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 90),
                ],
              ),
            ),
    );
  }
}
