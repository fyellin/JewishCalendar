//
//  Holidays.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/7/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

/* Given a day of the Hebrew month, figuring out all the interesting holidays
 * that correspond to that date.  ParshaP, OmerP, and CholP determine whether
 * we should given info about the Parsha of the week, the Sfira, or Chol Hamoed.
 *
 * We are also influenced by the IsraelP flag
 */

enum DayOfWeek: Int {
    init(from_absolute absolute: Int) {
        let offset = (7 + absolute) % 7
        self = DayOfWeek(rawValue: offset)!
    }
    case Sunday = 0, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}


func FindHolidays(year: Int, month _month: Int, day: Int, absolute: Int,
                  kvia: Int, leap_year_p: Bool, day_number: Int,
                  inIsrael: Bool, showParsha: Bool, showOmer: Bool, showChol: Bool)
    -> [String] {
    
    var holidays = [String]()
    let weekday = DayOfWeek(from_absolute: absolute)
    let shabbat_p = (weekday == .Saturday)  // Is it a Saturday?
    
    // Treat Adar in a non-leap year as if it were Adar II.
    let month = ((_month == 12) && !leap_year_p) ? 13 : _month
    switch (month) {
    case 1:  /* Nissan */
        switch (day) {
        case 1:
            if (shabbat_p) {
                holidays.append("Sh. HaHodesh")
            }
        case 14:
            if (!shabbat_p) {
                // If it's Shabbat, we already have three pieces of info.
                // This is the least important.
                holidays.append("Erev Pesach")
            }
            fallthrough
        case 8...13: // and fall through of the 14th
            // The Saturday before Pesach (8th-14th)
            if (shabbat_p) {
                holidays.append("Sh. HaGadol")
            }
        case 15, 16, 21, 22:
            if (!inIsrael || (day == 15) || (day == 21)) {
                holidays.append("Pesach")
                break
            } else if (day == 22) {
                break
            }
            fallthrough
        case 17...20:
            if (showChol) {
                holidays.append("Chol Hamoed")
            }
        case 27...28:
            // Yom HaShoah only exists since Israel was established.
            // If it falls on Sunday (e.g. 1997) it's bumped to Monday, but only since 97/03/20.
            if isYomHashoah(year, day, weekday) {
                holidays.append("Yom HaShoah")
            }
        default:
            break
        }
        if ((day > 15) && showOmer) {
            // Count the Omer, starting after the first day of Pesach.
           holidays.append(getSefirah(day - 15))
        }
        
    case 2:  /* Iyar */
        switch (day) {
        case 2...6:
            // Yom HaAtzmaut is on the 5th, unless that's a Saturday, in which
            // case it is moved forward two days to Thursday, and unless that's
            // a Friday in which case it is moved forward one day to Thursday.
            // Yom HaZikaron is the day before Yom HaAtzmaut.
            // In 2004 the law changed so that if the 5th is a Monday, Yom
            // Hazikaron gets moved backward to Tuesday.
            // http://www.hebcal.com/home/150/yom_haatzmaut_yom_hazikaron_2007
            if let yomHatzmaut = getYomHaAtzmaut(year: year, month: month, day: day, absolute: absolute) {
                if day == yomHatzmaut - 1 {
                    holidays.append("Yom HaZikaron")
                } else if day == yomHatzmaut {
                    holidays.append("Yom HaAtzmaut")
                }
            }
        case 28:
            // only since the 1967 war
            if (year > 1967 + 3760) {
                holidays.append("Yom Yerushalayim")
            }
            
        case 18:
            holidays.append("Lag BaOmer")
            
        default:
            break
        }
        
        if ((day != 18) && showOmer) {
            // Sefirah is the entire month, but we've already mentioned Lag BaOmer
            holidays.append(getSefirah(day + 15))
        }
        
    case 3:  /* Sivan */
        switch (day) {
        case 1...4:
            // Sfirah until Shavuot
            if (showOmer) {
                holidays.append(getSefirah(day + 44))
            }
        case 5:
            // Don't need to mention Sfira(49) if there's already two other pieces of information
            if (showOmer && !shabbat_p)  {
                holidays.append(getSefirah(49))
            }
            holidays.append("Erev Shavuot")
        case 6...7:
            if (!inIsrael || (day == 6)) {
                holidays.append("Shavuot")
            }
        default:
            break
        }
        
    case 4:  /* Tamuz */
        // 17th of Tamuz, except Shabbat pushes it to Sunday.
        if ((!shabbat_p && (day == 17)) || ((weekday == .Sunday) && (day == 18))) {
            holidays.append("Tzom Tamuz")
        }
        
    case 5:  /* Ab */
        if (shabbat_p && (3 <= day) && (day <= 16)) {
            // The shabbat before and after Tisha B'Av are special
            holidays.append((day <= 9) ? "Sh. Hazon" : "Sh. Nahamu")
        } else if ((!shabbat_p && (day == 9)) || ((weekday == .Sunday) && (day == 10))) {
            // 9th of Av, except Shabbat pushes it to Sunday.
            holidays.append("Tisha B'Av")
        }
        
    case 6:  /* Elul */
        if ((day >= 20) && (day <= 26) && shabbat_p) {
            holidays.append("S'lichot (evening)")
        } else if (day == 29) {
            holidays.append("Erev R.H.")
        }
        
    case 7:  /* Tishrei */
        switch (day) {
        case 1...2:
            holidays.append("Rosh Hashonah")

        case 3:
            holidays.append(shabbat_p ? "Sh. Shuvah" : "Tzom Gedaliah");

        case 4:
            if (weekday == .Sunday) {
                holidays.append("Tzom Gedliah")
            }
            fallthrough
        case 5...8:
            if (shabbat_p) {
                holidays.append("Sh. Shuvah")
            }
        case 9:
            holidays.append("Erev Y.K.");
        case 10:
            holidays.append("Yom Kippur");
        case 14:
            holidays.append("Erev Sukkot");
            break;
        case 15, 16:
            if (!inIsrael || (day == 15)) {
                holidays.append("Sukkot");
                break;
            }
            fallthrough
        case 17...20:
            if (showChol) {
                holidays.append("Chol Hamoed")
            }
        case 21:
            holidays.append("Hoshanah Rabah");
        case 22:
            holidays.append("Shmini Atzeret")
        case 23:
            if (!inIsrael) {
                holidays.append("Simchat Torah")
            }
        default:
            break;
        }
        
    case 8:  /* Cheshvan */
        break;
        
    case 9:  /* Kislev */
        if (day == 24) {
            holidays.append("Erev Hanukah")
        } else if (day >= 25) {
            holidays.append("Hanukah")
        }
        
    case 10: /* Tevet */
        if (day <= (kvia == 0 ? 3 : 2)) {
            // Need to know length of Kislev to determine last day of Chanukah
            holidays.append("Hanukah")
        } else if (((day == 10) && !shabbat_p) || ((day == 11) && (weekday == .Sunday))) {
            // 10th of Tevet.  Shabbat pushes it to Sunday
           holidays.append("Tzom Tevet")
        }
        
    case 11: /* Shvat */
        let song = "Sh. Shirah"
        switch (day) {
            // The info for figuring out Shabbat Shirah is from the Gnu code.  I
            // assume it's correct.
        case 10:
            if ((kvia != 0) && shabbat_p) {
                holidays.append(song)
            }
        case 11...16:
            if (shabbat_p) {
                holidays.append(song)
            }
            if (day == 15) {
                holidays.append("Tu B'Shvat")
            }
        case 17:
            if ((kvia == 0) && shabbat_p) {
                holidays.append(song)
            }
        case 25...30:
            // The last shabbat on or before 1 Adar or 1 AdarII
            if (shabbat_p && !leap_year_p) {
                holidays.append("Sh. Shekalim")
            }
        default:
            break
        }
        
    case 12: /* Adar I */
        if (day == 14) {
            // Eat Purim Katan Candy
            holidays.append("Purim Katan")
        } else if ((day >= 25) && shabbat_p) {
            // The last shabbat on or before 1 Adar II.
            holidays.append("Sh. Shekalim")
        }
        
    case 13: /* Adar II or Adar */
        switch (day) {
        case 1:
            if (shabbat_p) {
                holidays.append("Sh. Shekalim")
            }
        case 11...12:
            // Ta'anit ester is on the 13th.  But shabbat moves it back to
            // Thursday.
            if (weekday == .Thursday)  {
                holidays.append("Ta'anit Ester")
            }
            fallthrough
        case 7...10:
            // The Shabbat before purim is Shabbat Zachor
            if (shabbat_p) {
                holidays.append("Sh. Zachor")
            }
        case 13:
            holidays.append(shabbat_p ? "Sh. Zachor" : "Erev Purim")
            // It's Ta'anit Esther, unless it's a Friday or Saturday
            if (weekday != .Friday && weekday != .Saturday) {
                holidays.append("Ta'anit Ester")
            }
        case 14:
            holidays.append("Purim")
        case 15:
            if (!shabbat_p) {
                holidays.append("Shushan Purim")
            }
        case 16:
            if (weekday == .Sunday) {
                holidays.append("Shushan Purim")
            }
        case 17...23:
            if (shabbat_p) {
                holidays.append("Sh. Parah")
            }
        case 24...29:
            if (shabbat_p) {
                holidays.append("Sh. HaHodesh")
            }
        default:
            break
        }
    default:
        break
    }
    if (shabbat_p && showParsha) {
        // Find the Parsha on Shabbat.
        if let parsha = findParshaName(day_number, kvia, leap_year_p, inIsrael) {
            holidays.append(parsha)
        }
    }
    return holidays;
}

private func getSefirah(_ day: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(from: NSNumber(value: day))! + " day Omer"
}

private func isYomHashoah(_ year: Int, _ day: Int, _ weekday: DayOfWeek) -> Bool {
    // Yom HaShoah only exists since Israel was established.
    // If it falls on Sunday (e.g. 1997) it's bumped to Monday, but only since 97/03/20.
    // When this is called, day will always be 27 or 28,
    if (year > 1948 + 3760) {
        if (year >= 1997 + 3760) {
            switch (weekday) {
            case .Sunday:
                return false
            case .Monday:
                return true   // either Monday 27 or bumped from Sunday 27.
            default:
                return day == 27
            }
        } else {
            return day == 27
        }
    }
    return false
}

private func getYomHaAtzmaut(year: Int, month: Int, day: Int, absolute: Int) -> Int? {
    if (year < 1948 + 3760) {
        return nil
    }
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
    let weekdayOfTheSixth = DayOfWeek(from_absolute: absolute + (6 - day))
    switch (weekdayOfTheSixth) {
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
