// Holidays.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// Given a day of the Hebrew month, figuring out all the interesting holidays
/// that correspond to that date.  ParshaP, OmerP, and CholP determine whether
/// we should given info about the Parsha of the week, the Sfira, or Chol Hamoed.
///
/// We are also influenced by the IsraelP flag

/// An enumeration to determine that specifies the day of the week.
/// It understands the "absolute" value of DateConverter.swift, and can convert an absolute
/// value into the appropriate week day
enum DayOfWeek: Int {
  init(from_absolute absolute: Int) {
    let offset = absolute % 7
    self = DayOfWeek(rawValue: offset >= 0 ? offset : offset + 7)!
  }

  case Sunday = 0, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

  static func + (day: DayOfWeek, days: Int) -> DayOfWeek {
    return DayOfWeek(from_absolute: day.rawValue + days)
  }

  static func - (day: DayOfWeek, days: Int) -> DayOfWeek {
    return DayOfWeek(from_absolute: day.rawValue - days)
  }
}

func FindHolidays(
  fromDateResult dr: DateResult,
  inIsrael: Bool,
  showParsha: Bool,
  showOmer: Bool,
  showChol: Bool) -> [String] {
  // Get the day of the week and other information
  let dayOfWeek = dr.dayOfWeek
  let isShabbat = (dayOfWeek == .Saturday) // Is it a Saturday?
  let isLeapYear = dr.isHebrewLeapYear
  let isShortYear = dr.isHebrewShortYear

  // Pull out date information for the date result structure, but treat Adar in a non-leap
  // year as if it were Adar II
  let (year, _month, day) = (dr.hebrewYear, dr.hebrewMonth, dr.hebrewDay)
  let month = ((_month == 12) && !isLeapYear) ? 13 : _month

  var holidays = [String]()

  switch (month, day) {
    /* Nissan */
    case (1, 14):
      holidays.append("Erev Pesach")
      fallthrough
    case (1, 8...13):
      // The Saturday before Pesach (8th-14th)
      if isShabbat {
        holidays.append("Sh. HaGadol")
      }

    case (1, 15...22):
      if day == 15 || day == 21 || (!inIsrael && (day == 16 || day == 22)) {
        holidays.append("Pesach")
      } else if inIsrael, day == 22 {
        // donothing
      } else {
        if showChol {
          holidays.append("Chol Hamoed")
        }
      }

    case (1, 27...28):
      // Yom HaShoah only exists since Israel was established.
      // If it falls on Sunday (e.g. 1997) it's bumped to Monday, but only since 97/03/20.
      if isYomHashoah(year, day, dayOfWeek) {
        holidays.append("Yom HaShoah")
      }

    /* Iyar */
    case (2, 2...6):
      // Yom HaAtzmaut is on the 5th, unless that's a Saturday, in which
      // case it is moved forward two days to Thursday, and unless that's
      // a Friday in which case it is moved forward one day to Thursday.
      // Yom HaZikaron is the day before Yom HaAtzmaut.
      // In 2004 the law changed so that if the 5th is a Monday, Yom
      // Hazikaron gets moved backward to Tuesday.
      // http://www.hebcal.com/home/150/yom_haatzmaut_yom_hazikaron_2007
      if let yomHatzmaut = getYomHaAtzmaut(year: year, month: month, day: day, dayOfWeek: dayOfWeek) {
        if day == yomHatzmaut - 1 {
          holidays.append("Yom HaZikaron")
        } else if day == yomHatzmaut {
          holidays.append("Yom HaAtzmaut")
        }
      }

    case (2, 18):
      holidays.append("Lag BaOmer")

    case (2, 28):
      // only since the 1967 war
      if year > 1967 + 3760 {
        holidays.append("Yom Yerushalayim")
      }

    /* Sivan */
    case (3, 5):
      holidays.append("Erev Shavuot")

    case (3, 6...7):
      if !inIsrael || (day == 6) {
        holidays.append("Shavuot")
      }

    /* Tamuz */
    case (4, 17...18):
      // 17th of Tamuz, except Shabbat pushes it to Sunday.
      if (!isShabbat && (day == 17)) || ((dayOfWeek == .Sunday) && (day == 18)) {
        holidays.append("Tzom Tamuz")
      }

    /* Ab */
    case (5, 3...16):
      if isShabbat && (day >= 3) && (day <= 16) {
        // The shabbat before and after Tisha B'Av are special
        holidays.append((day <= 9) ? "Sh. Hazon" : "Sh. Nahamu")
      } else if (!isShabbat && (day == 9)) || ((dayOfWeek == .Sunday) && (day == 10)) {
        // 9th of Av, except Shabbat pushes it to Sunday.
        holidays.append("Tisha B'Av")
      }

    /* Elul */
    case (6, 20...26):
      if isShabbat {
        holidays.append("S'lichot (evening)")
      }

    case (6, 29):
      holidays.append("Erev R.H.")

    /* Tishrei */
    case (7, 1...2):
      holidays.append("Rosh Hashonah")

    case (7, 3):
      holidays.append(isShabbat ? "Sh. Shuvah" : "Tzom Gedaliah")

    case (7, 4):
      if dayOfWeek == .Sunday {
        holidays.append("Tzom Gedliah")
      }
      fallthrough
    case (7, 5...8):
      if isShabbat {
        holidays.append("Sh. Shuvah")
      }
    case (7, 9):
      holidays.append("Erev Y.K.")

    case (7, 10):
      holidays.append("Yom Kippur")

    case (7, 14):
      holidays.append("Erev Sukkot")

    case (7, 15...16):
      if !inIsrael || (day == 15) {
        holidays.append("Sukkot")
        break
      }
      fallthrough

    case (7, 17...20):
      if showChol {
        holidays.append("Chol Hamoed")
      }

    case (7, 21):
      holidays.append("Hoshanah Rabah")

    case (7, 22):
      holidays.append("Shmini Atzeret")

    case (7, 23):
      if !inIsrael {
        holidays.append("Simchat Torah")
      }

    /* Cheshvan */
    case (9, 24):
      holidays.append("Erev Hanukah")

    case (9, 25...30):
      holidays.append("Hanukah")

    /* Kislev */
    case (10, 1...2):
      holidays.append("Hanukah")

    case (10, 3):
      if isShortYear {
        holidays.append("Hanukah")
      }

    case (10, 10...11):
      if ((day == 10) && !isShabbat) || ((day == 11) && (dayOfWeek == .Sunday)) {
        // 10th of Tevet.  Shabbat pushes it to Sunday
        holidays.append("Tzom Tevet")
      }

    /* Shvat */
    case (11, 11...16):
      if isShabbat {
        holidays.append("Sh. Shirah")
      }
      if day == 15 {
        holidays.append("Tu B'Shvat")
      }
    case (11, 10), (11, 17):
      if isShabbat, day == (isShortYear ? 17 : 10) {
        holidays.append("Sh. Shirah")
      }
    case (11, 25...30):
      // The last shabbat on or before 1 Adar or 1 AdarII
      if isShabbat, !isLeapYear {
        holidays.append("Sh. Shekalim")
      }

    /* Adar I */
    case (12, 14):
      holidays.append("Purim Katan")
    case (12, 25...30), (13, 1):
      if isShabbat {
        holidays.append("Sh. Shekalim")
      }

    /* Adar II */
    case (13, 7...13):
      if (day == 11 && dayOfWeek == .Thursday) || (day == 13 && !isShabbat) {
        holidays.append("Ta'anit Ester")
      }
      if isShabbat {
        holidays.append("Sh. Zachor")
      }
      if day == 13 {
        holidays.append("Erev Purim")
      }

    case (13, 14):
      // Tuesday, Thursday, Friday, or Sunday
      holidays.append("Purim")

    case (13, 15):
      if !isShabbat {
        holidays.append("Shushan Purim")
      }

    case (13, 16):
      if dayOfWeek == .Sunday {
        holidays.append("Shushan Purim")
      }

    case (13, 17...23):
      if isShabbat {
        holidays.append("Sh. Parah")
      }

    case (13, 24...29), (1, 1):
      if isShabbat {
        holidays.append("Sh. HaHodesh")
      }

    default:
      break
  }

  if showOmer {
    var dayOfOmer: Int?
    switch (month, day) {
      case (1, 16...30): dayOfOmer = day - 15
      case (2, _): dayOfOmer = day + 15
      case (3, 1...5): dayOfOmer = day + 44
      default:
        break
    }
    if let dayOfOmer = dayOfOmer, dayOfOmer != 33 {
      let formatter = NumberFormatter()
      formatter.numberStyle = .ordinal
      let omer = formatter.string(from: NSNumber(value: dayOfOmer))! + " day Omer"
      holidays.append(omer)
    }
  }

  if isShabbat, showParsha {
    // Find the Parsha on Shabbat.
    if let parsha = findParshaName(dr.hebrewDayNumber, dr.hebrewYearLength, inIsrael) {
      holidays.append(parsha)
    }
  }
  return holidays
}

