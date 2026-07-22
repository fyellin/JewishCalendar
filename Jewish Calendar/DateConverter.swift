// DateConverter.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// A day of the week.  The raw value is chosen so that a day's weekday is its
/// absolute day number mod 7.
enum Weekday: Int {
    case sunday = 0, monday, tuesday, wednesday, thursday, friday, saturday

    /// The weekday of the given day count, handling negative values correctly.
    init(dayNumber: Int) {
        self.init(rawValue: (dayNumber % 7 + 7) % 7)!
    }

    static func + (weekday: Weekday, days: Int) -> Weekday {
        Weekday(dayNumber: weekday.rawValue + days)
    }

    static func - (weekday: Weekday, days: Int) -> Weekday {
        Weekday(dayNumber: weekday.rawValue - days)
    }
}

/// A count of days in which day 1 is Monday, January 1, 1 CE in the (proleptic)
/// Gregorian calendar.  This is the "absolute date" of Reingold and Dershowitz's
/// "Calendrical Calculations", and is the common currency through which the
/// secular and Hebrew calendars are converted to each other.
struct AbsoluteDay: Strideable {
    let dayNumber: Int

    init(_ dayNumber: Int) {
        self.dayNumber = dayNumber
    }

    var weekday: Weekday {
        Weekday(dayNumber: dayNumber)
    }

    /// The current day.
    static func today() -> AbsoluteDay {
        SecularCalendar.gregorian.absoluteDay(of: SecularCalendar.gregorian.today())
    }

    static func < (lhs: AbsoluteDay, rhs: AbsoluteDay) -> Bool {
        lhs.dayNumber < rhs.dayNumber
    }

    static func + (day: AbsoluteDay, days: Int) -> AbsoluteDay {
        AbsoluteDay(day.dayNumber + days)
    }

    static func - (day: AbsoluteDay, days: Int) -> AbsoluteDay {
        AbsoluteDay(day.dayNumber - days)
    }

    static func - (lhs: AbsoluteDay, rhs: AbsoluteDay) -> Int {
        lhs.dayNumber - rhs.dayNumber
    }

    func distance(to other: AbsoluteDay) -> Int {
        other.dayNumber - dayNumber
    }

    func advanced(by days: Int) -> AbsoluteDay {
        AbsoluteDay(dayNumber + days)
    }
}

/// A date in one of the secular calendars.  Months are numbered 1 (January)
/// through 12 (December).
struct SecularDate: Equatable {
    var year: Int
    var month: Int
    var day: Int
}

/// The two secular calendars.  They differ only in their leap year rule, and
/// hence in how far they have drifted apart over the centuries.
enum SecularCalendar: CaseIterable {
    case gregorian
    case julian

    func isLeapYear(_ year: Int) -> Bool {
        guard year.isMultiple(of: 4) else { return false }
        switch self {
            case .julian: return true
            case .gregorian: return year.isMultiple(of: 400) || !year.isMultiple(of: 100)
        }
    }

    func lengthOfYear(_ year: Int) -> Int {
        isLeapYear(year) ? 366 : 365
    }

    func lengthOfMonth(_ month: Int, ofYear year: Int) -> Int {
        month == 2 && isLeapYear(year) ? 29 : Self.monthLengths[month]
    }

    /// The first day (January 1) of the given year.
    func firstDay(ofYear year: Int) -> AbsoluteDay {
        let priorYears = year - 1
        var days = 365 * priorYears + priorYears / 4
        switch self {
            case .julian: days -= 2
            case .gregorian: days += priorYears / 400 - priorYears / 100
        }
        return AbsoluteDay(days + 1)
    }

    func absoluteDay(of date: SecularDate) -> AbsoluteDay {
        let leapAdjustment = date.month > 2 && isLeapYear(date.year) ? 1 : 0
        let dayOfYear = Self.daysBeforeMonth[date.month] + leapAdjustment + date.day
        return firstDay(ofYear: date.year) + (dayOfYear - 1)
    }

    func date(of day: AbsoluteDay) -> SecularDate {
        var year = day.dayNumber / 366
        while day >= firstDay(ofYear: year + 1) {
            year += 1
        }
        var dayOfMonth = day - firstDay(ofYear: year) + 1
        var month = 1
        while dayOfMonth > lengthOfMonth(month, ofYear: year) {
            dayOfMonth -= lengthOfMonth(month, ofYear: year)
            month += 1
        }
        return SecularDate(year: year, month: month, day: dayOfMonth)
    }

