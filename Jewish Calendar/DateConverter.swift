// DateConverter.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

typealias YearMonthDay = (year: Int, month: Int, day: Int)

class SecularCalendar {
  private class Constants {
    // For each year type, the length of each month.  January is at index 1
    static let secularMonthLengths365 = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    static let secularMonthLengths366 = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    // For non leap years, the total number of days in all preceding months.  January is at index 1
    static let totalSecularMonths365 = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
  }

  static let julian = SecularCalendar(useJulian: true)
  static let gregorian = SecularCalendar(useJulian: false)

  static func forUsingJulian(_ useJulian: Bool) -> SecularCalendar {
    return useJulian ? julian : gregorian
  }

  let useJulian: Bool

  init(useJulian: Bool) {
    self.useJulian = useJulian
  }

  func firstOfYear(_ year: Int) -> Int {
    let xyear = year - 1
    var startOfYear = 365 * xyear + (xyear / 4)
    if useJulian {
      startOfYear -= 2
    } else {
      startOfYear += (xyear / 400) - (xyear / 100)
    }
    return startOfYear + 1
  }

  func toAbsolute(_ year: Int, _ month: Int, _ day: Int) -> Int {
    let dayOfYear = day + Constants.totalSecularMonths365[month] +
      (month > 2 && isLeapYear(year: year) ? 1 : 0)
    return firstOfYear(year) + dayOfYear - 1
  }

  /* Given an absolute date, calculate the secular date */
  func fromAbsolute(_ absolute: Int) -> YearMonthDay {
    var year = absolute / 366
    var length = getYearLength(year: year)
    var day = absolute - firstOfYear(year) + 1
    while day > length {
      day -= length
      year += 1
      length = getYearLength(year: year)
    }
    let monthLengths = getMonthLengths(yearLength: length)
    var month = 1
    while day > monthLengths[month] {
      day -= monthLengths[month]
      month += 1
    }
    return (year: year, month: month, day: day)
  }

  /* Number of days in a Julian or gregorian month */
  fileprivate func getMonthLengths(year: Int) -> [Int] {
    return getMonthLengths(yearLength: getYearLength(year: year))
  }

  /* Number of days in a Julian or gregorian month */
  fileprivate func getMonthLengths(yearLength: Int) -> [Int] {
    switch  yearLength {
    case 365: return Constants.secularMonthLengths365
    case 366: return Constants.secularMonthLengths366
    default: preconditionFailure("Bad month length")
    }
  }

  /* Is it a leap year in the gregorian/julian calendar? */
  private func isLeapYear(year: Int) -> Bool {
    if (year % 4) != 0 {
      return false
    }
    if useJulian || (year % 400) == 0 {
      return true
    }
    if (year % 100) == 0 {
      return false
    }
    return true
  }

  private func getYearLength(year: Int) -> Int {
    return isLeapYear(year: year) ? 366 : 365
  }
}

