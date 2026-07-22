// HebrewYearStructureTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

struct HebrewYearStructureTests {
    /// Structural invariants of the calendar, checked over three thousand
    /// years.  These are classical corollaries of the molad and postponement
    /// rules, computed independently of them, so they exercise years far
    /// beyond the fourteen that the golden file covers.
    @Test
    func yearInvariants() {
        for year in 4000...7000 {
            let hebrewYear = HebrewYear(year)

            let validLengths = hebrewYear.isLeap ? [383, 384, 385] : [353, 354, 355]
            #expect(validLengths.contains(hebrewYear.length), "Year \(year) has length \(hebrewYear.length)")

            // Rosh Hashanah never falls on Sunday, Wednesday, or Friday.
            let roshHashanah = hebrewYear.firstDay.weekday
            #expect(![Weekday.sunday, .wednesday, .friday].contains(roshHashanah), "Year \(year)")

            // Yom Kippur (10 Tishrei) never falls on Friday or Sunday.
            let yomKippur = (hebrewYear.firstDay + 9).weekday
            #expect(yomKippur != .friday && yomKippur != .sunday, "Year \(year)")

            // Hoshana Rabbah (21 Tishrei) never falls on Shabbat.
            #expect((hebrewYear.firstDay + 20).weekday != .saturday, "Year \(year)")

            // The first day of Pesach (15 Nisan) never falls on Monday,
            // Wednesday, or Friday.
            let pesach = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: .nisan, day: 15)).weekday
            #expect(![Weekday.monday, .wednesday, .friday].contains(pesach), "Year \(year)")

            // Purim (14 Adar, or Adar II in a leap year) never falls on Shabbat.
            let adar: HebrewMonth = hebrewYear.isLeap ? .adarII : .adarI
            let purim = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: adar, day: 14)).weekday
            #expect(purim != .saturday, "Year \(year)")

            // 10 Tevet never falls on Shabbat.  (So the branch in Holidays.swift
            // that moves Tzom Tevet from Shabbat to Sunday can never be taken.)
            let tzomTevet = hebrewYear.absoluteDay(of: HebrewDate(year: year, month: .tevet, day: 10)).weekday
            #expect(tzomTevet != .saturday, "Year \(year)")
        }

        // Leap years occur seven times in every nineteen-year cycle.
        for cycleStart in stride(from: 4000, to: 7000, by: 19) {
            let leapCount = (cycleStart..<cycleStart + 19).filter { HebrewYear.isLeapYear($0) }.count
            #expect(leapCount == 7, "Cycle starting \(cycleStart)")
        }
    }

    /// The computed calendar agrees with historical reality.
    @Test
    func knownRoshHashanahDates() {
        // Rosh Hashanah 5780 was Monday, September 30, 2019.
        expectRoshHashanah(5780, onGregorian: 2019, 9, 30, weekday: .monday)
        // Rosh Hashanah 5786 was Tuesday, September 23, 2025.
        expectRoshHashanah(5786, onGregorian: 2025, 9, 23, weekday: .tuesday)
        // Rosh Hashanah 5787 will be Saturday, September 12, 2026.
        expectRoshHashanah(5787, onGregorian: 2026, 9, 12, weekday: .saturday)
    }

    private func expectRoshHashanah(
        _ year: Int, onGregorian secularYear: Int, _ month: Int, _ day: Int, weekday: Weekday
    ) {
        let firstDay = HebrewYear(year).firstDay
        #expect(SecularCalendar.gregorian.date(of: firstDay)
            == SecularDate(year: secularYear, month: month, day: day))
        #expect(firstDay.weekday == weekday)
    }
}
