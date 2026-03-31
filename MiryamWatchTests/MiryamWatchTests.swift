import Foundation
import MiryamCore
import Testing
import WatchConnectivity
@testable import MiryamWatch

@MainActor
@Suite("Watch App Smoke")
struct MiryamWatchTests {
    private func makeSong() -> Song {
        Song(
            id: 1,
            name: "Watch Song",
            artistName: "Artist",
            albumName: "Album",
            albumId: 10,
            artworkURL: URL(string: "https://example.com/100x100.jpg"),
            previewURL: URL(string: "https://example.com/preview.m4a"),
            durationInMilliseconds: 30_000,
            genre: "Pop",
            trackNumber: 1,
            releaseDate: nil
        )
    }

    private func makeAlbum() -> Album {
        Album(
            id: 10,
            name: "Watch Album",
            artistName: "Artist",
            artworkURL: URL(string: "https://example.com/100x100.jpg"),
            trackCount: 3,
            releaseDate: nil,
            genre: "Pop"
        )
    }

    @Test("Watch app body can be evaluated")
    func watchAppBodySmoke() {
        let app = MiryamWatchApp()
        _ = app.body
    }

    @Test("Watch dependency container creates expected graph")
    func watchDependencyContainerSmoke() {
        let container = WatchDependencyContainer()

        #expect(container.playerViewModel.currentSong == nil)
        _ = container.sessionDelegate
        _ = container.makeAlbumViewModel(album: makeAlbum())
    }

    @Test("Remote player accepts playback context")
    func remotePlayerApplicationContext() async throws {
        let player = RemotePlayer()
        var iterator = player.stateStream.makeAsyncIterator()
        let state = PlaybackState(
            status: .playing,
            currentSong: makeSong(),
            currentTime: 5,
            duration: 30,
            progress: 5.0 / 30.0
        )
        let data = try JSONEncoder().encode(PlaybackStateMessage(from: state))

        await player.handleApplicationContext(["playbackState": data])

        let received = await iterator.next()
        #expect(received?.currentSong?.id == state.currentSong?.id)
        #expect(received?.status == .playing)
    }

    @Test("Watch session delegate forwards received context")
    func watchSessionDelegateForwardsState() async throws {
        let player = RemotePlayer()
        let delegate = WatchSessionDelegate(remotePlayer: player)
        var iterator = player.stateStream.makeAsyncIterator()
        let state = PlaybackState(
            status: .paused,
            currentSong: makeSong(),
            currentTime: 0,
            duration: 30,
            progress: 0
        )
        let data = try JSONEncoder().encode(PlaybackStateMessage(from: state))

        delegate.session(WCSession.default, didReceiveApplicationContext: ["playbackState": data])

        let received = await iterator.next()
        #expect(received?.status == .paused)
        #expect(received?.currentSong?.id == state.currentSong?.id)
    }
}
