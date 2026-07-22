// SecularCalendarTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

struct SecularCalendarTests {
    /// Years chosen to exercise the leap-year rules of both calendars.
    private static let sampleYears = [1, 4, 100, 400, 1582, 1900, 2000, 2023, 2024, 2100]

    /// Converting every day of a sample year to a date and back is the
    /// identity, in both calendars.  (The golden file only exercises Gregorian.)
    @Test(arguments: SecularCalendar.allCases)
    func conversionsRoundTrip(calendar: SecularCalendar) {
        for year in Self.sampleYears {
            let firstDay = calendar.firstDay(ofYear: year)
            let yearLength = calendar.lengthOfYear(year)
            #expect(calendar.firstDay(ofYear: year + 1) - firstDay == yearLength)
            #expect((1...12).map { calendar.lengthOfMonth($0, ofYear: year) }.reduce(0, +) == yearLength)

            var expected = SecularDate(year: year, month: 1, day: 1)
            for day in firstDay..<(firstDay + yearLength) {
                #expect(calendar.date(of: day) == expected)
                #expect(calendar.absoluteDay(of: expected) == day)
                if expected.day < calendar.lengthOfMonth(expected.month, ofYear: year) {
                    expected.day += 1
                } else {
                    expected = SecularDate(year: year, month: expected.month + 1, day: 1)
                }
            }
        }
    }

    /// The calendars differ only in their treatment of century years.
    @Test
    func leapYearRules() {
        #expect(SecularCalendar.julian.isLeapYear(1900))
        #expect(!SecularCalendar.gregorian.isLeapYear(1900))
        #expect(SecularCalendar.julian.isLeapYear(2000))
        #expect(SecularCalendar.gregorian.isLeapYear(2000))
        #expect(SecularCalendar.julian.isLeapYear(2100))
        #expect(!SecularCalendar.gregorian.isLeapYear(2100))
        for calendar in SecularCalendar.allCases {
            #expect(calendar.isLeapYear(2024))
            #expect(!calendar.isLeapYear(2023))
            #expect(calendar.lengthOfMonth(2, ofYear: 2024) == 29)
            #expect(calendar.lengthOfMonth(2, ofYear: 2023) == 28)
        }
    }

    @Test
    func knownAnchors() {
        // Absolute day 1 is Monday, January 1, 1 CE in the Gregorian calendar...
        #expect(SecularCalendar.gregorian.absoluteDay(of: SecularDate(year: 1, month: 1, day: 1)) == AbsoluteDay(1))
        #expect(AbsoluteDay(1).weekday == .monday)
        // ...and the Julian calendar starts two days earlier.
        #expect(SecularCalendar.julian.absoluteDay(of: SecularDate(year: 1, month: 1, day: 1)) == AbsoluteDay(-1))

        // The sample date used throughout Reingold and Dershowitz's
        // "Calendrical Calculations".
        #expect(SecularCalendar.gregorian.absoluteDay(of: SecularDate(year: 1945, month: 11, day: 12))
            == AbsoluteDay(710347))

        // January 1, 2000 was a Saturday.
        #expect(SecularCalendar.gregorian.absoluteDay(of: SecularDate(year: 2000, month: 1, day: 1)).weekday
            == .saturday)

        // The Gregorian reform: Thursday, October 4, 1582 (Julian) was followed
        // by Friday, October 15, 1582 (Gregorian).
        let lastJulianDay = SecularCalendar.julian.absoluteDay(of: SecularDate(year: 1582, month: 10, day: 4))
        let firstGregorianDay = SecularCalendar.gregorian.absoluteDay(of: SecularDate(year: 1582, month: 10, day: 15))
        #expect(lastJulianDay.weekday == .thursday)
        #expect(firstGregorianDay == lastJulianDay + 1)
    }

    /// From March 1900 through February 2100, the Julian calendar runs 13 days
    /// behind the Gregorian, so the same nominal date falls 13 days later.
    @Test
    func julianGregorianOffsetIsThirteenDays() {
        for (year, month, day) in [(1900, 3, 1), (1950, 6, 15), (2000, 1, 1), (2026, 7, 21), (2100, 2, 28)] {
            let date = SecularDate(year: year, month: month, day: day)
            #expect(SecularCalendar.julian.absoluteDay(of: date)
                == SecularCalendar.gregorian.absoluteDay(of: date) + 13)
        }
    }
}
