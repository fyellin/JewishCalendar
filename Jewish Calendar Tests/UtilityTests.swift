// UtilityTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

struct UtilityTests {
    @Test
    func weekdayFromDayNumberHandlesNegatives() {
        #expect(Weekday(dayNumber: 1) == .monday)
        #expect(Weekday(dayNumber: 0) == .sunday)
        #expect(Weekday(dayNumber: -1) == .saturday)
        #expect(Weekday(dayNumber: -7) == .sunday)
        #expect(Weekday(dayNumber: -13) == .monday)
        for dayNumber in -21...21 {
            #expect(Weekday(dayNumber: dayNumber) == Weekday(dayNumber: dayNumber + 7))
        }
    }

    @Test
    func weekdayArithmeticWrapsAround() {
        #expect(Weekday.saturday + 1 == .sunday)
        #expect(Weekday.sunday - 1 == .saturday)
        #expect(Weekday.wednesday + 7 == .wednesday)
        #expect(Weekday.wednesday - 14 == .wednesday)
        #expect(Weekday.monday + 12 == .saturday)
        #expect(Weekday.monday - 2 == .saturday)
    }

    @Test
    func absoluteDayArithmetic() {
        let day = AbsoluteDay(1000)
        #expect(day + 5 - day == 5)
        #expect(day - 5 == AbsoluteDay(995))
        #expect(day.advanced(by: 3) == AbsoluteDay(1003))
        #expect(day.distance(to: AbsoluteDay(1010)) == 10)
        // Strideable lets AbsoluteDay ranges be iterated.
        #expect(Array(day..<(day + 3)) == [day, AbsoluteDay(1001), AbsoluteDay(1002)])
    }

    @Test
    func expandingAbbreviations() {
        #expect("Sh. Chazon".expandingAbbreviations == "Shabbat Chazon")
        #expect("Sh. HaGadol".expandingAbbreviations == "Shabbat HaGadol")
        #expect("Erev R.H.".expandingAbbreviations == "Erev Rosh Hashanah")
        #expect("Erev Y.K.".expandingAbbreviations == "Erev Yom Kippur")
        #expect("Rosh Hashanah".expandingAbbreviations == "Rosh Hashanah")
        // "Sh" alone, without the ". ", is not an abbreviation.
        #expect("Shushan Purim".expandingAbbreviations == "Shushan Purim")
        #expect("".expandingAbbreviations == "")
    }
}