class HebrewCalendar {
  private class Constants {
    // For each year type, the length of the month
    static let hebrewMonthLengths353 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 29, 29, 30, 29]
    static let hebrewMonthLengths354 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29]
    static let hebrewMonthLengths355 = [0, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 30, 29]
    static let hebrewMonthLengths383 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 29, 29, 30, 30, 29]
    static let hebrewMonthLengths384 = [0, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 30, 29]
    static let hebrewMonthLengths385 = [0, 30, 29, 30, 29, 30, 29, 30, 30, 30, 29, 30, 30, 29]

    // For each year type, the total number of days in all preceding months.  (Starting at Tishri)
    static let totalHebrewMonths353 = [0, 176, 206, 235, 265, 294, 324, 0, 30, 59, 88, 117, 147]
    static let totalHebrewMonths354 = [0, 177, 207, 236, 266, 295, 325, 0, 30, 59, 89, 118, 148]
    static let totalHebrewMonths355 = [0, 178, 208, 237, 267, 296, 326, 0, 30, 60, 90, 119, 149]
    static let totalHebrewMonths383 = [0, 206, 236, 265, 295, 324, 354, 0, 30, 59, 88, 117, 147, 177]
    static let totalHebrewMonths384 = [0, 207, 237, 266, 296, 325, 355, 0, 30, 59, 89, 118, 148, 178]
    static let totalHebrewMonths385 = [0, 208, 238, 267, 297, 326, 356, 0, 30, 60, 90, 119, 149, 179]

    static let partsPerDay = 25920
    static let initialParts = 1 * partsPerDay + 5604
    static let partsPerMonth = 29 * partsPerDay + 13753
  }

  static let shared = HebrewCalendar()

  /* Given a Hebrew date, calculate the absolute date. */
  func toAbsolute(_ year: Int, _ month: Int, _ day: Int) -> Int {
    let yearLength = getYearLength(year: year)
    let cumulativeMonthLengths = getCumulativeMonthLengths(yearLength: yearLength)
    return firstOfYear(year) + cumulativeMonthLengths[month] + day - 1
  }

  /* Given an absolute date, calculate the Hebrew date. */
  func fromAbsolute(_ absolute: Int) -> YearMonthDay {
    var year = absolute / 366 + 3760
    var thisYearStart = firstOfYear(year)
    var nextYearStart = firstOfYear(year + 1)
    while absolute >= nextYearStart {
      thisYearStart = nextYearStart
      year += 1
      nextYearStart = firstOfYear(year + 1)
    }
    let yearLength = nextYearStart - thisYearStart
    var day = absolute - thisYearStart + 1
    let monthLengths = getMonthLengths(yearLength: yearLength)
    let monthCount = monthLengths.count - 1 // monthLengths is padded with an extra 0 at the beginning
    var month = 7
    while day > monthLengths[month] {
      day -= monthLengths[month]
      month = month == monthCount ? 1 : month + 1
    }
    return (year: year, month: month, day: day)
  }

  /* Return the number of days from 1 Tishrei 0001 to the beginning of the given year.
   * Since this routine gets called frequently with the same year arguments, we cache
   * the most recent values.
   */
  static var roshHashanahCache = [Int: Int]()
  static var cache_hit = 0
  static var cache_miss = 0

  func firstOfYear(_ year: Int) -> Int {
    if let result = HebrewCalendar.roshHashanahCache[year] {
      HebrewCalendar.cache_hit += 1
      return result
    }
    HebrewCalendar.cache_miss += 1
    let previousYear = year - 1
    let monthsElapsed = 235 * (previousYear / 19) /* months in complete cycles so far */
      + 12 * (previousYear % 19) /* regular months in this cycle */
      + (((previousYear % 19) * 7 + 1) / 19) /* leap months this cycle */
    let partsElapsed = Constants.initialParts + Constants.partsPerMonth * monthsElapsed
    let (day, parts) = partsElapsed.quotientAndRemainder(dividingBy: Constants.partsPerDay)
    var absolute = day - 1373428
    var weekday = DayOfWeek(from_absolute: absolute)

    if (parts >= 19440)
      || (weekday == .Tuesday && (parts >= 9924) && !isLeapYear(year: year))
      || (weekday == .Monday && (parts >= 16789) && isLeapYear(year: previousYear)) {
      absolute += 1
      weekday = weekday + 1
    }
    if weekday == .Sunday || weekday == .Wednesday || weekday == .Friday {
      absolute += 1
    }
    HebrewCalendar.roshHashanahCache[year] = absolute
    return absolute
  }

  /* Number of days in the given Hebrew year */
  fileprivate func getYearLength(year: Int) -> Int {
    return firstOfYear(year + 1) - firstOfYear(year)
  }

  /* Number of days in a Hebrew month */
  fileprivate func getMonthLengths(yearLength: Int) -> [Int] {
    switch yearLength {
      case 353: return Constants.hebrewMonthLengths353
      case 354: return Constants.hebrewMonthLengths354
      case 355: return Constants.hebrewMonthLengths355
      case 383: return Constants.hebrewMonthLengths383
      case 384: return Constants.hebrewMonthLengths384
      case 385: return Constants.hebrewMonthLengths385
      default: preconditionFailure("Bad hebrew year length")
    }
  }

  fileprivate func getCumulativeMonthLengths(yearLength: Int) -> [Int] {
    switch yearLength {
      case 353: return Constants.totalHebrewMonths353
      case 354: return Constants.totalHebrewMonths354
      case 355: return Constants.totalHebrewMonths355
      case 383: return Constants.totalHebrewMonths383
      case 384: return Constants.totalHebrewMonths384
      case 385: return Constants.totalHebrewMonths385
      default: preconditionFailure("Bad hebrew year length")
    }
  }

  /* Is it a leap year in the Jewish Calendar */
  private func isLeapYear(year: Int) -> Bool {
    switch year % 19 {
      case 0, 3, 6, 8, 11, 14, 17:
        return true
      default:
        return false
    }
  }
}

