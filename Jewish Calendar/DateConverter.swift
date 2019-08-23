//
//  dateConverter.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/7/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

struct YearMonthDay: Equatable {
    let year: Int
    let month: Int
    let day: Int
    
    func asTuple() -> (Int, Int, Int) {
        return (year, month, day)
    }
}

enum Kvia : Int {
    case short = 0
    case normal = 1
    case long = 2
    
    init(forHebrewYear year: Int) {
        let hebrewYearLength = yearLength(hebrewYear: year)
        assert((353...355).contains(hebrewYearLength) || (383...385).contains(hebrewYearLength))
        let raw = (hebrewYearLength % 10) - 3
        self.init(rawValue: raw)!
    }
}

private class Constants {
    // For each year type, the length of the month
    //                                     N   I   Si  Ta  Ab  E,  Ti  Ch  K   Te  Sh  Ad  A2
    static let hebrewMonthLengths353 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 29, 29, 30, 29]
    static let hebrewMonthLengths354 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29]
    static let hebrewMonthLengths355 = [0, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 30, 29]
    static let hebrewMonthLengths383 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 29, 29, 30, 30, 29]
    static let hebrewMonthLengths384 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29]
    static let hebrewMonthLengths385 = [0, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 30, 30, 29]
    
    // For each year type, the total number of days in all preceding months.  (Starting at Tishri)
    //                                      N    I   Si   Ta   Ab    E,  Ti Ch  K   Te  Sh   Ad   A2
    static let totalHebrewMonths353 =  [0, 176, 206, 235, 265, 294, 324, 0, 30, 59, 88, 117, 147]
    static let totalHebrewMonths354 =  [0, 177, 207, 236, 266, 295, 325, 0, 30, 59, 89, 118, 148]
    static let totalHebrewMonths355 =  [0, 178, 208, 237, 267, 296, 326, 0, 30, 60, 90, 119, 149]
    static let totalHebrewMonths383 =  [0, 206, 236, 265, 295, 324, 354, 0, 30, 59, 88, 117, 147, 177]
    static let totalHebrewMonths384 =  [0, 207, 237, 266, 296, 325, 355, 0, 30, 59, 89, 118, 148, 178]
    static let totalHebrewMonths385 =  [0, 208, 238, 267, 297, 326, 356, 0, 30, 60, 90, 119, 149, 179]
    
    // For each year type, the length of each month.  January is at index 1
    //                                      J   F   M   Ap  M   Ju  Ju  Au  S   O   N   D
    static let secularMonthLengths365 = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    static let secularMonthLengths366 = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    // For non leap years, the total number of days in all preceding months.  January is at index 1
    //                                     J  F   M   Ap   M   Ju   Ju   Au   S    O    N    D
    static let totalSecularMonths365 = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

}

/* Given a secular date, calculate the number of days since January 0, 0000 (Gregorian)
 */
func absoluteFromSecular(_ year: Int, _ month: Int, _ day: Int, _ isJulian: Bool) -> Int {
    let xyear = year - 1
    let dayOfYear = day + Constants.totalSecularMonths365[month] +
        (month > 2 && isLeapYear(secularYear: year, isJulian) ? 1 : 0)
    var startOfYear = 365 * xyear + (xyear / 4)
    if isJulian {
        startOfYear -= 2
    } else {
        startOfYear += (xyear / 400) - (xyear / 100)
    }
    return dayOfYear + startOfYear
}


/* Given a Hebrew date, calculate the number of days since
 * January 0, 0001, Gregorian
 */
func absoluteFromHebrew(_ year: Int, _ month: Int, _ day: Int) -> Int {
    let cumulativeMonthLengths = getCumulativeMonthLengths(hebrewYear: year)
    return hebrew_elapsed_days(year) + cumulativeMonthLengths[month] + day - 1373429
}


/* Given an absolute date, calculate the secular date */
func secularFromAbsolute(_ absolute: Int, _ isJulian: Bool) -> YearMonthDay {
    var year = absolute/366
    var length = yearLength(secularYear: year, isJulian: isJulian)
    var day = absolute - absoluteFromSecular(year, 1, 1, isJulian) + 1
    while day > length {
        day -= length
        year += 1
        length = yearLength(secularYear: year, isJulian: isJulian)
    }
    let monthLengths = getMonthLengths(secularYear: year, isJulian: isJulian)
    var month = 1
    while day > monthLengths[month] {
        day -= monthLengths[month]
        month += 1
    }
    return YearMonthDay(year: year, month: month, day: day)
}

