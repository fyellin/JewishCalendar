// CalendarScreen.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The main screen: navigation controls above, the month grid below.
struct CalendarScreen: View {
    @Environment(CalendarViewModel.self) private var model

    // Watching the preferences here refreshes the calendar the moment they are
    // changed in the Settings window.  The keys and defaults match Preferences.
    @AppStorage("julian") private var useJulian = false
    @AppStorage("israel") private var inIsrael = false
    @AppStorage("parsha") private var showParsha = true
    @AppStorage("omer") private var showOmer = true
    @AppStorage("chol") private var showCholHamoed = true

    private static let monthNames = DateFormatter().standaloneMonthSymbols!

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 12) {
            HStack {
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

                Spacer()

                Button("Today") {
                    model.goToToday()
                }
            }

            MonthGridView(month: displayedMonth, fontSize: model.fontSize)
        }
        .padding()
        .frame(minWidth: 560, minHeight: 480)
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