/* Return today's date. */
func todaysYearMonthDay(_ secularCalendar: SecularCalendar) -> YearMonthDay {
  let calendar = Calendar(identifier: .gregorian)
  let components = calendar.dateComponents([.year, .month, .day], from: Date())
  let year = components.value(for: .year)!
  let month = components.value(for: .month)!
  let day = components.value(for: .day)!
  if secularCalendar.useJulian {
    let absolute = SecularCalendar.gregorian.toAbsolute(year, month, day)
    return SecularCalendar.julian.fromAbsolute(absolute)
  } else {
    return (year: year, month: month, day: day)
  }
}

struct DateResult {
  let hebrewYear, hebrewMonth, hebrewDay, hebrewMonthLength, hebrewYearLength: Int
  let secularYear, secularMonth, secularDay, secularMonthLength: Int

  let calendar: SecularCalendar
  let absolute: Int

  init(fromSecularYear year: Int, month: Int, day: Int, calendar: SecularCalendar) {
    let absolute = calendar.toAbsolute(year, month, day)
    let hebrewDate = HebrewCalendar.shared.fromAbsolute(absolute)
    let secularDate = (year: year, month: month, day: day)
    self.init(hebrewDate: hebrewDate, secularDate: secularDate, absolute: absolute, calendar: calendar)
  }

  init(fromAbsolute absolute: Int, calendar: SecularCalendar) {
    let hebrewDate = HebrewCalendar.shared.fromAbsolute(absolute)
    let secularDate = calendar.fromAbsolute(absolute)
    self.init(hebrewDate: hebrewDate, secularDate: secularDate, absolute: absolute, calendar: calendar)
  }

  func next() -> DateResult {
    if hebrewDay < hebrewMonthLength, secularDay < secularMonthLength {
      return DateResult(dateResult: self, offset: 1)
    } else {
      return DateResult(fromAbsolute: absolute + 1, calendar: calendar)
    }
  }

  var isHebrewLeapYear: Bool {
    return hebrewYearLength > 360
  }

  var isHebrewShortYear: Bool {
    return hebrewYearLength % 10 == 3
  }

  var dayOfWeek: DayOfWeek {
    return DayOfWeek(from_absolute: absolute)
  }

  var hebrewDayNumber: Int {
    let hebrewCalendar = HebrewCalendar.shared
    return hebrewCalendar.getCumulativeMonthLengths(yearLength: hebrewYearLength)[hebrewMonth] + hebrewDay
  }

  private init(
    hebrewDate: YearMonthDay, secularDate: YearMonthDay, absolute: Int,
    calendar: SecularCalendar) {
    let hebrewCalendar = HebrewCalendar.shared

    self.hebrewYear = hebrewDate.year
    self.hebrewMonth = hebrewDate.month
    self.hebrewDay = hebrewDate.day
    self.hebrewYearLength = hebrewCalendar.getYearLength(year: hebrewYear)
    self.hebrewMonthLength = hebrewCalendar.getMonthLengths(yearLength: hebrewYearLength)[hebrewDate.month]

    self.secularYear = secularDate.year
    self.secularMonth = secularDate.month
    self.secularDay = secularDate.day
    self.secularMonthLength = calendar.getMonthLengths(year: secularDate.year)[secularDate.month]

    self.absolute = absolute
    self.calendar = calendar
  }

  private init(dateResult: DateResult, offset: Int = 1) {
    assert(dateResult.hebrewDay + offset <= dateResult.hebrewMonthLength)
    assert(dateResult.secularDay + offset <= dateResult.secularMonthLength)

    self.hebrewYear = dateResult.hebrewYear
    self.hebrewMonth = dateResult.hebrewMonth
    self.hebrewDay = dateResult.hebrewDay + offset
    self.hebrewYearLength = dateResult.hebrewYearLength
    self.hebrewMonthLength = dateResult.hebrewMonthLength

    self.secularYear = dateResult.secularYear
    self.secularMonth = dateResult.secularMonth
    self.secularDay = dateResult.secularDay + offset
    self.secularMonthLength = dateResult.secularMonthLength

    self.absolute = dateResult.absolute + offset
    self.calendar = dateResult.calendar
  }
}