    /// Today's date, in this calendar.
    func today() -> SecularDate {
        let components = Calendar(identifier: .gregorian)
            .dateComponents([.year, .month, .day], from: Date())
        let gregorianToday = SecularDate(
            year: components.year!, month: components.month!, day: components.day!)
        switch self {
            case .gregorian: return gregorianToday
            case .julian: return date(of: SecularCalendar.gregorian.absoluteDay(of: gregorianToday))
        }
    }

    // January is at index 1.  February's entry assumes a non-leap year.
    private static let monthLengths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    private static let daysBeforeMonth = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
}

/// A month of the Hebrew year.  The raw values follow the traditional numbering,
/// in which Nisan is month 1 even though the year number changes in Tishrei.
/// In a non-leap year there is a single month of Adar, represented here as `adarI`.
enum HebrewMonth: Int {
    case nisan = 1, iyar, sivan, tammuz, av, elul
    case tishrei, cheshvan, kislev, tevet, shevat
    case adarI, adarII

    /// The months of a year, in calendar order beginning with Tishrei.
    static func yearOrder(leapYear: Bool) -> [HebrewMonth] {
        leapYear
            ? [.tishrei, .cheshvan, .kislev, .tevet, .shevat, .adarI, .adarII,
                  .nisan, .iyar, .sivan, .tammuz, .av, .elul]
            : [.tishrei, .cheshvan, .kislev, .tevet, .shevat, .adarI,
                  .nisan, .iyar, .sivan, .tammuz, .av, .elul]
    }

    /// The name shown to the user.
    func name(inLeapYear leapYear: Bool) -> String {
        switch self {
            case .nisan: return "Nisan"
            case .iyar: return "Iyar"
            case .sivan: return "Sivan"
            case .tammuz: return "Tammuz"
            case .av: return "Av"
            case .elul: return "Elul"
            case .tishrei: return "Tishrei"
            case .cheshvan: return "Cheshvan"
            case .kislev: return "Kislev"
            case .tevet: return "Tevet"
            case .shevat: return "Shevat"
            case .adarI: return leapYear ? "Adar I" : "Adar"
            case .adarII: return leapYear ? "Adar II" : "Adar"
        }
    }
}

/// A date in the Hebrew calendar.
struct HebrewDate {
    var year: Int
    var month: HebrewMonth
    var day: Int
}

/// A single Hebrew year.  Its first day and its length together determine the
/// length of every month, so this type is the context needed to interpret any
/// date within the year.
struct HebrewYear: Equatable {
    let year: Int

    /// The day of Rosh Hashanah, 1 Tishrei.
    let firstDay: AbsoluteDay

    /// One of 353, 354, 355 (non-leap) or 383, 384, 385 (leap).
    let length: Int

    init(_ year: Int) {
        self.year = year
        self.firstDay = Self.firstDay(ofYear: year)
        self.length = Self.firstDay(ofYear: year + 1) - firstDay
    }

    /// The year containing the given day.
    init(containing day: AbsoluteDay) {
        var candidate = HebrewYear(day.dayNumber / 366 + 3760)
        while !candidate.contains(day) {
            candidate = HebrewYear(candidate.year + 1)
        }
        self = candidate
    }

    /// A leap year has a thirteenth month, Adar II.
    var isLeap: Bool {
        Self.isLeapYear(year)
    }

    /// In a deficient year, Cheshvan and Kislev both have 29 days.
    var isDeficient: Bool {
        length % 10 == 3
    }

    /// In a complete year, Cheshvan and Kislev both have 30 days.
    var isComplete: Bool {
        length % 10 == 5
    }

    /// The months of this year, in calendar order beginning with Tishrei.
    var months: [HebrewMonth] {
        HebrewMonth.yearOrder(leapYear: isLeap)
    }

    func length(of month: HebrewMonth) -> Int {
        switch month {
            case .nisan, .sivan, .av, .tishrei, .shevat: return 30
            case .iyar, .tammuz, .elul, .tevet, .adarII: return 29
            case .cheshvan: return isComplete ? 30 : 29
            case .kislev: return isDeficient ? 29 : 30
            case .adarI: return isLeap ? 30 : 29
        }
    }

