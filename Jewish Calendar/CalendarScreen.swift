// CalendarScreen.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The main screen: navigation controls above, the month display below.
/// Wide screens (Mac, iPad, iPhone landscape) get the full grid with holidays
/// in the cells; compact screens get the dot grid with a detail card.
struct CalendarScreen: View {
    @Environment(CalendarViewModel.self) private var model

    // Watching the preferences here refreshes the calendar the moment they are
    // changed in the Settings window.  The defaults match Preferences.
    @AppStorage(Preferences.Key.useJulian) private var useJulian = false
    @AppStorage(Preferences.Key.inIsrael) private var inIsrael = false
    @AppStorage(Preferences.Key.showParsha) private var showParsha = true
    @AppStorage(Preferences.Key.showOmer) private var showOmer = true
    @AppStorage(Preferences.Key.showCholHamoed) private var showCholHamoed = true

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        @State private var showingSettings = false
        @FocusState private var yearFieldIsFocused: Bool
        private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
        private var isCompact: Bool { false }
    #endif

    private static let monthNames = DateFormatter().standaloneMonthSymbols!

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 12) {
            HStack {
                if !isCompact {
                    Button {
                        model.addMonths(-12)
                    } label: {
                        Image(systemName: "chevron.backward.2")
                    }
                    .disabled(!model.canShowEarlierYear)
                    .help("Previous year (↓)")

                    Button {
                        model.addMonths(-1)
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!model.canShowEarlierMonth)
                    .help("Previous month (←)")
                }

                Picker("Month", selection: $model.month) {
                    ForEach(1...12, id: \.self) { month in
                        Text(Self.monthNames[month - 1]).tag(month)
                    }
                }
                .labelsHidden()
                .fixedSize()

                TextField("Year", value: $model.year, format: .number.grouping(.never))
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(width: 64)
                    #if os(iOS)
                        // The number pad has no return key, so give the
                        // keyboard a Done button to commit and dismiss.
                        .keyboardType(.numberPad)
                        .focused($yearFieldIsFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    yearFieldIsFocused = false
                                }
                            }
                        }
                    #endif

                if !isCompact {
                    Button {
                        model.addMonths(1)
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!model.canShowLaterMonth)
                    .help("Next month (→)")

                    Button {
                        model.addMonths(12)
                    } label: {
                        Image(systemName: "chevron.forward.2")
                    }
                    .disabled(!model.canShowLaterYear)
                    .help("Next year (↑)")
                }

                if useJulian {
                    badge("Julian", .orange)
                        .help("Dates are shown in the Julian calendar (see Settings)")
                }
                if inIsrael {
                    badge("Israel", .blue)
                        .help("Holidays follow Israel observance (see Settings)")
                }

                Spacer()

                Button("Today") {
                    model.goToToday()
                }

                #if os(iOS)
                    // On the Mac, Settings lives in the app menu (⌘,); iOS needs
                    // its own way in.
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                #endif
            }

            MonthPager(model: model) { year, month in
                monthContent(year: year, month: month)
            }
        }
        .padding()
        .task {
            // Keep the today highlight correct across midnight.
            for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                model.refreshToday()
            }
        }
        #if os(macOS)
            .frame(minWidth: 560, minHeight: 480)
        #endif
        #if os(iOS)
            .sheet(isPresented: $showingSettings) {
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    showingSettings = false
                                }
                            }
                        }
                }
            }
        #endif
    }

    /// A capsule in the control bar calling out one of the display modes.
    private func badge(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Capsule().fill(color))
            .colorScheme(.dark)
    }

    @ViewBuilder private func monthContent(year: Int, month: Int) -> some View {
        let displayedMonth = CalendarMonth(
            year: year, month: month,
            calendar: useJulian ? .julian : .gregorian,
            options: HolidayOptions(
                inIsrael: inIsrael, showParsha: showParsha,
                showOmer: showOmer, showCholHamoed: showCholHamoed))
        if isCompact {
            CompactMonthView(month: displayedMonth, today: model.today, fontSize: model.fontSize)
        } else {
            MonthGridView(month: displayedMonth, today: model.today, fontSize: model.fontSize)
        }
    }
}

#Preview {
    CalendarScreen()
        .environment(CalendarViewModel())
}
