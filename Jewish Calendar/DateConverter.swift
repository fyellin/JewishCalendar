//
//  dateConverter.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/7/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

struct YearMonthDay {
    let year: Int
    let month: Int
    let day: Int
}

enum Kvia : Int {
    case short = 0
    case normal = 1
    case long = 2
    
    init(forHebrewYear year: Int) {
        let hebrewYearLength = hebrew_elapsed_days(year + 1) - hebrew_elapsed_days(year)
        assert((353...355).contains(hebrewYearLength) || (383...385).contains(hebrewYearLength))
        let raw = (hebrewYearLength % 10) - 3
        self.init(rawValue: raw)!
    }
}

/* Given a secular date, calculate the number of days since January 0, 0000 (Gregorian)
 */
func absoluteFromSecular(_ year: Int, _ month: Int, _ day: Int, _ isJulian: Bool) -> Int {
    let xyear = year - 1
    var day_number = day + 31 * (month - 1)
    if (month > 2) {
        day_number -= (23 + (4 * month))/10
        if isSecularLeapYear(year, isJulian) {
            day_number += 1
        }
    }
    day_number +=        /* the day number within the current year */
        365  * xyear +   /* days in prior years */
        (xyear / 4)      /* Julian leap years */

    if isJulian {
        return day_number - 2
    } else {
        return day_number +
            (-(xyear / 100)) +     /* deduct century years */
            (xyear / 400)          /* add Gregorian leap years */
    }
}

/* Given a Hebrew date, calculate the number of days since
 * January 0, 0001, Gregorian
 */
func absoluteFromHebrew(_ year: Int, _ month: Int, _ day: Int) -> Int {
    var sum = day + hebrew_elapsed_days(year) - 1373429
    if (month < 7) {
        let months = getHebrewMonthsInYear(year)
        for i in 7...months {
            sum += getHebrewMonthLength(year: year, month: i)
        }
        for i in 1..<month {
            sum += getHebrewMonthLength(year: year, month: i)
        }
    } else {
        for i in 7..<month {
            sum += getHebrewMonthLength(year: year, month: i)
        }
    }
    return sum
}

func secularFromAbsolute(_ date: Int, _ isJulian: Bool) -> YearMonthDay {
    var year = date/366
    var month = 1
    while date >= absoluteFromSecular(year + 1, 1, 1, isJulian) {
        year += 1
    }
    while month < 12 && date >= absoluteFromSecular(year, month + 1, 1, isJulian) {
        month += 1
    }
    let day = 1 + date - absoluteFromSecular(year, month, 1, isJulian)
    return YearMonthDay(year: year, month: month, day: day)
}


/* Given an absolute date, calculate the Hebrew date */
private func hebrewFromAbsolute(_ date: Int) -> YearMonthDay {
    let lowballSecularYear = date/366
    var year = lowballSecularYear + 3760
    while (date >= absoluteFromHebrew(1 + year, 7, 1)) {
        year += 1
    }
    let months = getHebrewMonthsInYear(year)
    var month = 7
    while date > absoluteFromHebrew(year, month, getHebrewMonthLength(year: year, month: month)) {
        month = 1 + (month % months)
    }
    let day = 1 + date - absoluteFromHebrew(year, month, 1)
    return YearMonthDay(year:year, month:month, day:day)
}

/* Number of months in a Hebrew year */
private func getHebrewMonthsInYear(_ year: Int) -> Int {
    return isHebrewLeapYear(year) ? 13 : 12
}

enum HebrewMonth: Int {
    case Nissan = 1, Iyar, Sivan, Tamuz, Ab, Elul, Tishrei, Cheshvan, Kislev, Tevet, Shvat, Adar, AdarII
}

enum SecularMonth: Int {
    case January = 1, February, March, April, May, June, July, August, September, October, November, December
}


/* Number of days in a Hebrew month */
private func getHebrewMonthLength(year: Int, month: Int) -> Int {
    let hebrewMonth = HebrewMonth(rawValue: month)
    switch (hebrewMonth!) {
    case .Tishrei,  .Shvat,  .Nissan, .Sivan, .Ab:
        return 30
        
    case .Tevet, .Iyar, .Tamuz, .Elul, .AdarII:
        return 29
        
    case .Cheshvan:
        // 29 days, unless it's a long year.
        return Kvia(forHebrewYear: year) == .long ? 30 : 29
        
    case .Kislev:
        // 30 days, unless it's a short year.
        return Kvia(forHebrewYear: year) == .short ? 29 : 30
        
    case .Adar:
        // Adar (non-leap year) has 29 days.  Adar I has 30 days.
        return isHebrewLeapYear(year) ? 30 : 29
    }
}

/* Number of days in a Julian or gregorian month */
private func getSecularMonthLength(year: Int, month: Int, isJulian: Bool) -> Int {
    let secularMonth = SecularMonth(rawValue: month)
    switch(secularMonth!) {
    case .January, .March, .May, .July, .August, .October, .December:
        return 31
    case .April, .June, .September, .November:
        return 30
    case .February:
        return isSecularLeapYear(year, isJulian) ? 29 : 28
    }
}

