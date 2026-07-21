// DateTests.swift
// Copyright (c) 2019 Frank Yellin
// Created on 8/31/19.

import Foundation
import Testing

@testable import Jewish_Calendar

/// Used to locate the test bundle, which holds the golden file.
private final class BundleLocator {}

/// One Hebrew year of each of the fourteen year types, identified by the
/// weekday of Rosh Hashanah, the year length, and whether it is a leap year.
///
///     5780 Monday   long   normal      5789 Thursday normal normal
///     5781 Saturday short  normal      5790 Monday   short  leap
///     5782 Tuesday  normal leap        5795 Thursday long   leap
///     5784 Saturday short  leap        5797 Monday   short  normal
///     5785 Thursday long   normal      5803 Monday   long   leap
///     5786 Tuesday  normal normal      5812 Thursday short  leap
///     5787 Saturday long   leap
///     5788 Saturday long   normal
private let testYears = [5780, 5781, 5782, 5784, 5785, 5786, 5787, 5788, 5789, 5790, 5795, 5797, 5803, 5812]

struct DateTests {
    @Test(arguments: testYears)
    func basicCalendarOperation(year: Int) {
        let hebrewYear = HebrewYear(year)

        // Rosh Hashanah is 1 Tishrei, and never falls on Sunday, Wednesday, or Friday.
        #expect(hebrewYear.firstDay
            == hebrewYear.absoluteDay(of: HebrewDate(year: year, month: .tishrei, day: 1)))
        let weekday = hebrewYear.firstDay.weekday
        #expect(weekday != .sunday)
        #expect(weekday != .wednesday)
        #expect(weekday != .friday)

        // Cheshvan and Kislev are the months whose lengths vary with the year type.
        switch hebrewYear.length % 10 {
            case 3:
                #expect(hebrewYear.length(of: .cheshvan) == 29)
                #expect(hebrewYear.length(of: .kislev) == 29)
            case 4:
                #expect(hebrewYear.length(of: .cheshvan) == 29)
                #expect(hebrewYear.length(of: .kislev) == 30)
            case 5:
                #expect(hebrewYear.length(of: .cheshvan) == 30)
                #expect(hebrewYear.length(of: .kislev) == 30)
            default:
                Issue.record("Unexpected year length \(hebrewYear.length)")
        }

        // The months tile the year exactly: each month starts the day after the
        // previous one ends, and the year ends the day before the next Rosh Hashanah.
        let months = hebrewYear.months
        #expect(months.count == (hebrewYear.isLeap ? 13 : 12))
        #expect(months.map { hebrewYear.length(of: $0) }.reduce(0, +) == hebrewYear.length)
        for (previous, next) in zip(months, months.dropFirst()) {
            let lastOfPrevious = hebrewYear.absoluteDay(
                of: HebrewDate(year: year, month: previous, day: hebrewYear.length(of: previous)))
            let firstOfNext = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: next, day: 1))
            #expect(firstOfNext == lastOfPrevious + 1)
        }
        let lastDay = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: .elul, day: 29))
        #expect(HebrewYear(year + 1).firstDay == lastDay + 1)

        // Converting a day to a Hebrew date and back is the identity.
        for day in hebrewYear.firstDay..<(hebrewYear.firstDay + hebrewYear.length) {
            #expect(hebrewYear.contains(day))
            let date = hebrewYear.date(of: day)
            #expect(date.year == year)
            #expect(hebrewYear.absoluteDay(of: date) == day)
            #expect(HebrewYear(containing: day) == hebrewYear)
        }
    }

    @Test
    func independenceDay() throws {
        for year in 1940...2010 {
            let hebrewYear = HebrewYear(year + 3760)
            let iyar2 = hebrewYear.absoluteDay(of: HebrewDate(year: year + 3760, month: .iyar, day: 2))
            let holidays = (iyar2...iyar2 + 4).map {
                CalendarDay($0, calendar: .gregorian).holidays(HolidayOptions())
            }
            let zikaron = holidays.map { $0.contains("Yom HaZikaron") }
            let atzmaut = holidays.map { $0.contains("Yom HaAtzmaut") }
            if year < 1948 {
                #expect(!zikaron.contains(true))
                #expect(!atzmaut.contains(true))
            } else {
                // Exactly one day of each, on consecutive days, on the day of Iyar
                // required by the postponement rules.
                let zikaronIndex = try #require(zikaron.firstIndex(of: true))
                let atzmautIndex = try #require(atzmaut.firstIndex(of: true))
                #expect(zikaronIndex == zikaron.lastIndex(of: true))
                #expect(atzmautIndex == atzmaut.lastIndex(of: true))
                #expect(zikaronIndex + 1 == atzmautIndex)
                let weekdayOfTheFifth = (iyar2 + 3).weekday
                let atzmautDayOfIyar = atzmautIndex + 2
                switch weekdayOfTheFifth {
                    case .monday where year < 2004, .wednesday:
                        #expect(atzmautDayOfIyar == 5)
                    case .monday:
                        #expect(atzmautDayOfIyar == 6)
                    case .friday:
                        #expect(atzmautDayOfIyar == 4)
                    case .saturday:
                        #expect(atzmautDayOfIyar == 3)
                    default:
                        Issue.record("The fifth of Iyar should never fall on \(weekdayOfTheFifth)")
                }
            }
        }
    }

    /// Compares every day of the fourteen test years against a golden file
    /// generated by version 3.1 of this program.
    @Test
    func matchesGoldenFile() throws {
        let bundle = Bundle(for: BundleLocator.self)
        let resourceURL = try #require(bundle.url(forResource: "golden31", withExtension: "txt"))
        let contents = try String(contentsOf: resourceURL, encoding: .utf8)
        var expectedLines = contents.split(whereSeparator: \.isNewline)[...]

        for year in testYears {
            let hebrewYear = HebrewYear(year)
            for absolute in hebrewYear.firstDay..<HebrewYear(year + 1).firstDay {
                let day = CalendarDay(absolute, calendar: .gregorian)
                #expect(day.hebrewDate.year == year)
                #expect(hebrewYear.absoluteDay(of: day.hebrewDate) == absolute)
                #expect(SecularCalendar.gregorian.absoluteDay(of: day.secularDate) == absolute)
                #expect(day.dayOfHebrewYear == absolute - hebrewYear.firstDay + 1)

                let diaspora = day.holidays(HolidayOptions(inIsrael: false))
                let israel = day.holidays(HolidayOptions(inIsrael: true))
                // The line format (including the doubled month length) matches the
                // program that generated the golden file.
                var line = """
                \(absolute.dayNumber) \(day.dayOfHebrewYear) \(day.hebrewDate.year) \
                \(day.hebrewDate.month.rawValue) \(day.hebrewDate.day) \
                \(day.secularDate.year) \(day.secularDate.month) \(day.secularDate.day) \
                \(day.secularMonthLength) \(day.secularMonthLength) \(diaspora)
                """
                if diaspora != israel {
                    line += " \(israel)"
                }
                let expected = try #require(expectedLines.first, "Golden file ended too soon")
                #expect(String(expected) == line)
                expectedLines = expectedLines.dropFirst()
            }
        }
        #expect(expectedLines.isEmpty, "Golden file has \(expectedLines.count) extra lines")
    }
}
