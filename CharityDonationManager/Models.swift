import Foundation
import SwiftData
import CoreLocation

@Model
final class FavoritePlace {
    @Attribute(.unique) var placeID: String
    var name: String
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    var createdAt: Date
    init(placeID: String, name: String, subtitle: String?, latitude: Double, longitude: Double, createdAt: Date = .init()) {
        self.placeID = placeID
        self.name = name
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
}

@Model
final class DonationRecord {
    var id: UUID
    var charityName: String
    var amount: Decimal
    var paymentMethod: String
    var date: Date
    init(id: UUID = UUID(), charityName: String, amount: Decimal, paymentMethod: String, date: Date = .init()) {
        self.id = id
        self.charityName = charityName
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.date = date
    }
}

@Model
final class Profile {
    var id: UUID
    var name: String
    var email: String
    init(id: UUID = UUID(), name: String = "", email: String = "") {
        self.id = id
        self.name = name
        self.email = email
    }
}

@Model
final class AppUser {
    @Attribute(.unique) var email: String
    var name: String
    var passwordHash: String
    init(email: String, name: String, passwordHash: String) {
        self.email = email
        self.name = name
        self.passwordHash = passwordHash
    }
}

struct PlaceDTO: Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var distanceMeters: Double?

    static func == (lhs: PlaceDTO, rhs: PlaceDTO) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
