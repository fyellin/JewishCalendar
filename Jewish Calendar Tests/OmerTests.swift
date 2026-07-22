// OmerTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

/// One Hebrew year of each of the fourteen year types (see DateTests.swift).
private let testYears = [5780, 5781, 5782, 5784, 5785, 5786, 5787, 5788, 5789, 5790, 5795, 5797, 5803, 5812]

/// English ordinals, spelled out independently of NumberFormatter.  The app
/// formats the Omer count with a locale-sensitive NumberFormatter; this test
/// documents the expectation that it produces English ordinals.
private func englishOrdinal(_ n: Int) -> String {
    let suffix: String
    switch (n % 100, n % 10) {
        case (11...13, _): suffix = "th"
        case (_, 1): suffix = "st"
        case (_, 2): suffix = "nd"
        case (_, 3): suffix = "rd"
        default: suffix = "th"
    }
    return "\(n)\(suffix)"
}

struct OmerTests {
    /// The Omer count runs exactly 49 consecutive days, from 16 Nisan through
    /// 5 Sivan, with day 33 shown as Lag BaOmer instead of a count.
    @Test(arguments: testYears)
    func omerCount(year: Int) {
        let hebrewYear = HebrewYear(year)
        let firstDay = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: .nisan, day: 16))
        let lastDay = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: .sivan, day: 5))
        #expect(lastDay == firstDay + 48)

        for count in 1...49 {
            let day = CalendarDay(firstDay + (count - 1), calendar: .gregorian)
            let holidays = day.holidays(HolidayOptions())
            let omerStrings = holidays.filter { $0.hasSuffix("day Omer") }
            if count == 33 {
                // Lag BaOmer is shown instead of "33rd day Omer".
                #expect(omerStrings.isEmpty)
                #expect(holidays.contains("Lag BaOmer"))
            } else {
                #expect(omerStrings == ["\(englishOrdinal(count)) day Omer"])
            }
        }

        // The first and last days coincide with their holidays.
        #expect(CalendarDay(firstDay, calendar: .gregorian).holidays(HolidayOptions())
            == ["Pesach", "1st day Omer"])
        #expect(CalendarDay(lastDay, calendar: .gregorian).holidays(HolidayOptions())
            .contains("Erev Shavuot"))

        // And no Omer count appears anywhere else in the year.
        var omerDays = 0
        for absolute in hebrewYear.firstDay..<(hebrewYear.firstDay + hebrewYear.length) {
            let day = CalendarDay(absolute, calendar: .gregorian)
            if day.holidays(HolidayOptions()).contains(where: { $0.hasSuffix("day Omer") }) {
                omerDays += 1
                #expect(absolute >= firstDay && absolute <= lastDay)
            }
        }
        #expect(omerDays == 48)
    }
}
