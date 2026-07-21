// SettingsView.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The Settings (Preferences) window.  Values are stored in UserDefaults under
/// the same keys the app has always used, so existing preferences carry over.
struct SettingsView: View {
    @AppStorage("israel") private var inIsrael = false
    @AppStorage("julian") private var useJulian = false
    @AppStorage("parsha") private var showParsha = true
    @AppStorage("omer") private var showOmer = true
    @AppStorage("chol") private var showCholHamoed = true

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
                if newValue {
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
            Button("OK") {}
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
