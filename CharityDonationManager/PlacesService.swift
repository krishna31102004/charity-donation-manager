import Foundation
import GooglePlaces
import CoreLocation

final class PlacesService {
    private let client = GMSPlacesClient.shared()

    func nearby(maxResults: Int = 10, completion: @escaping ([PlaceDTO]) -> Void) {
        let fields: GMSPlaceField = [.name, .formattedAddress, .coordinate, .placeID]
        client.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields) { likelihoods, error in
            guard error == nil, let items = likelihoods else { completion([]); return }
            let results = items.prefix(maxResults).map { l -> PlaceDTO in
                let p = l.place
                return PlaceDTO(
                    id: p.placeID ?? UUID().uuidString,
                    name: p.name ?? "Unknown",
                    subtitle: p.formattedAddress,
                    coordinate: p.coordinate,
                    distanceMeters: nil
                )
            }
            completion(results)
        }
    }

    func search(
        query: String,
        origin: CLLocation?,
        radiusMeters: Double,
        maxResults: Int = 12,
        completion: @escaping ([PlaceDTO]) -> Void
    ) {
        let token = GMSAutocompleteSessionToken()
        let filter = GMSAutocompleteFilter()

        // Use types (string identifiers) to restrict to places/establishments.
        filter.types = ["establishment"]

        // Circular location bias (function has NO argument labels on this SDK).
        if let o = origin {
            filter.locationBias = GMSPlaceCircularLocationOption(o.coordinate, radiusMeters)
        }

        // This SDK expects `callback:` (not `completion:`)
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: token, callback: { predictions, error in
            guard error == nil, let preds = predictions, !preds.isEmpty else { completion([]); return }

            let ids = Array(preds.prefix(maxResults * 2)).compactMap { $0.placeID }
            if ids.isEmpty { completion([]); return }

            var results: [PlaceDTO] = []
            var seen = Set<String>()
            let group = DispatchGroup()
            let fields: GMSPlaceField = [.name, .formattedAddress, .coordinate, .placeID]

            for id in ids {
                group.enter()
                // This SDK also expects `callback:` here.
                self.client.fetchPlace(fromPlaceID: id, placeFields: fields, sessionToken: token, callback: { place, _ in
                    defer { group.leave() }
                    guard let p = place else { return }

                    let pid = p.placeID ?? id
                    if seen.contains(pid) { return }
                    seen.insert(pid)

                    var dist: Double? = nil
                    if let o = origin {
                        let to = CLLocation(latitude: p.coordinate.latitude, longitude: p.coordinate.longitude)
                        dist = o.distance(from: to)
                    }

                    results.append(
                        PlaceDTO(
                            id: pid,
                            name: p.name ?? "Unknown",
                            subtitle: p.formattedAddress,
                            coordinate: p.coordinate,
                            distanceMeters: dist
                        )
                    )
                })
            }

            group.notify(queue: .main) {
                let filtered = results.filter { dto in
                    guard let d = dto.distanceMeters, radiusMeters > 0 else { return true }
                    return d <= radiusMeters
                }
                let sorted = filtered.sorted {
                    ($0.distanceMeters ?? .greatestFiniteMagnitude) < ($1.distanceMeters ?? .greatestFiniteMagnitude)
                }
                completion(Array(sorted.prefix(maxResults)))
            }
        })
    }

    func searchAny(
        queries: [String],
        origin: CLLocation?,
        radiusMeters: Double,
        maxResults: Int = 12,
        completion: @escaping ([PlaceDTO]) -> Void
    ) {
        var aggregate: [PlaceDTO] = []
        var seen = Set<String>()

        func step(_ idx: Int) {
            if idx >= queries.count || aggregate.count >= maxResults {
                completion(Array(aggregate.prefix(maxResults)))
                return
            }
            search(query: queries[idx], origin: origin, radiusMeters: radiusMeters, maxResults: maxResults) { items in
                for x in items where !seen.contains(x.id) {
                    seen.insert(x.id)
                    aggregate.append(x)
                    if aggregate.count >= maxResults { break }
                }
                step(idx + 1)
            }
        }
        step(0)
    }
}
