import SwiftUI
import SwiftData
import MapKit

/// DiscoverView: Displays categories, search controls and a scrollable list of nearby charities.
/// Updated design features a professional look, unified scrolling for the whole screen,
/// and polished cards for results. Categories can be selected via chips; a radius slider
/// controls the search radius. When the "Other" category is chosen, a text field appears
/// for custom keywords.
struct DiscoverView: View {
    @StateObject private var vm = PlacesViewModel()
    @Environment(\.modelContext) private var context
    @StateObject private var favVM = FavoritesViewModel()

    @State private var selectedCategory: CharityCategory = .all
    @State private var otherText: String = ""
    @FocusState private var isOtherFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    controls
                    content
                }
                .padding(.vertical, 12)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { vm.onAppear() }
        }
    }

    /// A friendly header with a title and subtitle on a subtle material background.
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Find charities near you")
                .font(.title.bold())
            Text("Search by category or name. Tap a result to see details or donate.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.06))
        )
        .padding(.horizontal)
    }

    /// Controls section containing category chips, optional text field, and radius slider.
    private var controls: some View {
        VStack(spacing: 12) {
            // Horizontal list of category chips.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CharityCategory.allCases, id: \ .self) { cat in
                        Button {
                            selectedCategory = cat
                            if cat != .other {
                                isOtherFocused = false
                                otherText = ""
                            }
                            // Trigger search whenever the category changes.
                            vm.searchCategory(cat, otherText: otherText)
                        } label: {
                            Text(cat.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(
                                    Capsule()
                                        .fill(cat == selectedCategory ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(cat == selectedCategory ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.15))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }

            // Text field for the "other" category.
            if selectedCategory == .other {
                HStack(spacing: 10) {
                    TextField("Search by name or keyword", text: $otherText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .focused($isOtherFocused)
                        .onSubmit {
                            vm.searchCategory(.other, otherText: otherText)
                        }
                    Button {
                        isOtherFocused = false
                        vm.searchCategory(.other, otherText: otherText)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.12))
                            )
                    }
                }
                .padding(.horizontal)
            }

            // Radius slider with label.
            VStack(spacing: 6) {
                HStack {
                    Text("Radius")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(Int(vm.radiusKm)) km")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Slider(value: $vm.radiusKm, in: 1...50, step: 1) {
                    Text("Radius")
                } minimumValueLabel: {
                    Text("1").font(.caption2)
                } maximumValueLabel: {
                    Text("50").font(.caption2)
                }
                .padding(.horizontal)
                .onChange(of: vm.radiusKm) { _ in
                    vm.searchCategory(selectedCategory, otherText: otherText)
                }
            }
        }
    }

    /// Main content area: shows a loading indicator, empty state, or a list of results.
    private var content: some View {
        Group {
            if vm.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Searching nearby charities…")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            } else if vm.results.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(vm.results) { p in
                        NavigationLink {
                            PlaceDetailView(place: p)
                        } label: {
                            placeCard(p)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    /// Individual card representing a place with icon, name, subtitle, distance and favorite indicator.
    private func placeCard(_ p: PlaceDTO) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.12))
                Image(systemName: "building.2.fill")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text(p.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if let sub = p.subtitle, !sub.isEmpty {
                    Text(sub)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if let d = p.distanceMeters {
                    let km = d / 1000
                    Text(String(format: "%.1f km away", km))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
            Spacer()
            // Show a heart if the place is already in favorites.
            if favVM.isFavorite(p.id, context: context) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.primary.opacity(0.06))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    /// Empty state view when no results are found.
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "mappin.and.ellipse")
                .imageScale(.large)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("No results")
                .font(.headline)
            Text("Try a different category, increase the radius, or enable location.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }
}

// Provide a tertiary label color for compatibility with earlier iOS versions.
private extension ShapeStyle where Self == Color {
    static var tertiaryLabel: Color { Color(UIColor.tertiaryLabel) }
}
