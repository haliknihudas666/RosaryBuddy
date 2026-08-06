import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/offline_audio_repository.dart';

@immutable
class OfflineAudioState {
  final bool isDownloading;
  final int downloadedCount;
  final int totalCount;
  final bool isFullyDownloaded;
  final String? errorMessage;

  const OfflineAudioState({
    this.isDownloading = false,
    this.downloadedCount = 0,
    this.totalCount = 0,
    this.isFullyDownloaded = false,
    this.errorMessage,
  });

  OfflineAudioState copyWith({
    bool? isDownloading,
    int? downloadedCount,
    int? totalCount,
    bool? isFullyDownloaded,
    String? errorMessage,
  }) {
    return OfflineAudioState(
      isDownloading: isDownloading ?? this.isDownloading,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      totalCount: totalCount ?? this.totalCount,
      isFullyDownloaded: isFullyDownloaded ?? this.isFullyDownloaded,
      errorMessage: errorMessage,
    );
  }
}

class OfflineAudioNotifier extends Notifier<OfflineAudioState> {
  final OfflineAudioRepository _repo = OfflineAudioRepository();

  @override
  OfflineAudioState build() {
    _checkStatusAndAutoDownload();
    return const OfflineAudioState();
  }

  Future<void> _checkStatusAndAutoDownload() async {
    final manifest = _repo.buildAllPrayerManifest();
    final total = manifest.length;
    int cachedCount = 0;

    for (final item in manifest) {
      final path = await _repo.getCachedFilePath(item.audioKey);
      if (path != null) cachedCount++;
    }

    final fullyDownloaded = cachedCount >= total;
    state = state.copyWith(
      downloadedCount: cachedCount,
      totalCount: total,
      isFullyDownloaded: fullyDownloaded,
    );

    // Auto background download on startup if incomplete
    if (!fullyDownloaded && !state.isDownloading) {
      downloadAllPrayers();
    }
  }

  /// Downloads and caches all static prayer audio files for Tagalog and English.
  Future<void> downloadAllPrayers() async {
    if (state.isDownloading) return;

    final manifest = _repo.buildAllPrayerManifest();
    final total = manifest.length;

    state = state.copyWith(
      isDownloading: true,
      totalCount: total,
      errorMessage: null,
    );

    int count = 0;
    for (final item in manifest) {
      final isCached = await _repo.preCacheAudioItem(item);
      if (isCached) count++;
      state = state.copyWith(downloadedCount: count);
    }

    final isComplete = count >= total;
    state = state.copyWith(
      isDownloading: false,
      downloadedCount: count,
      totalCount: total,
      isFullyDownloaded: isComplete,
    );
  }
}

final offlineAudioProvider =
    NotifierProvider<OfflineAudioNotifier, OfflineAudioState>(
        OfflineAudioNotifier.new);
