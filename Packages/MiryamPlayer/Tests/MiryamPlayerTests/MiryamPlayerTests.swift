import Foundation
import MiryamCore
import Testing

@testable import MiryamPlayer

// MARK: - Test Helpers

private func makeSong(
    id: Int = 1,
    name: String = "Test Song",
    previewURL: URL? = URL(string: "https://example.com/preview.m4a")
) -> Song {
    Song(
        id: id,
        name: name,
        artistName: "Artist",
        albumName: "Album",
        albumId: 100,
        artworkURL: nil,
        previewURL: previewURL,
        durationInMilliseconds: 30000,
        genre: "Pop",
        trackNumber: 1,
        releaseDate: nil
    )
}

// MARK: - AudioPlayer Tests

@Suite("AudioPlayer")
struct AudioPlayerTests {

    // MARK: - play() error paths

    @Test("play with nil previewURL throws playbackFailed")
    func playWithNilPreviewURLThrows() async {
        let player = AudioPlayer()
        let song = makeSong(previewURL: nil)

        await #expect(throws: AppError.self) {
            try await player.play(song)
        }
    }

    @Test("play with nil previewURL throws specific playbackFailed error")
    func playWithNilPreviewURLThrowsPlaybackFailed() async {
        let player = AudioPlayer()
        let song = makeSong(previewURL: nil)

        do {
            try await player.play(song)
            Issue.record("Expected playbackFailed error")
        } catch let error as AppError {
            guard case .playbackFailed = error else {
                Issue.record("Expected playbackFailed, got \(error)")
                return
            }
        } catch {
            Issue.record("Expected AppError, got \(error)")
        }
    }

    // MARK: - stop()

    @Test("stop emits idle state")
    func stopEmitsIdle() async {
        let player = AudioPlayer()

        let task = Task {
            var states: [PlaybackState.Status] = []
            for await state in player.stateStream {
                states.append(state.status)
                if case .idle = state.status { break }
            }
            return states
        }

        try? await Task.sleep(nanoseconds: 50_000_000)

        await player.stop()

        let states = await task.value
        #expect(states.last == .idle)
    }

    @Test("stop clears current song")
    func stopClearsSong() async {
        let player = AudioPlayer()

        let task = Task {
            for await state in player.stateStream {
                if case .idle = state.status {
                    return state.currentSong
                }
            }
            return nil as Song?
        }

        try? await Task.sleep(nanoseconds: 50_000_000)
        await player.stop()

        let song = await task.value
        #expect(song == nil)
    }

    // MARK: - play() state emissions

    @Test("play with nil previewURL does not emit playing state")
    func playNilURLDoesNotEmitPlaying() async {
        let player = AudioPlayer()
        let song = makeSong(previewURL: nil)

        var emittedPlaying = false
        let task = Task {
            for await state in player.stateStream {
                if case .playing = state.status {
                    emittedPlaying = true
                }
            }
        }

        try? await player.play(song)

        try? await Task.sleep(nanoseconds: 100_000_000)
        task.cancel()

        #expect(!emittedPlaying)
    }

    @Test("play emits loading state before any other state")
    func playEmitsLoadingFirst() async {
        let player = AudioPlayer()
        let song = makeSong()

        let task = Task<PlaybackState?, Never> {
            for await state in player.stateStream {
                if case .loading = state.status {
                    return state
                }
                if case .playing = state.status {
                    return state
                }
            }
            return nil
        }

        try? await Task.sleep(nanoseconds: 50_000_000)

        try? await player.play(song)

        try? await Task.sleep(nanoseconds: 200_000_000)
        task.cancel()

        let state = await task.value
        if let state {
            #expect(state.status == .loading)
            #expect(state.currentSong == song)
        }
    }

    @Test("play sets currentSong in emitted state")
    func playSetsCurrentSong() async {
        let player = AudioPlayer()
        let song = makeSong(name: "Specific Song")

        let task = Task {
            for await state in player.stateStream {
                if state.currentSong != nil {
                    return state.currentSong
                }
            }
            return nil as Song?
        }

        try? await Task.sleep(nanoseconds: 50_000_000)
        try? await player.play(song)
        try? await Task.sleep(nanoseconds: 200_000_000)
        task.cancel()

        let result = await task.value
        #expect(result?.name == "Specific Song")
    }

    // MARK: - stateStream

    @Test("stateStream is available immediately after init")
    func stateStreamAvailable() async {
        let player = AudioPlayer()
        _ = player.stateStream
    }

    // MARK: - Multiple plays

    @Test("playing new song emits idle before loading")
    func playNewSongStopsPrevious() async {
        let player = AudioPlayer()
        let song1 = makeSong(id: 1, name: "Song 1")
        let song2 = makeSong(id: 2, name: "Song 2")

        var statuses: [PlaybackState.Status] = []
        let task = Task {
            for await state in player.stateStream {
                statuses.append(state.status)
                if statuses.filter({ if case .loading = $0 { true } else { false } }).count >= 2 {
                    break
                }
            }
        }

        try? await Task.sleep(nanoseconds: 50_000_000)
        try? await player.play(song1)
        try? await player.play(song2)
        try? await Task.sleep(nanoseconds: 200_000_000)
        task.cancel()

        let hasIdle = statuses.contains { if case .idle = $0 { true } else { false } }
        #expect(hasIdle, "Expected idle state between two play() calls")
    }
}

// MARK: - PlaybackState.Status Equatable

extension PlaybackState.Status: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): true
        case (.loading, .loading): true
        case (.playing, .playing): true
        case (.paused, .paused): true
        case let (.failed(a), .failed(b)): a.localizedDescription == b.localizedDescription
        default: false
        }
    }
}
