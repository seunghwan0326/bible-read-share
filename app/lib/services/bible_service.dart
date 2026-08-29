import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bible_meta.dart';

class BibleService {
  static const _cachePrefix = 'bible_book_cache_v12_';

  String _cacheKey(int book) => '$_cachePrefix${BibleMeta.fileNames[book]}';

  Future<String?> _readCache(int book) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey(book));
    if (cached == null || cached.isEmpty) return null;
    try {
      jsonDecode(cached);
      return cached;
    } catch (_) {
      await prefs.remove(_cacheKey(book));
      return null;
    }
  }

  Future<void> _writeCache(int book, String body) async {
    // Browser localStorage is much smaller than Android app storage.
    // Keep only the currently requested book in PWA mode so Safari storage
    // is not exhausted by all 66 books.
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final keys = prefs.getKeys()
          .where((key) => key.startsWith(_cachePrefix) && key != _cacheKey(book))
          .toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    }

    try {
      await prefs.setString(_cacheKey(book), body);
    } catch (_) {
      // Cache failure must never block online Bible reading.
    }
  }

  Future<String> _loadBook(int book) async {
    final cached = await _readCache(book);
    if (cached != null) return cached;

    final uri = Uri.parse(
      '${BibleMeta.dataBase}${BibleMeta.fileNames[book]}.json',
    );
    final response = await http.get(
      uri,
      headers: const {'User-Agent': 'BibleReadShare/Flutter-1.2'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('성경 본문 다운로드 실패 HTTP ${response.statusCode}');
    }

    jsonDecode(response.body);
    await _writeCache(book, response.body);
    return response.body;
  }

  Future<String> chapterText(int book, int chapter) async {
    final raw = await _loadBook(book);
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final chapters = root['chapters'] as List<dynamic>;
    final chapterObj = chapters[chapter - 1] as Map<String, dynamic>;
    final verses = chapterObj['verses'] as List<dynamic>;

    return verses.map((item) {
      final verse = item as Map<String, dynamic>;
      return '${verse['verse']}  ${verse['text']}';
    }).join('\n\n');
  }

  Future<int> cachedBookCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((key) => key.startsWith(_cachePrefix))
        .length;
  }

  bool get supportsFullOfflineDownload => !kIsWeb;

  Future<void> downloadAll({
    void Function(int done, int total)? onProgress,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'iPhone/PWA에서는 저장공간 제한 때문에 66권 전체 오프라인 저장을 사용하지 않습니다.',
      );
    }

    for (var i = 0; i < BibleMeta.fileNames.length; i++) {
      await _loadBook(i);
      onProgress?.call(i + 1, BibleMeta.fileNames.length);
    }
  }
}
