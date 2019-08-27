// CalendarViewDataModel.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// This class encapsulates all the data that is needed by the CalendarView to generate the
/// information that is viewed on the screen

class CalendarViewDataModel {
  let inIsrael = Preference.inIsrael.get()
  let showParsha = Preference.showParsha.get()
  let showChol = Preference.showCholHamoed.get()
  let showOmer = Preference.showOmer.get()
  let calendar = SecularCalendar.forUsingJulian(Preference.useJulian.get())

  /// The yerar being displayed
  let currentYear: Int

  /// The month being displayed
  let currentMonth: Int

  /// A lazily calculated of DateResult values for the entire secular month
  lazy var dateResultMonthArray: [DateResult] = {
    var result = DateResult(fromSecularYear: currentYear, month: currentMonth, day: 1, calendar: calendar)
    return (1...result.secularMonthLength).map { currentDay in
      if currentDay > 1 {
        result = result.next()
      }
      assert((currentYear, currentMonth, currentDay) ==
        (result.secularYear, result.secularMonth, result.secularDay))
      return result
    }
  }()

  init(year: Int, month: Int) {
    self.currentYear = year
    self.currentMonth = month
  }

  /// Get the holidays for the specified date, using the flags with which we were created
  func getHolidaysFor(dateResult: DateResult) -> [String] {
    return FindHolidays(
      fromDateResult: dateResult,
      inIsrael: inIsrael, showParsha: showParsha, showOmer: showOmer, showChol: showChol)
  }

  /// Get today, given the current claendar
  func getToday() -> YearMonthDay {
    return todaysYearMonthDay(calendar)
  }
}
