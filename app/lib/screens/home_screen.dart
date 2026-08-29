import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/bible_meta.dart';
import '../services/bible_service.dart';
import '../services/room_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'rooms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.storage,
    required this.bibleService,
    required this.roomService,
  });

  final StorageService storage;
  final BibleService bibleService;
  final RoomService roomService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<bool> progress = List<bool>.filled(BibleMeta.totalChapters, false);
  int book = 0;
  int chapter = 1;
  double textSize = 18;
  String chapterText = '본문을 불러오는 중입니다…';
  int roomCount = 0;
  String? activeRoomName;
  int cachedBooks = 0;
  bool loadingText = false;

  int get readCount => progress.where((e) => e).length;
  bool get isCurrentRead => progress[BibleMeta.chapterIndex(book, chapter)];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    progress = await widget.storage.loadProgress();
    book = (await widget.storage.loadLastBook()).clamp(0, 65).toInt();
    chapter = (await widget.storage.loadLastChapter()).clamp(1, BibleMeta.chapterCounts[book]).toInt();
    textSize = await widget.storage.loadTextSize();
    cachedBooks = await widget.bibleService.cachedBookCount();
    await _reloadRoomSummary();
    if (mounted) setState(() {});
    await _loadChapter();
  }

  Future<void> _reloadRoomSummary() async {
    final rooms = await widget.storage.loadRooms();
    final active = await widget.storage.activeRoom();
    roomCount = rooms.length;
    activeRoomName = active?.roomName;
    if (mounted) setState(() {});
  }

  Future<void> _loadChapter() async {
    setState(() {
      loadingText = true;
      chapterText = '본문을 불러오는 중입니다…';
    });
    await widget.storage.saveLastPosition(book, chapter);
    try {
      final text = await widget.bibleService.chapterText(book, chapter);
      if (!mounted) return;
      setState(() {
        chapterText = text;
        loadingText = false;
      });
      cachedBooks = await widget.bibleService.cachedBookCount();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        chapterText = '본문을 불러오지 못했습니다.\n인터넷 연결을 확인해 주세요.\n\n$e';
        loadingText = false;
      });
    }
  }

  Future<void> _toggleRead() async {
    final index = BibleMeta.chapterIndex(book, chapter);
    setState(() => progress[index] = !progress[index]);
    await widget.storage.saveProgress(progress);
    await widget.storage.saveLastPosition(book, chapter);
    widget.roomService.syncAllRooms(progress, book, chapter);
  }

  Future<void> _rooms() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomsScreen(
          storage: widget.storage,
          roomService: widget.roomService,
        ),
      ),
    );
    await _reloadRoomSummary();
  }

  Future<void> _changeTextSize(double delta) async {
    setState(() => textSize = (textSize + delta).clamp(15.0, 25.0).toDouble());
    await widget.storage.saveTextSize(textSize);
  }

  Future<void> _downloadAll() async {
    var done = 0;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('66권 전체 저장'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: done / 66),
              const SizedBox(height: 12),
              Text('$done / 66권'),
            ],
          ),
        ),
      ),
    );

    try {
      await widget.bibleService.downloadAll(onProgress: (value, total) {
        done = value;
        if (mounted) setState(() => cachedBooks = value);
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('전체 저장 중 오류: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = readCount / BibleMeta.totalChapters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('함께읽는성경'),
        actions: [
          IconButton(
            tooltip: '내 방',
            onPressed: _rooms,
            icon: const Icon(Icons.groups),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'chapter') {
                Share.share('📖 ${BibleMeta.bookNames[book]} $chapter장 · 개역한글판\n\n$chapterText');
              } else if (value == 'progress') {
                Share.share(
                  '📖 함께읽는성경 읽기 진행\n'
                  '읽은 장: $readCount / ${BibleMeta.totalChapters}\n'
                  '진행률: ${(pct * 100).toStringAsFixed(1)}%\n'
                  '최근 위치: ${BibleMeta.bookNames[book]} $chapter장',
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'chapter', child: Text('현재 장 말씀 공유')),
              PopupMenuItem(value: 'progress', child: Text('내 읽기 진행 공유')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.wine,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '성경전서 개역한글판',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '읽은 장 $readCount / ${BibleMeta.totalChapters} · ${(pct * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups, color: AppColors.wine),
              title: Text(roomCount == 0 ? '함께 읽는 방' : '내 방 $roomCount개'),
              subtitle: Text(
                roomCount == 0
                    ? '가족·교회·친구와 읽기 진도와 기도제목을 나눠보세요.'
                    : '현재 ${activeRoomName ?? '방'} · 내 진도는 모든 가입 방에 자동 반영됩니다.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _rooms,
            ),
          ),
          if (kIsWeb)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  '🍎 iPhone 설치: Safari에서 공유 버튼 → 「홈 화면에 추가」를 누르면 앱처럼 사용할 수 있습니다.',
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: book,
                  decoration: const InputDecoration(labelText: '성경'),
                  items: List.generate(
                    BibleMeta.bookNames.length,
                    (i) => DropdownMenuItem(value: i, child: Text(BibleMeta.bookNames[i])),
                  ),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      book = value;
                      chapter = 1;
                    });
                    await _loadChapter();
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 105,
                child: DropdownButtonFormField<int>(
                  value: chapter,
                  decoration: const InputDecoration(labelText: '장'),
                  items: List.generate(
                    BibleMeta.chapterCounts[book],
                    (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}장')),
                  ),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() => chapter = value);
                    await _loadChapter();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton(onPressed: () => _changeTextSize(-1), child: const Text('A−')),
              const SizedBox(width: 6),
              OutlinedButton(onPressed: () => _changeTextSize(1), child: const Text('A+')),
              const Spacer(),
              if (!kIsWeb)
                TextButton.icon(
                  onPressed: _downloadAll,
                  icon: const Icon(Icons.download),
                  label: Text('오프라인 $cachedBooks/66'),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'PWA · 최근 본문 캐시',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${BibleMeta.bookNames[book]} $chapter장',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.wineDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: loadingText
                  ? const Center(child: CircularProgressIndicator())
                  : SelectableText(
                      chapterText,
                      style: TextStyle(fontSize: textSize, height: 1.72),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: isCurrentRead ? AppColors.readGreen : AppColors.wine,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: _toggleRead,
            icon: const Icon(Icons.check),
            label: Text(isCurrentRead ? '읽음 완료' : '이 장 읽음'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
