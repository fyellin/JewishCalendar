// HebrewDateRangeTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

struct HebrewDateRangeTests {
    private func month(_ year: Int, _ month: Int) -> CalendarMonth {
        CalendarMonth(year: year, month: month, calendar: .gregorian, options: HolidayOptions())
    }

    @Test
    func monthWithinASingleHebrewMonth() {
        // February 2025 fell entirely within Shevat 5785.
        #expect(month(2025, 2).hebrewDateRange == "3 — 30 Shevat 5785")
        // February 2033 falls entirely within Adar I of leap year 5793.
        #expect(month(2033, 2).hebrewDateRange == "2 — 29 Adar I 5793")
    }

    @Test
    func monthSpanningTwoHebrewMonths() {
        // July 2026 runs from Tammuz into Av (the example in the doc comment).
        #expect(month(2026, 7).hebrewDateRange == "16 Tammuz — 17 Av 5786")
        // February 2026 runs from Shevat into Adar.
        #expect(month(2026, 2).hebrewDateRange == "14 Shevat — 11 Adar 5786")
    }

    @Test
    func monthSpanningTwoHebrewYears() {
        // September 2025 contained Rosh Hashanah 5786.
        #expect(month(2025, 9).hebrewDateRange == "8 Elul 5785 — 8 Tishrei 5786")
    }

    @Test
    func daysCoverTheSecularMonth() {
        let february = month(2026, 2)
        #expect(february.days.count == 28)
        #expect(february.days.first?.secularDate == SecularDate(year: 2026, month: 2, day: 1))
        #expect(february.days.last?.secularDate == SecularDate(year: 2026, month: 2, day: 28))
        #expect(month(2024, 2).days.count == 29)
    }
}
