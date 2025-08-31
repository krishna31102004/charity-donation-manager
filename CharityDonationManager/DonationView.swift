import SwiftUI
import SwiftData
import Foundation
import Observation

/// Donation screen styled to resemble a native card entry form with
/// signature and details sections. Users can see and edit the charity name
/// and donation amount, enter card details (holder, bank, type, number,
/// CVV, expiry), and confirm a dummy payment. On success, the donation
/// is saved via `DonationViewModel.save(context:)` and appears in history.
struct DonationView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // For @Observable view models, use @State and @Bindable inside the body
    @State private var vm = DonationViewModel()

    /// Optional charity name passed from PlaceDetailView
    let defaultCharity: String?

    // MARK: - Signature section state (Removed Bank field)
    @State private var cardHolderName: String = ""
    @State private var cardType: String = "VISA"
    private let cardTypes = ["VISA", "Discover", "AMEX", "Mastercard"]

    // MARK: - Card details state
    @State private var cardNumberRaw: String = ""
    @State private var formattedCardNumber: String = ""
    @State private var cvcRaw: String = ""
    @State private var formattedCVC: String = ""
    @State private var selectedDate: Date = .now

    // MARK: - Validation & processing
    @State private var hadInvalidChar: Bool = false
    @State private var errorText: String?
    @State private var isProcessing: Bool = false

    @FocusState private var focusedField: Field?
    enum Field { case charity, amount, card, cvc }

    var body: some View {
        @Bindable var vm = vm

        return NavigationStack {
            VStack(spacing: 8) {
                // Donation header with charity name and amount
                donationHeader(vm: vm)

                Form {
                    Section("SIGNATURE") {
                        TextField("Card Holder Name", text: $cardHolderName)
                        Picker("Card Type", selection: $cardType) {
                            ForEach(cardTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                    }

                    Section("DETAILS") {
                        TextField("Card Number", text: $formattedCardNumber)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .card)
                            .onChange(of: formattedCardNumber) { newValue in
                                // Filter digits and flag invalid chars (spaces allowed in display)
                                let digits = newValue.filter { "0123456789".contains($0) }
                                hadInvalidChar = (newValue.replacingOccurrences(of: " ", with: "") != digits)
                                cardNumberRaw = String(digits.prefix(16))
                                formattedCardNumber = formatCardNumber(cardNumberRaw)
                                updateErrorText()
                            }

                        TextField("CVV", text: $formattedCVC)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .cvc)
                            .onChange(of: formattedCVC) { newValue in
                                let digits = newValue.filter { "0123456789".contains($0) }
                                hadInvalidChar = (newValue != digits)
                                cvcRaw = String(digits.prefix(3))
                                formattedCVC = cvcRaw
                                updateErrorText()
                            }

                        HStack {
                            Text("Valid Through")
                            Spacer()
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }

                        if let hint = cardValidationHint() {
                            Text(hint)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    Section("DONATION") {
                        TextField("Charity name", text: $vm.charityName)
                            .focused($focusedField, equals: .charity)
                        TextField("Amount (USD)", text: $vm.amountText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .amount)
                    }
                }

                if let e = errorText {
                    Text(e)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                confirmButton

                Text("This is a dummy payment. Invalid characters cause a decline; on success the donation is saved locally.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .navigationTitle("Donate")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                if let d = defaultCharity, vm.charityName.isEmpty {
                    vm.charityName = d
                }
                vm.method = "Card (Dummy)"
            }
        }
    }

    // MARK: - Donation header
    @ViewBuilder
    private func donationHeader(vm: DonationViewModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(vm.charityName.isEmpty ? "Charity (tap to edit below)" : vm.charityName)
                .font(.title3.bold())
            Text(vm.amountText.isEmpty ? "—" : "$\(vm.amountText)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.primary.opacity(0.06)))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Confirm button
    private var confirmButton: some View {
        Button {
            confirmDummyPayment()
        } label: {
            if isProcessing {
                HStack {
                    ProgressView()
                    Text("Processing…").padding(.leading, 6)
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("Confirm Donation").frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .padding(.vertical, 4)
        .disabled(!isFormValid())
    }

    // MARK: - Validation logic
    private func isFormValid() -> Bool {
        // Charity name must not be empty (after trimming whitespace)
        let trimmedName = vm.charityName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        // Amount must parse to a positive decimal
        guard let amount = Decimal(string: vm.amountText), amount > 0 else { return false }

        // Card number must be exactly 16 digits (no Luhn check for dummy)
        guard cardNumberRaw.count == 16 else { return false }

        // CVV must be exactly 3 digits
        guard cvcRaw.count == 3 else { return false }

        // Expiry month must be between 1 and 12 (DatePicker ensures this)
        let comps = Calendar.current.dateComponents([.month], from: selectedDate)
        guard let month = comps.month, (1...12).contains(month) else { return false }

        return true
    }

    private func cardValidationHint() -> String? {
        if hadInvalidChar { return "Invalid character detected. Only digits are allowed (spaces auto-added in card number)." }
        if !cardNumberRaw.isEmpty && cardNumberRaw.count < 16 { return "Card number must be 16 digits." }
        if !cvcRaw.isEmpty && cvcRaw.count < 3 { return "CVV must be 3 digits." }
        return nil
    }

    private func updateErrorText() {
        errorText = hadInvalidChar ? "Invalid character detected. Please enter digits only." : nil
    }

    // MARK: - Processing and save
    private func confirmDummyPayment() {
        guard isFormValid() else {
            errorText = "Please fix the highlighted fields before confirming."
            return
        }
        errorText = nil
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessing = false
            vm.method = "Card (Dummy)"
            _ = vm.save(context: context)
            dismiss()
        }
    }

    // MARK: - Helpers
    private func formatCardNumber(_ number: String) -> String {
        var formatted = ""
        var count = 0
        for char in number {
            if char.isNumber {
                if count > 0 && count % 4 == 0 {
                    formatted += " "
                }
                formatted += String(char)
                count += 1
            }
        }
        return formatted
    }

    private func luhnIsValid(_ number: String) -> Bool {
        var sum = 0
        let reversed = number.reversed().compactMap { Int(String($0)) }
        for (idx, digit) in reversed.enumerated() {
            if idx % 2 == 1 {
                let doubled = digit * 2
                sum += (doubled > 9) ? (doubled - 9) : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}