private func isYomHashoah(_ year: Int, _ day: Int, _ dayOfWeek: DayOfWeek) -> Bool {
  // Yom HaShoah only exists since Israel was established.
  // If it falls on Sunday (e.g. 1997) it's bumped to Monday, but only since 97/03/20.
  // When this is called, day will always be 27 or 28,
  if year > 1948 + 3760 {
    if year >= 1997 + 3760 {
      switch dayOfWeek {
        case .Sunday:
          return false
        case .Monday:
          return true // either Monday 27 or bumped from Sunday 27.
        default:
          return day == 27
      }
    } else {
      return day == 27
    }
  }
  return false
}

private func getYomHaAtzmaut(year: Int, month: Int, day: Int, dayOfWeek: DayOfWeek) -> Int? {
  if year < 1948 + 3760 {
    return nil
  }
  assert(month == 2 && (2...6).contains(day))
  // Yom HaAtzmaut is on the 5th, unless that's a Saturday, in which
  // case it is moved forward two days to Thursday, and unless that's
  // a Friday in which case it is moved forward one day to Thursday.
  // Yom HaZikaron is the day before Yom HaAtzmaut.
  // In 2004 the law changed so that if the 5th is a Monday, Yom
  // Hazikaron gets moved backward to Tuesday.
  // http://www.hebcal.com/home/150/yom_haatzmaut_yom_hazikaron_2007

  // <Yom HaZikaron> [Yom HaAtzmaut]
  //   2     3     4     5     6
  //  Fri   Sat  <Sun> [Mon]  Tue  // < 2004
  //  Fri   Sat   Sun  <Mon> [Tue] // >= 2004
  // -Sat---Sun---Mon---Tue---Wed- // does not occur
  //  Sun   Mon  <Tue> [Wed]  Thu
  // -Mon---Tue---Wed---Thu---Fri- // does not occur
  //  Tue  <Wed> [Thu]  Fri   Sat
  // <Wed> [Thu]  Fri   Sat   Sun
  // -Thu---Fri---Sat---Sun---Mon- // does not occur
  let weekdayOfTheSixth = dayOfWeek + (6 - day)
  switch weekdayOfTheSixth {
    case .Sunday:
      return 3
    case .Saturday:
      return 4
    case .Thursday:
      return 5
    case .Tuesday:
      return year < 2004 + 3760 ? 5 : 6
    default:
      return nil
  }
}
