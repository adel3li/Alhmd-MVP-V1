/// Post-MVP hook (spec §2.1, §13.2): each blessing's
/// `relatedPodcastEpisode` will link to its «الحمد» podcast episode, played
/// via just_audio. Interface stubbed now so feature code can depend on it;
/// do NOT add the just_audio dependency before the feature is scheduled.
abstract class PodcastAudioService {
  Future<void> playEpisode(String episodeId);
  Future<void> pause();
  Stream<bool> get isPlaying;
}

/// MVP placeholder — podcast playback ships post-MVP (§13).
class UnavailablePodcastAudioService implements PodcastAudioService {
  @override
  Future<void> playEpisode(String episodeId) async {}

  @override
  Future<void> pause() async {}

  @override
  Stream<bool> get isPlaying => const Stream.empty();
}
