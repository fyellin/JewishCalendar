// CalendarMonth.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// Everything the MonthGridView needs in order to display one secular month.
/// The user's preferences are captured at creation time.
struct CalendarMonth {
    /// The secular year being displayed
    let year: Int

    /// The secular month being displayed
    let month: Int

    let calendar: SecularCalendar
    let options: HolidayOptions

    /// One entry for each day of the month.
    let days: [CalendarDay]

    init(
        year: Int, month: Int,
        calendar: SecularCalendar = Preferences.secularCalendar,
        options: HolidayOptions = Preferences.holidayOptions
    ) {
        self.year = year
        self.month = month
        self.calendar = calendar
        self.options = options

        let firstDay = calendar.absoluteDay(of: SecularDate(year: year, month: month, day: 1))
        let length = calendar.lengthOfMonth(month, ofYear: year)
        self.days = (firstDay..<(firstDay + length)).map { CalendarDay($0, calendar: calendar) }
    }

    /// The holidays for the given day, using the options with which we were created.
    func holidays(on day: CalendarDay) -> [String] {
        day.holidays(options)
    }

    /// Today's date, in the calendar being displayed.
    var today: SecularDate {
        calendar.today()
    }

    /// The range of Hebrew dates covered by this secular month, such as
    /// "16 Tamuz — 17 Ab 5786".
    var hebrewDateRange: String {
        let firstDay = days.first!
        let lastDay = days.last!
        let start: String
        if firstDay.hebrewDate.month == lastDay.hebrewDate.month {
            start = "\(firstDay.hebrewDate.day)"
        } else if firstDay.hebrewDate.year == lastDay.hebrewDate.year {
            start = "\(firstDay.hebrewDate.day) \(firstDay.hebrewMonthName)"
        } else {
            start = "\(firstDay.hebrewDate.day) \(firstDay.hebrewMonthName) \(firstDay.hebrewDate.year)"
        }
        let end = "\(lastDay.hebrewDate.day) \(lastDay.hebrewMonthName) \(lastDay.hebrewDate.year)"
        return "\(start) — \(end)"
    }
}
