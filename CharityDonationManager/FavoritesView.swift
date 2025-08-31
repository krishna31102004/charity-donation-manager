import SwiftUI
import SwiftData
import CoreLocation
import MapKit

/// A view listing the user's saved places with search and card styling.
struct FavoritesView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm = FavoritesViewModel()
    @State private var search = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    searchBar
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(filtered, id: \ .placeID) { p in
                                NavigationLink {
                                    let dto = PlaceDTO(
                                        id: p.placeID,
                                        name: p.name,
                                        subtitle: p.subtitle,
                                        coordinate: CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude),
                                        distanceMeters: nil
                                    )
                                    PlaceDetailView(place: dto)
                                } label: {
                                    favCard(p)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Favorites")
        }
    }

    private var filtered: [FavoritePlace] {
        let all = vm.allFavorites(context: context)
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.name.lowercased().contains(q) || ($0.subtitle ?? "").lowercased().contains(q) }
    }

    private var header: some View {
        HStack {
            Text("Saved charities")
                .font(.title2.bold())
            Spacer()
            Text("\(filtered.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule().fill(Color.secondary.opacity(0.12))
                )
        }
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search favorites", text: $search)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal)
    }

    private func favCard(_ p: FavoritePlace) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(p.name)
                .font(.headline)
            if let s = p.subtitle, !s.isEmpty {
                Text(s)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.06))
        )
        .contextMenu {
            Button(role: .destructive) {
                context.delete(p)
                try? context.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No favorites yet")
                .font(.headline)
            Text("Tap the star on a place to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}