/* Given an absolute date, calculate the Hebrew date */
private func hebrewFromAbsolute(_ absolute: Int) -> YearMonthDay {
    var year = absolute/366 + 3760
    var length = yearLength(hebrewYear: year)
    var day = absolute - absoluteFromHebrew(year, 7, 1) + 1
    while day > length {
        day -= length
        year += 1
        length = yearLength(hebrewYear: year)
    }
    let monthLengths = getMonthLengths(hebrewYear: year)
    let monthCount = monthLengths.count - 1  // monthLengths is padded with an extra 0 at the beginning
    var month = 7
    while day > monthLengths[month] {
        day -= monthLengths[month]
        month = month == monthCount ? 1 : month + 1
    }
    return YearMonthDay(year: year, month: month, day: day)
}

/* Number of months in a Hebrew year */
private func getHebrewMonthsInYear(_ year: Int) -> Int {
    return isLeapYear(hebrewYear: year) ? 13 : 12
}

/* Number of days in a Hebrew month */
private func getMonthLengths(hebrewYear year: Int) -> [Int] {
    switch (isLeapYear(hebrewYear: year), Kvia(forHebrewYear: year)) {
    case (false, .short):   return Constants.hebrewMonthLengths353
    case (false, .normal):  return Constants.hebrewMonthLengths354
    case (false, .long):    return Constants.hebrewMonthLengths355
    case (true,  .short):   return Constants.hebrewMonthLengths383
    case (true,  .normal):  return Constants.hebrewMonthLengths384
    case (true,  .long):    return Constants.hebrewMonthLengths385
    }
}

private func getCumulativeMonthLengths(hebrewYear year: Int) -> [Int] {
    switch (isLeapYear(hebrewYear: year), Kvia(forHebrewYear: year)) {
    case (false, .short):   return Constants.totalHebrewMonths353
    case (false, .normal):  return Constants.totalHebrewMonths354
    case (false, .long):    return Constants.totalHebrewMonths355
    case (true,  .short):   return Constants.totalHebrewMonths383
    case (true,  .normal):  return Constants.totalHebrewMonths384
    case (true,  .long):    return Constants.totalHebrewMonths385
    }
}
/* Number of days in a Julian or gregorian month */
private func getMonthLengths(secularYear year: Int, isJulian: Bool) -> [Int] {
    if isLeapYear(secularYear: year, isJulian) {
        return Constants.secularMonthLengths366
    } else {
        return Constants.secularMonthLengths365
    }
}


/* Is it a leap year in the gregorian/julian calendar? */
func isLeapYear(secularYear year: Int, _ isJulian: Bool) -> Bool {
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
func isLeapYear(hebrewYear year: Int) -> Bool {
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
var cache_hit = 0
var cache_miss = 0
    
private func hebrew_elapsed_days(_ year: Int) -> Int {
    if let result = hebrew_elapsed_days_cache[year] {
        cache_hit += 1
        return result
    }
    cache_miss += 1
    let prev_year = year - 1
    let months_elapsed = 235 * (prev_year / 19)      /* months in complete cycles so far */
             + 12 * (prev_year % 19)   /* regular months in this cycle */
             + (((prev_year % 19) * 7 + 1) / 19) /* leap months this cycle */
    let parts_elapsed = 5604 + 13753 * months_elapsed
    let day = 1 + 29 * months_elapsed + parts_elapsed / 25920
    let parts = parts_elapsed % 25920
    let weekday = (day % 7)
    var actualDay = ((parts >= 19440)
          || (weekday == 2 && (parts >= 9924) && !isLeapYear(hebrewYear: year))
          || (weekday == 1 && (parts >= 16789) && isLeapYear(hebrewYear: prev_year))) ? day + 1 : day
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
private func yearLength(hebrewYear year: Int) -> Int {
    return hebrew_elapsed_days(1 + year) - hebrew_elapsed_days(year)
}

private func yearLength(secularYear year: Int, isJulian: Bool) -> Int {
    return isLeapYear(secularYear: year, isJulian) ? 366 : 365
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
    let isHebrewLeapYear, isSecularLeapYear : Bool
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
        hebrewMonthLength = getMonthLengths(hebrewYear: hebrewDate.year)[hebrewDate.month]
        secularMonthLength = getMonthLengths(
            secularYear: secularDate.year, isJulian: isJulian)[secularDate.month]
        isHebrewLeapYear = isLeapYear(hebrewYear: hebrewDate.year)
        isSecularLeapYear = isLeapYear(secularYear: secularDate.year, isJulian)
        kvia = Kvia(forHebrewYear: hebrewYear)
        hebrewDayNumber = absolute - absoluteFromHebrew(hebrewYear, 7, 1) + 1
    }
}
