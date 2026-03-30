import MiryamCore

@MainActor
enum TestData {
    static let releaseDate = Date(timeIntervalSince1970: 1_609_459_200) // 2021-01-01

    static func makeSong(
        id: Int = 1,
        name: String = "Bohemian Rhapsody",
        artistName: String = "Queen",
        albumName: String = "A Night at the Opera",
        albumId: Int = 100,
        durationInMilliseconds: Int = 354_000,
        genre: String = "Rock",
        trackNumber: Int = 1
    ) -> Song {
        Song(
            id: id,
            name: name,
            artistName: artistName,
            albumName: albumName,
            albumId: albumId,
            artworkURL: nil,
            previewURL: nil,
            durationInMilliseconds: durationInMilliseconds,
            genre: genre,
            trackNumber: trackNumber,
            releaseDate: releaseDate
        )
    }

    static func makeAlbum(
        id: Int = 100,
        name: String = "A Night at the Opera",
        artistName: String = "Queen",
        trackCount: Int = 12,
        genre: String = "Rock"
    ) -> Album {
        Album(
            id: id,
            name: name,
            artistName: artistName,
            artworkURL: nil,
            trackCount: trackCount,
            releaseDate: releaseDate,
            genre: genre
        )
    }

    static let sampleSongs: [Song] = [
        makeSong(id: 1, name: "Bohemian Rhapsody", trackNumber: 1, durationInMilliseconds: 354_000),
        makeSong(id: 2, name: "You're My Best Friend", trackNumber: 2, durationInMilliseconds: 172_000),
        makeSong(id: 3, name: "Love of My Life", trackNumber: 3, durationInMilliseconds: 219_000)
    ]

    private static func makeSong(
        id: Int,
        name: String,
        trackNumber: Int,
        durationInMilliseconds: Int
    ) -> Song {
        makeSong(
            id: id,
            name: name,
            durationInMilliseconds: durationInMilliseconds,
            trackNumber: trackNumber
        )
    }
}
