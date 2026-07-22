// SettingsView.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The Settings (Preferences) window.  Values are stored in UserDefaults under
/// the same keys the app has always used, so existing preferences carry over.
struct SettingsView: View {
    @AppStorage(Preferences.Key.inIsrael) private var inIsrael = false
    @AppStorage(Preferences.Key.useJulian) private var useJulian = false
    @AppStorage(Preferences.Key.showParsha) private var showParsha = true
    @AppStorage(Preferences.Key.showOmer) private var showOmer = true
    @AppStorage(Preferences.Key.showCholHamoed) private var showCholHamoed = true

    /// Once the user has read the Julian warning and clicked OK, never show it
    /// again.  (Cancelling leaves it armed for the next attempt.)
    @AppStorage("julianWarningAcknowledged") private var julianWarningAcknowledged = false

    @State private var confirmingJulian = false

    var body: some View {
        Form {
            Picker("Location:", selection: $inIsrael) {
                Text("Diaspora").tag(false)
                Text("Israel").tag(true)
            }
            .pickerStyle(.inline)

            Section("Show:") {
                Toggle("Parsha of the week", isOn: $showParsha)
                Toggle("Day of the Omer", isOn: $showOmer)
                Toggle("Chol Hamoed", isOn: $showCholHamoed)
            }

            Picker("Secular calendar:", selection: $useJulian) {
                Text("Gregorian").tag(false)
                Text("Julian").tag(true)
            }
            .pickerStyle(.inline)
            .onChange(of: useJulian) { _, newValue in
                if newValue, !julianWarningAcknowledged {
                    confirmingJulian = true
                }
            }
        }
        .formStyle(.grouped)
        #if os(macOS)
            .frame(width: 380)
        #endif
        .alert("Are you sure?", isPresented: $confirmingJulian) {
            Button("Cancel", role: .cancel) {
                useJulian = false
            }
            Button("OK") {
                julianWarningAcknowledged = true
            }
        } message: {
            Text(julianWarning)
        }
    }

    private var julianWarning: String {
        let today = SecularCalendar.julian.today()
        let monthNames = DateFormatter().standaloneMonthSymbols!
        let date = "\(today.day) \(monthNames[today.month - 1]), \(today.year)"
        return """
        Please don't use this option unless you understand the difference between \
        the Gregorian and the Julian calendar.

        Most of Europe switched from the Julian to the Gregorian calendar in 1582, \
        Great Britain (including its American colonies) switched in 1752, \
        and Turkey in 1926.

        Today's date in the Julian calendar is \(date).  If you are confused, please hit 'Cancel'.
        """
    }
}

#Preview {
    SettingsView()
}
