// Holidays.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// The user's choices about which optional items to show on the calendar.
struct HolidayOptions: Sendable {
    var inIsrael = false
    var showParsha = true
    var showOmer = true
    var showCholHamoed = true
}

extension CalendarDay {
    /// All the interesting holidays that fall on this day.  The result depends on
    /// whether we are in Israel, and on whether the user wants to see the parsha
    /// of the week, the Omer count, and Chol Hamoed.
    ///
    /// Note: a few spellings below ("Rosh Hashonah", "Tzom Gedliah") are preserved
    /// exactly as they have always appeared, since the golden test file locks them in.
    func holidays(_ options: HolidayOptions) -> [String] {
        let isShabbat = weekday == .saturday
        let isLeapYear = hebrewYear.isLeap
        let year = hebrewDate.year
        let day = hebrewDate.day

        // In a non-leap year, the single month of Adar follows the rules of Adar II.
        let month: HebrewMonth = (hebrewDate.month == .adarI && !isLeapYear) ? .adarII : hebrewDate.month

        var holidays = [String]()

        switch (month, day) {
            /* Nisan */
            case (.nisan, 14):
                holidays.append("Erev Pesach")
                fallthrough
            case (.nisan, 8...13):
                // The Saturday before Pesach (8th-14th)
                if isShabbat {
                    holidays.append("Sh. HaGadol")
                }

            case (.nisan, 15...22):
                if day == 15 || day == 21 || (!options.inIsrael && (day == 16 || day == 22)) {
                    holidays.append("Pesach")
                } else if !(options.inIsrael && day == 22), options.showCholHamoed {
                    holidays.append("Chol Hamoed")
                }

            case (.nisan, 27...28):
                if isYomHaShoah() {
                    holidays.append("Yom HaShoah")
                }

            /* Iyar */
            case (.iyar, 2...6):
                if let yomHaAtzmaut = yomHaAtzmautDayOfIyar() {
                    if day == yomHaAtzmaut - 1 {
                        holidays.append("Yom HaZikaron")
                    } else if day == yomHaAtzmaut {
                        holidays.append("Yom HaAtzmaut")
                    }
                }

            case (.iyar, 18):
                holidays.append("Lag BaOmer")

            case (.iyar, 28):
                // Only since the 1967 war
                if year > 1967 + 3760 {
                    holidays.append("Yom Yerushalayim")
                }

            /* Sivan */
            case (.sivan, 5):
                holidays.append("Erev Shavuot")

            case (.sivan, 6...7):
                if !options.inIsrael || day == 6 {
                    holidays.append("Shavuot")
                }

            /* Tammuz */
            case (.tammuz, 17...18):
                // 17th of Tammuz, except Shabbat pushes it to Sunday.
                if (!isShabbat && day == 17) || (weekday == .sunday && day == 18) {
                    holidays.append("Tzom Tamuz")
                }

            /* Av */
            case (.av, 3...16):
                if isShabbat {
                    // The Shabbat before and after Tisha B'Av are special
                    holidays.append(day <= 9 ? "Sh. Hazon" : "Sh. Nahamu")
                } else if day == 9 || (weekday == .sunday && day == 10) {
                    // 9th of Av, except Shabbat pushes it to Sunday.
                    holidays.append("Tisha B'Av")
                }

            /* Elul */
            case (.elul, 20...26):
                if isShabbat {
                    holidays.append("S'lichot (evening)")
                }

            case (.elul, 29):
                holidays.append("Erev R.H.")

            /* Tishrei */
            case (.tishrei, 1...2):
                holidays.append("Rosh Hashonah")

            case (.tishrei, 3):
                holidays.append(isShabbat ? "Sh. Shuvah" : "Tzom Gedaliah")

            case (.tishrei, 4):
                if weekday == .sunday {
                    holidays.append("Tzom Gedliah") // [sic]
                }
                fallthrough
            case (.tishrei, 5...8):
                if isShabbat {
                    holidays.append("Sh. Shuvah")
                }

            case (.tishrei, 9):
                holidays.append("Erev Y.K.")

            case (.tishrei, 10):
                holidays.append("Yom Kippur")

            case (.tishrei, 14):
                holidays.append("Erev Sukkot")

            case (.tishrei, 15...16):
                if !options.inIsrael || day == 15 {
                    holidays.append("Sukkot")
                    break
                }
                fallthrough
            case (.tishrei, 17...20):
                if options.showCholHamoed {
                    holidays.append("Chol Hamoed")
                }

            case (.tishrei, 21):
                holidays.append("Hoshanah Rabah")

            case (.tishrei, 22):
                holidays.append("Shmini Atzeret")

            case (.tishrei, 23):
                if !options.inIsrael {
                    holidays.append("Simchat Torah")
                }

            /* Kislev */
            case (.kislev, 24):
                holidays.append("Erev Hanukah")

            case (.kislev, 25...30):
                holidays.append("Hanukah")

            /* Tevet */
            case (.tevet, 1...2):
                holidays.append("Hanukah")

            case (.tevet, 3):
                // Hanukah has an eighth day here only if Kislev had 29 days.
                if hebrewYear.isDeficient {
                    holidays.append("Hanukah")
                }

            case (.tevet, 10...11):
                // 10th of Tevet.  Shabbat pushes it to Sunday.
                if (day == 10 && !isShabbat) || (day == 11 && weekday == .sunday) {
                    holidays.append("Tzom Tevet")
                }

            /* Shevat */
            case (.shevat, 11...16):
                if isShabbat {
                    holidays.append("Sh. Shirah")
                }
                if day == 15 {
                    holidays.append("Tu B'Shvat")
                }

            case (.shevat, 10), (.shevat, 17):
                if isShabbat, day == (hebrewYear.isDeficient ? 17 : 10) {
                    holidays.append("Sh. Shirah")
                }

            case (.shevat, 25...30):
                // The last Shabbat on or before 1 Adar
                if isShabbat, !isLeapYear {
                    holidays.append("Sh. Shekalim")
                }

            /* Adar I */
            case (.adarI, 14):
                holidays.append("Purim Katan")

            case (.adarI, 25...30), (.adarII, 1):
                // The last Shabbat on or before 1 Adar II
                if isShabbat {
                    holidays.append("Sh. Shekalim")
                }

            /* Adar II (or Adar in a non-leap year) */
            case (.adarII, 7...13):
                if (day == 11 && weekday == .thursday) || (day == 13 && !isShabbat) {
                    holidays.append("Ta'anit Ester")
                }
                if isShabbat {
                    holidays.append("Sh. Zachor")
                }
                if day == 13 {
                    holidays.append("Erev Purim")
                }

            case (.adarII, 14):
                // Tuesday, Thursday, Friday, or Sunday
                holidays.append("Purim")

            case (.adarII, 15):
                if !isShabbat {
                    holidays.append("Shushan Purim")
                }

            case (.adarII, 16):
                if weekday == .sunday {
                    holidays.append("Shushan Purim")
                }

            case (.adarII, 17...23):
                if isShabbat {
                    holidays.append("Sh. Parah")
                }

            case (.adarII, 24...29), (.nisan, 1):
                if isShabbat {
                    holidays.append("Sh. HaHodesh")
                }

            default:
                break
        }

        if options.showOmer, let dayOfOmer = dayOfOmer(month: month, day: day), dayOfOmer != 33 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            holidays.append(formatter.string(from: NSNumber(value: dayOfOmer))! + " day Omer")
        }

