import SwiftUI
import MiryamCore
import MiryamFeatures

public struct SongsView: View {
    @Bindable private var viewModel: SongsViewModel
    @Environment(Router.self) private var router

    public init(viewModel: SongsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error, viewModel.songs.isEmpty {
                    errorView(error)
                } else if viewModel.songs.isEmpty && viewModel.searchQuery.isEmpty {
                    emptyStateView
                } else if viewModel.songs.isEmpty {
                    noResultsView
                } else {
                    songsList
                }
            }
            .background(Color._miryamBackground)
            .navigationTitle("Songs")
            .searchable(text: $viewModel.searchQuery, prompt: "Search songs...")
            .onChange(of: viewModel.searchQuery) {
                viewModel.search()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .player(let song):
                    Text("Player: \(song.name)")
                case .album(let album):
                    Text("Album: \(album.name)")
                }
            }
            .sheet(item: $router.presentedSheet) { sheet in
                switch sheet {
                case .moreOptions(let song):
                    Text("Options: \(song.name)")
                }
            }
        }
        .task {
            await viewModel.loadRecentlyPlayed()
        }
    }

    // MARK: - Subviews

    private var songsList: some View {
        List {
            if !viewModel.recentlyPlayed.isEmpty && viewModel.searchQuery.isEmpty {
                recentlyPlayedSection
            }

            ForEach(viewModel.songs) { song in
                SongRow(song: song)
                    .onTapGesture {
                        router.navigate(to: .player(song))
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            router.presentSheet(.moreOptions(song))
                        } label: {
                            Label("More", systemImage: "ellipsis.circle")
                        }
                        .tint(Color._miryamAccent)
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
                .listRowSeparator(.hidden)
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
            .listRowSeparator(.hidden)
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