    func contains(_ day: AbsoluteDay) -> Bool {
        day >= firstDay && day - firstDay < length
    }

    /// The 1-based day of the year, counting from 1 Tishrei.
    func dayOfYear(of day: AbsoluteDay) -> Int {
        day - firstDay + 1
    }

    func absoluteDay(of date: HebrewDate) -> AbsoluteDay {
        assert(date.year == year)
        let daysBefore = months.prefix { $0 != date.month }
            .reduce(0) { $0 + length(of: $1) }
        return firstDay + daysBefore + (date.day - 1)
    }

    func date(of day: AbsoluteDay) -> HebrewDate {
        var remaining = dayOfYear(of: day)
        for month in months {
            let monthLength = length(of: month)
            if remaining <= monthLength {
                return HebrewDate(year: year, month: month, day: remaining)
            }
            remaining -= monthLength
        }
        preconditionFailure("Day \(day.dayNumber) is not in Hebrew year \(year)")
    }

    /// Is it a leap year in the Hebrew calendar?  Leap years occur seven times in
    /// each nineteen-year cycle.
    static func isLeapYear(_ year: Int) -> Bool {
        switch year % 19 {
            case 0, 3, 6, 8, 11, 14, 17: return true
            default: return false
        }
    }

    /// The day of Rosh Hashanah of the given year, computed from the mean lunar
    /// conjunction (molad) plus the traditional postponement rules.
    static func firstDay(ofYear year: Int) -> AbsoluteDay {
        // Times of day are measured in "parts": 1080 to the hour, 25920 to the day.
        let partsPerDay = 25920
        let lunarMonth = 29 * partsPerDay + 13753 // 29 days, 12 hours, 793 parts
        let firstMolad = 1 * partsPerDay + 5604 // the molad of Tishrei of year 1

        let priorYears = year - 1
        let priorMonths = 235 * (priorYears / 19) // months in complete 19-year cycles
            + 12 * (priorYears % 19) // regular months in this cycle
            + ((priorYears % 19) * 7 + 1) / 19 // leap months in this cycle
        let (days, parts) = (firstMolad + lunarMonth * priorMonths)
            .quotientAndRemainder(dividingBy: partsPerDay)
        var day = AbsoluteDay(days - 1373428) // convert the epoch to absolute days

        // Postpone by a day if the molad falls at or after noon, or in two other
        // cases (the dechiyot) that keep every year's length legal.
        if parts >= 19440
            || (day.weekday == .tuesday && parts >= 9924 && !isLeapYear(year))
            || (day.weekday == .monday && parts >= 16789 && isLeapYear(year - 1)) {
            day = day + 1
        }
        // Rosh Hashanah may not fall on Sunday, Wednesday, or Friday.
        switch day.weekday {
            case .sunday, .wednesday, .friday: return day + 1
            default: return day
        }
    }
}

/// A single day, seen simultaneously through the secular and Hebrew calendars.
struct CalendarDay {
    let absoluteDay: AbsoluteDay
    let secularCalendar: SecularCalendar
    let secularDate: SecularDate
    let hebrewYear: HebrewYear
    let hebrewDate: HebrewDate

    init(_ absoluteDay: AbsoluteDay, calendar: SecularCalendar) {
        self.absoluteDay = absoluteDay
        self.secularCalendar = calendar
        self.secularDate = calendar.date(of: absoluteDay)
        self.hebrewYear = HebrewYear(containing: absoluteDay)
        self.hebrewDate = hebrewYear.date(of: absoluteDay)
    }

    var weekday: Weekday {
        absoluteDay.weekday
    }

    /// The 1-based day of the Hebrew year, counting from 1 Tishrei.
    var dayOfHebrewYear: Int {
        hebrewYear.dayOfYear(of: absoluteDay)
    }

    var hebrewMonthLength: Int {
        hebrewYear.length(of: hebrewDate.month)
    }

    var secularMonthLength: Int {
        secularCalendar.lengthOfMonth(secularDate.month, ofYear: secularDate.year)
    }

    /// The name of the Hebrew month, as shown to the user.
    var hebrewMonthName: String {
        hebrewDate.month.name(inLeapYear: hebrewYear.isLeap)
    }
}
