import SwiftUI
import SwiftData

/// A polished history view that lists past donations with search and card styling.
/// It uses a scrollable layout, a header with a count of records, a search bar,
/// and card-style rows showing the charity name, amount, payment method, and date.
struct DonationHistoryView: View {
    /// Fetch donation records sorted by date (most recent first).
    @Query(sort: \DonationRecord.date, order: .reverse) private var records: [DonationRecord]
    /// Search text entered by the user to filter donations.
    @State private var search: String = ""

    /// Returns the records filtered by the search string. Matches on the charity name,
    /// payment method, or formatted amount.
    private var filtered: [DonationRecord] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return records }
        let lower = trimmed.lowercased()
        return records.filter { record in
            // Format amount as a string for matching. Use two decimal places for dollars.
            let amountString = String(format: "%.2f", NSDecimalNumber(decimal: record.amount).doubleValue)
            return record.charityName.lowercased().contains(lower)
                || record.paymentMethod.lowercased().contains(lower)
                || amountString.contains(lower)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    searchBar
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { record in
                                donationCard(record)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    /// Header showing the section title and a badge with the number of filtered records.
    private var header: some View {
        HStack {
            Text("Your donations")
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

    /// A search bar allowing the user to filter donations by name, amount, or method.
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search (name, amount, method)", text: $search)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal)
    }

    /// A card representing a single donation record.
    /// Shows the charity name prominently and secondary details beneath.
    private func donationCard(_ record: DonationRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Charity name
            Text(record.charityName)
                .font(.headline)
            // Secondary details: amount, payment method, and date.
            HStack(spacing: 12) {
                Text(String(format: "$%.2f", NSDecimalNumber(decimal: record.amount).doubleValue))
                Divider()
                Text(record.paymentMethod)
                Divider()
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
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
    }

    /// An empty state displayed when there are no matching donation records.
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No donations recorded")
                .font(.headline)
            Text("Log one from a place detail or the Donate screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }
}
