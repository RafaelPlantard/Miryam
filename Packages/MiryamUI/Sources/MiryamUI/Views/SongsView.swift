import MiryamCore
import MiryamFeatures
import SwiftUI

public struct SongsView: View {
    @Bindable private var viewModel: SongsViewModel
    @Environment(Router.self) private var router
    @Environment(PlayerViewModel.self) private var playerViewModel

    public init(viewModel: SongsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.songsView.rawValue)
        .background(Color._miryamBackground)
        .hideNavigationBarChrome()
        .onChange(of: viewModel.searchQuery) {
            viewModel.search()
        }
        .task {
            await viewModel.loadRecentlyPlayed()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.songs)
                .font(.miryam.display32)
                .foregroundStyle(Color._miryamLabel)
                .padding(.top, Layout.Songs.titleTopPadding)
                .padding(.horizontal, Layout.Songs.titleHorizontalPadding)
                .padding(.bottom, Layout.Songs.titleBottomPadding)

            SongsSearchHeader(query: $viewModel.searchQuery)
                .padding(.horizontal, Layout.Songs.searchHorizontalPadding)
                .padding(.bottom, Layout.Songs.searchBottomPadding)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.error, viewModel.songs.isEmpty {
            errorView(error)
        } else if viewModel.songs.isEmpty, viewModel.searchQuery.isEmpty {
            emptyStateView
        } else if viewModel.songs.isEmpty {
            noResultsView
        } else {
            songsList
        }
    }

    private var songsList: some View {
        ScrollView {
            LazyVStack(spacing: Layout.SongRow.verticalPadding) {
                if !viewModel.recentlyPlayed.isEmpty, viewModel.searchQuery.isEmpty {
                    recentlyPlayedSection
                }

                ForEach(viewModel.songs) { song in
                    SongRow(
                        song: song,
                        isPlaying: song.id == playerViewModel.currentSong?.id && playerViewModel.isPlaying,
                        onTapped: {
                            playerViewModel.setQueue(viewModel.songs)
                            router.navigate(to: .player(song))
                        },
                        onViewAlbum: {
                            // iOS/iPadOS: present the MoreOptions sheet so the
                            // user can see song metadata + pick an action. tvOS/
                            // visionOS hosts have no sheet wiring, so we short-
                            // circuit directly to the album destination there.
                            #if os(iOS)
                                router.presentSheet(.moreOptions(song))
                            #else
                                let album = Album(
                                    id: song.albumId,
                                    name: song.albumName,
                                    artistName: song.artistName,
                                    artworkURL: song.artworkURL,
                                    trackCount: 0,
                                    releaseDate: nil,
                                    genre: ""
                                )
                                router.navigate(to: .album(album))
                            #endif
                        }
                    )
                    .padding(.horizontal, Layout.SongRow.horizontalPadding)
                    .onAppear {
                        if song.id == viewModel.songs.last?.id {
                            viewModel.loadMore()
                        }
                    }

                    if song.id != viewModel.songs.last?.id {
                        Divider()
                            .padding(.leading, Layout.SongRow.separatorLeadingInset)
                    }
                }

                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.top, Layout.Songs.sectionTopPadding)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var recentlyPlayedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.recentlyPlayed)
                .font(.miryam.display)
                .foregroundStyle(Color._miryamLabel)
                .padding(.horizontal, Layout.Songs.sectionHorizontalPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.recentlyPlayed) { song in
                        RecentlyPlayedCard(
                            song: song,
                            isPlaying: song.id == playerViewModel.currentSong?.id && playerViewModel.isPlaying
                        )
                        .onTapGesture {
                            playerViewModel.setQueue(viewModel.recentlyPlayed)
                            router.navigate(to: .player(song))
                        }
                    }
                }
                .padding(.horizontal, Layout.Songs.sectionHorizontalPadding)
            }
        }
        .accessibilityIdentifier(AccessibilityID.recentlyPlayedSection.rawValue)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .tint(Color._miryamAccent)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(symbol: .warningTriangle)
                .font(.miryam.iconMedium)
                .foregroundStyle(Color._miryamLabelSecondary)
            Text(error.userMessage)
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)
                .multilineTextAlignment(.center)
            Button {
                viewModel.search()
            } label: {
                Text(L10n.tryAgain)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color._miryamAccent)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            if !viewModel.recentlyPlayed.isEmpty {
                songsList
            } else {
                Spacer()
                Image(symbol: .musicNoteList)
                    .font(.miryam.iconMedium)
                    .foregroundStyle(Color._miryamLabelSecondary)
                Text(L10n.searchForSongs)
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabelSecondary)
                    .accessibilityIdentifier(AccessibilityID.emptyStateText.rawValue)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(symbol: .magnifyingGlass)
                .font(.miryam.iconMedium)
                .foregroundStyle(Color._miryamLabelSecondary)
            Text(L10n.noResultsFound)
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier(AccessibilityID.noResultsView.rawValue)
    }
}
