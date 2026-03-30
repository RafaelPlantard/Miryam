import MiryamCore
import MiryamFeatures
import SwiftUI

public struct SongsView: View {
    @Bindable private var viewModel: SongsViewModel
    @Environment(Router.self) private var router

    public init(viewModel: SongsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
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
        .background(Color._miryamBackground)
        .navigationTitle("Songs")
        .searchable(text: $viewModel.searchQuery, prompt: "Search")
        .onChange(of: viewModel.searchQuery) {
            viewModel.search()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadRecentlyPlayed()
        }
    }

    // MARK: - Subviews

    private var songsList: some View {
        List {
            if !viewModel.recentlyPlayed.isEmpty, viewModel.searchQuery.isEmpty {
                recentlyPlayedSection
            }

            ForEach(viewModel.songs) { song in
                SongRow(song: song) {
                    router.presentSheet(.moreOptions(song))
                }
                .onTapGesture {
                    router.navigate(to: .player(song))
                }
                .onAppear {
                    if song.id == viewModel.songs.last?.id {
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
                #if !os(watchOS)
                .listRowSeparator(.hidden)
                #endif
            }
        }
        .listStyle(.plain)
    }

    private var recentlyPlayedSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.recentlyPlayed) { song in
                        RecentlyPlayedCard(song: song)
                            .onTapGesture {
                                router.navigate(to: .player(song))
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .listRowInsets(EdgeInsets())
            #if !os(watchOS)
                .listRowSeparator(.hidden)
            #endif
        } header: {
            Text("Recently Played")
                .font(.miryam.display)
                .foregroundStyle(Color._miryamLabel)
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .tint(Color._miryamAccent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Color._miryamLabelSecondary)
            Text(error.userMessage)
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                viewModel.search()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color._miryamAccent)
            Spacer()
        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            if !viewModel.recentlyPlayed.isEmpty {
                recentlyPlayedList
            } else {
                Spacer()
                Image(systemName: "music.note.list")
                    .font(.system(size: 48))
                    .foregroundStyle(Color._miryamLabelSecondary)
                Text("Search for songs")
                    .font(.miryam.bodyLarge)
                    .foregroundStyle(Color._miryamLabelSecondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var recentlyPlayedList: some View {
        List {
            recentlyPlayedSection
        }
        .listStyle(.plain)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Color._miryamLabelSecondary)
            Text("No results found")
                .font(.miryam.bodyLarge)
                .foregroundStyle(Color._miryamLabelSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
