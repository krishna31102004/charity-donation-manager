import Foundation
import CoreLocation

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var radiusKm: Double = 2
    @Published var results: [PlaceDTO] = []
    @Published var isLoading = false

    private let service = PlacesService()
    private let locationManager = LocationManager()

    private var hasLocation: Bool { locationManager.location != nil }

    func onAppear() {
        if locationManager.authorization == .notDetermined { locationManager.request() }
        searchCategory(.all, otherText: nil)
    }

    func search() {
        perform(queries: [searchText])
    }

    func searchCategory(_ category: CharityCategory, otherText: String?) {
        let qs: [String]
        switch category {
        case .all:
            qs = ["charity near me", "nonprofit near me", "foundation near me", "donation center near me"]
        case .food:
            qs = ["food bank near me", "food pantry near me", "soup kitchen near me"]
        case .health:
            qs = ["health charity near me", "hospital foundation near me", "blood donation near me"]
        case .education:
            qs = ["education charity near me", "scholarship foundation near me", "tutoring nonprofit near me"]
        case .other:
            let t = (otherText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { results = []; return }
            qs = [t, "\(t) near me"]
        }
        perform(queries: qs)
    }

    private func perform(queries: [String]) {
        let meters = radiusKm * 1000
        isLoading = true
        service.searchAny(queries: queries, origin: locationManager.location, radiusMeters: meters, maxResults: 20) { [weak self] items in
            self?.results = items
            self?.isLoading = false
        }
    }
}
