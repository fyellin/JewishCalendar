// CalendarScreen.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The main screen: navigation controls above, the month display below.
/// Wide screens (Mac, iPad, iPhone landscape) get the full grid with holidays
/// in the cells; compact screens get the dot grid with a detail card.
struct CalendarScreen: View {
    @Environment(CalendarViewModel.self) private var model

    // Watching the preferences here refreshes the calendar the moment they are
    // changed in the Settings window.  The keys and defaults match Preferences.
    @AppStorage("julian") private var useJulian = false
    @AppStorage("israel") private var inIsrael = false
    @AppStorage("parsha") private var showParsha = true
    @AppStorage("omer") private var showOmer = true
    @AppStorage("chol") private var showCholHamoed = true

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

            monthContent
                .monthCardSwipe(model: model)
        }
        .padding()
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

    @ViewBuilder private var monthContent: some View {
        if isCompact {
            CompactMonthView(month: displayedMonth, fontSize: model.fontSize)
        } else {
            MonthGridView(month: displayedMonth, fontSize: model.fontSize)
        }
    }

    private var displayedMonth: CalendarMonth {
        CalendarMonth(
            year: model.year, month: model.month,
            calendar: useJulian ? .julian : .gregorian,
            options: HolidayOptions(
                inIsrael: inIsrael, showParsha: showParsha,
                showOmer: showOmer, showCholHamoed: showCholHamoed))
    }
}

#Preview {
    CalendarScreen()
        .environment(CalendarViewModel())
}
