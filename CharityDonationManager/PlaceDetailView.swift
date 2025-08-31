import SwiftUI
import MapKit
import SwiftData

/// A detailed view for a selected charity. Shows a map, details card, and action buttons.
struct PlaceDetailView: View {
    let place: PlaceDTO
    @Environment(\.modelContext) private var context
    @StateObject private var favVM = FavoritesViewModel()
    @State private var donateSheet = false

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Map hero
                Map(initialPosition: .region(region))
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.primary.opacity(0.06))
                    )
                    .padding(.horizontal)

                // Details card
                VStack(alignment: .leading, spacing: 8) {
                    Text(place.name)
                        .font(.title3.bold())
                    if let s = place.subtitle, !s.isEmpty {
                        Text(s)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if let d = place.distanceMeters {
                        Text(String(format: "%.1f km away", d / 1000))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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

                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        let q = place.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "maps://?q=\(q)&ll=\(place.coordinate.latitude),\(place.coordinate.longitude)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open in Maps", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        favVM.toggleFavorite(place, context: context)
                    } label: {
                        Label(favVM.isFavorite(place.id, context: context) ? "Unfavorite" : "Favorite",
                              systemImage: favVM.isFavorite(place.id, context: context) ? "star.fill" : "star")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        donateSheet = true
                    } label: {
                        Label("Donate", systemImage: "creditcard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $donateSheet) {
            DonationView(defaultCharity: place.name)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}
