import Foundation
import SwiftData
import Observation

/// View model for handling donation form fields and saving donations.
///
/// This class exposes observable properties for the charity name and amount text,
/// as well as a payment method string (defaulting to a dummy card). It provides
/// a single `save(context:)` method which persists a `DonationRecord` into
/// SwiftData, resetting its fields upon success. The `methods` static array
/// allows the UI to display available payment options (only the dummy card by default).
@Observable
final class DonationViewModel {
    // MARK: - Public properties
    /// The name of the charity entered by the user.
    var charityName: String = ""
    /// The donation amount as text. Must be a valid decimal number.
    var amountText: String = ""
    /// The payment method used for this donation. For dummy payments, this
    /// defaults to "Card (Dummy)". In a real integration, this might be
    /// replaced by values like "Credit Card" or "Apple Pay".
    var method: String = "Card (Dummy)"

    /// A list of available payment methods. The UI can use this to populate
    /// pickers or menus. Currently only a dummy method is provided.
    static let methods: [String] = ["Card (Dummy)"]

    // MARK: - Saving logic
    /// Persist a donation record into the provided model context.
    ///
    /// The method attempts to parse the amount text into a `Decimal`. If parsing
    /// fails or the amount is not greater than zero, the record is not saved
    /// and the method returns `false`. Upon success, it inserts a new
    /// `DonationRecord` with the trimmed charity name, the parsed amount,
    /// the chosen payment method, and the current date. The context is
    /// saved and the view model is reset.
    ///
    /// - Parameter context: The SwiftData `ModelContext` used to insert and save
    ///   the donation record.
    /// - Returns: `true` if the record was successfully saved and the view model
    ///   reset; `false` otherwise.
    @discardableResult
    func save(context: ModelContext) -> Bool {
        guard let amount = Decimal(string: amountText), amount > 0 else { return false }
        let record = DonationRecord(
            charityName: charityName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            amount: amount,
            paymentMethod: method,
            date: Date()
        )
        context.insert(record)
        do {
            try context.save()
            reset()
            return true
        } catch {
            return false
        }
    }

    /// Reset the view model's fields to their default values. This is invoked
    /// after a successful save to prepare the form for a new donation.
    func reset() {
        charityName = ""
        amountText = ""
        method = "Card (Dummy)"
    }
}