        if isShabbat, options.showParsha,
              let parsha = parshaName(
                  dayOfHebrewYear: dayOfHebrewYear, yearLength: hebrewYear.length,
                  inIsrael: options.inIsrael) {
            holidays.append(parsha)
        }

        return holidays
    }

    /// The day of the Omer count (1...49), if this day is part of it.
    private func dayOfOmer(month: HebrewMonth, day: Int) -> Int? {
        switch (month, day) {
            case (.nisan, 16...30): return day - 15
            case (.iyar, _): return day + 15
            case (.sivan, 1...5): return day + 44
            default: return nil
        }
    }

    /// Is this day (the 27th or 28th of Nisan) Yom HaShoah?
    private func isYomHaShoah() -> Bool {
        // Yom HaShoah only exists since Israel was established.
        // If it falls on Sunday (e.g. 1997) it's bumped to Monday, but only since 97/03/20.
        guard hebrewDate.year > 1948 + 3760 else { return false }
        guard hebrewDate.year >= 1997 + 3760 else { return hebrewDate.day == 27 }
        switch weekday {
            case .sunday: return false
            case .monday: return true // either Monday the 27th, or bumped from Sunday the 27th
            default: return hebrewDate.day == 27
        }
    }

    /// The day of Iyar on which Yom HaAtzmaut is celebrated this year, or nil if
    /// there is none.  Only meaningful when this day is the 2nd-6th of Iyar.
    private func yomHaAtzmautDayOfIyar() -> Int? {
        guard hebrewDate.year >= 1948 + 3760 else { return nil }
        // Yom HaAtzmaut is on the 5th, unless that's a Saturday, in which
        // case it is moved backward two days to Thursday, and unless that's
        // a Friday in which case it is moved backward one day to Thursday.
        // Yom HaZikaron is the day before Yom HaAtzmaut.
        // In 2004 the law changed so that if the 5th is a Monday, Yom
        // HaZikaron gets moved forward to Tuesday.
        // http://www.hebcal.com/home/150/yom_haatzmaut_yom_hazikaron_2007
        //
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
        let weekdayOfTheSixth = weekday + (6 - hebrewDate.day)
        switch weekdayOfTheSixth {
            case .sunday: return 3
            case .saturday: return 4
            case .thursday: return 5
            case .tuesday: return hebrewDate.year < 2004 + 3760 ? 5 : 6
            default: return nil
        }
    }
}