/* Is it a leap year in the gregorian/julian calendar? */
func isSecularLeapYear(_ year: Int, _ isJulian: Bool) -> Bool {
    if ((year % 4) != 0) {
        return false
    }
    if (isJulian || (year % 400) == 0) {
        return true
    }
    if ((year % 100) == 0) {
        return false
    }
    return true
}

/* Is it a leap year in the Jewish Calendar */
func isHebrewLeapYear(_ year: Int) -> Bool {
    switch (year % 19) {
    case 0, 3, 6, 8, 11, 14, 17:
        return true
    default:
        return false
    }
}

/* Return the number of days from 1 Tishrei 0001 to the beginning of the given year.
 * Since this routine gets called frequently with the same year arguments, we cache
 * the most recent values.
 */
var hebrew_elapsed_days_cache = [Int: Int]()
    
private func hebrew_elapsed_days(_ year: Int) -> Int {
    if let result = hebrew_elapsed_days_cache[year] {
        return result
    }
    let prev_year = year - 1
    let months_elapsed = 235 * (prev_year / 19)      /* months in complete cycles so far */
             + 12 * (prev_year % 19)   /* regular months in this cycle */
             + (((prev_year % 19) * 7 + 1) / 19) /* leap months this cycle */
    let parts_elapsed = 5604 + 13753 * months_elapsed
    let day = 1 + 29 * months_elapsed + parts_elapsed / 25920
    let parts = parts_elapsed % 25920
    let weekday = (day % 7)
    var actualDay = ((parts >= 19440)
          || (weekday == 2 && (parts >= 9924) && !isHebrewLeapYear(year))
          || (weekday == 1 && (parts >= 16789) && isHebrewLeapYear(prev_year))) ? day + 1 : day
    switch (actualDay % 7) {
    case 0, 3, 5:
        actualDay += 1
    default:
        break
    }
    hebrew_elapsed_days_cache[year] = actualDay
    return actualDay
}

/* Number of days in the given Hebrew year */
private func hebrew_year_length(_ year: Int) -> Int {
    return hebrew_elapsed_days(1 + year) - hebrew_elapsed_days(year)
}

/* Return today's date. */
func todaysYearMonthDay(isJulian: Bool) -> YearMonthDay {
    let calendar = Calendar.init(identifier: .gregorian)
    let components = calendar.dateComponents([.year, .month, .day], from: Date())
    let year = components.value(for: .year)!
    let month = components.value(for: .month)!
    let day = components.value(for: .day)!
    if isJulian {
        let absolute = absoluteFromSecular(year, month, day, false)
        return secularFromAbsolute(absolute, true)
    } else {
        return YearMonthDay(year: year, month: month, day: day)
    }
}

struct DateResult {
    let hebrewYear : Int
    let hebrewMonth : Int
    let hebrewDay : Int
    let secularYear: Int
    let secularMonth: Int
    let secularDay: Int
    let absolute: Int
    
    let hebrewMonthLength, secularMonthLength : Int
    let hebrew_leap_year_p, secular_leap_year_p : Bool
    let kvia : Kvia
    let hebrewDayNumber : Int
    
    init(fromSecularYear year: Int, month: Int, day: Int, isJulian: Bool) {
        let absolute = absoluteFromSecular(year, month, day, isJulian)
        let hebrewDate = hebrewFromAbsolute(absolute)
        let secularDate = YearMonthDay(year: year, month: month, day: day)
        self.init(hebrewDate: hebrewDate, secularDate: secularDate, absolute: absolute, isJulian: isJulian)
    }
    
    init(fromAbsolute absolute: Int, isJulian: Bool) {
        let hebrewDate = hebrewFromAbsolute(absolute)
        let secularDate = secularFromAbsolute(absolute, isJulian)
        self.init(hebrewDate: hebrewDate, secularDate: secularDate, absolute: absolute, isJulian: isJulian)
    }
    
    init(hebrewDate: YearMonthDay, secularDate: YearMonthDay, absolute xabsolute: Int, isJulian: Bool) {
        hebrewYear = hebrewDate.year
        hebrewMonth = hebrewDate.month
        hebrewDay = hebrewDate.day
        secularYear = secularDate.year
        secularMonth = secularDate.month
        secularDay = secularDate.day
        absolute = xabsolute
        hebrewMonthLength = getHebrewMonthLength(year: hebrewDate.year, month: hebrewDate.month)
        secularMonthLength = getSecularMonthLength(year: secularDate.year, month: secularDate.month, isJulian: isJulian)
        hebrew_leap_year_p = isHebrewLeapYear(hebrewDate.year)
        secular_leap_year_p = isSecularLeapYear(secularDate.year, isJulian)
        kvia = Kvia(forHebrewYear: hebrewYear)
        hebrewDayNumber = absolute - absoluteFromHebrew(hebrewYear, 7, 1) + 1
    }
}
