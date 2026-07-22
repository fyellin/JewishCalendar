// HolidayOptionsTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

/// One Hebrew year of each of the fourteen year types (see DateTests.swift).
private let testYears = [5780, 5781, 5782, 5784, 5785, 5786, 5787, 5788, 5789, 5790, 5795, 5797, 5803, 5812]

struct HolidayOptionsTests {
    /// Turning off each display option removes exactly its own items and
    /// changes nothing else, on every day of the year.  (The golden file only
    /// exercises the default options, with everything turned on.)
    @Test(arguments: testYears, [false, true])
    func eachFlagRemovesOnlyItsOwnItems(year: Int, inIsrael: Bool) {
        let hebrewYear = HebrewYear(year)
        let everything = HolidayOptions(inIsrael: inIsrael)
        var noOmer = everything
        noOmer.showOmer = false
        var noCholHamoed = everything
        noCholHamoed.showCholHamoed = false
        var noParsha = everything
        noParsha.showParsha = false

        var omerCount = 0
        var cholHamoedCount = 0
        var parshaCount = 0
        for absolute in hebrewYear.firstDay..<(hebrewYear.firstDay + hebrewYear.length) {
            let day = CalendarDay(absolute, calendar: .gregorian)
            let all = day.holidays(everything)
            omerCount += all.filter { $0.hasSuffix("day Omer") }.count
            cholHamoedCount += all.filter { $0 == "Chol Hamoed" }.count

            #expect(day.holidays(noOmer) == all.filter { !$0.hasSuffix("day Omer") })
            #expect(day.holidays(noCholHamoed) == all.filter { $0 != "Chol Hamoed" })

            // The parsha, when shown, is a single item appended at the end,
            // and only on Shabbat.
            let withoutParsha = day.holidays(noParsha)
            if withoutParsha != all {
                parshaCount += 1
                #expect(day.weekday == .saturday)
                #expect(withoutParsha == Array(all.dropLast()))
            }
        }

        // Each flag had something real to remove.
        #expect(omerCount == 48, "49 days of the Omer, minus Lag BaOmer")
        #expect(cholHamoedCount == (inIsrael ? 10 : 8))
        #expect(parshaCount >= 40)
    }
}
