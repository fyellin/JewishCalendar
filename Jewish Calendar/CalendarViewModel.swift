// CalendarViewModel.swift
// Copyright (c) 2019 Frank Yellin.
//
// The calendar's view model and menu commands.

import SwiftUI

/// The state of the calendar display: which month is showing and how big the
/// text is.  Shared by the view hierarchy and the menu commands.
@Observable
final class CalendarViewModel {
    static let yearRange = 1000...3999

    var year: Int {
        didSet {
            if !Self.yearRange.contains(year) {
                year = min(max(year, Self.yearRange.lowerBound), Self.yearRange.upperBound)
            }
        }
    }

    /// The month being displayed, 1 (January) through 12 (December).
    var month: Int

    /// The base size of the calendar text; everything else scales from it.
    var fontSize: Double {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }

    /// iOS has no menu commands to adjust the font size, and its screens have
    /// room to spare, so it gets a larger default than the Mac.
    #if os(iOS)
        private static let defaultFontSize = 16.0
    #else
        private static let defaultFontSize = 13.0
    #endif

    init() {
        let today = Preferences.secularCalendar.today()
        year = today.year
        month = today.month
        let storedSize = UserDefaults.standard.double(forKey: "fontSize")
        fontSize = storedSize == 0 ? Self.defaultFontSize : storedSize
    }

    func goToToday() {
        let today = Preferences.secularCalendar.today()
        (year, month) = (today.year, today.month)
    }

    /// Moves the display forward or backward, staying within the supported years.
    func addMonths(_ delta: Int) {
        let totalMonths = year * 12 + (month - 1) + delta
        guard Self.yearRange.contains(totalMonths / 12) else { return }
        year = totalMonths / 12
        month = totalMonths % 12 + 1
    }

    var canShowEarlierMonth: Bool { (year, month) > (Self.yearRange.lowerBound, 1) }
    var canShowLaterMonth: Bool { (year, month) < (Self.yearRange.upperBound, 12) }
    var canShowEarlierYear: Bool { year > Self.yearRange.lowerBound }
    var canShowLaterYear: Bool { year < Self.yearRange.upperBound }

    func adjustFontSize(by delta: Double) {
        fontSize = max(5, fontSize + delta)
    }
}

/// The app's menu additions: a Date menu, font size commands, and printing.
struct CalendarCommands: Commands {
    let model: CalendarViewModel

    var body: some Commands {
        CommandMenu("Date") {
            Button("Today") {
                model.goToToday()
            }
            .keyboardShortcut("t")

            Divider()

            Button("Previous Month") {
                model.addMonths(-1)
            }
            .keyboardShortcut(.leftArrow, modifiers: [])
            .disabled(!model.canShowEarlierMonth)

            Button("Next Month") {
                model.addMonths(1)
            }
            .keyboardShortcut(.rightArrow, modifiers: [])
            .disabled(!model.canShowLaterMonth)

            Button("Previous Year") {
                model.addMonths(-12)
            }
            .keyboardShortcut(.downArrow, modifiers: [])
            .disabled(!model.canShowEarlierYear)

            Button("Next Year") {
                model.addMonths(12)
            }
            .keyboardShortcut(.upArrow, modifiers: [])
            .disabled(!model.canShowLaterYear)
        }

        CommandGroup(before: .toolbar) {
            Button("Increase Font Size") {
                model.adjustFontSize(by: 1)
            }
            .keyboardShortcut("+")

            Button("Decrease Font Size") {
                model.adjustFontSize(by: -1)
            }
            .keyboardShortcut("-")

            Divider()
        }

        #if os(macOS)
            CommandGroup(replacing: .printItem) {
                Button("Print…") {
                    printCalendar()
                }
                .keyboardShortcut("p")
            }
        #endif
    }

    #if os(macOS)
        /// Prints the currently displayed month.
        private func printCalendar() {
            let grid = MonthGridView(
                month: CalendarMonth(year: model.year, month: model.month),
                fontSize: model.fontSize)
            let page = grid
                .padding()
                .background(Color.white)
                .environment(\.colorScheme, .light)
            let hostingView = NSHostingView(rootView: page)
            hostingView.frame = NSRect(x: 0, y: 0, width: 468, height: 560)
            NSPrintOperation(view: hostingView).run()
        }
    #endif
}
