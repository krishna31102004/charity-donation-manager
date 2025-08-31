//
//  FavoritesViewModel.swift
//  CharityDonationManager(CDM)
//
//  Created by Krishna Balaji on 8/26/25.
//


import Foundation
import SwiftData

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var query: String = ""

    func toggleFavorite(_ place: PlaceDTO, context: ModelContext) {
        if let existing = favorite(for: place.id, context: context) {
            context.delete(existing)
        } else {
            let model = FavoritePlace(placeID: place.id, name: place.name, subtitle: place.subtitle, latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            context.insert(model)
        }
        try? context.save()
    }

    func isFavorite(_ placeID: String, context: ModelContext) -> Bool {
        favorite(for: placeID, context: context) != nil
    }

    func favorite(for placeID: String, context: ModelContext) -> FavoritePlace? {
        let d = FetchDescriptor<FavoritePlace>(predicate: #Predicate { $0.placeID == placeID })
        return try? context.fetch(d).first
    }

    func allFavorites(context: ModelContext) -> [FavoritePlace] {
        let d = FetchDescriptor<FavoritePlace>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let items = (try? context.fetch(d)) ?? []
        if query.isEmpty { return items }
        let q = query.lowercased()
        return items.filter { p in
            let a = p.name.lowercased().contains(q)
            let b = (p.subtitle ?? "").lowercased().contains(q)
            return a || b
        }
    }
}
