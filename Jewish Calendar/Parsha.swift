//
//  Parsha.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/7/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

let parshiotNames = [
    "Bereshit",    "Noach",       "Lech L'cha", "Vayera",      "Chaye Sarah",
    "Toldot",      "Vayetze",     "Vayishlach", "Vayeshev",    "Miketz",
    "Vayigash",    "Vayechi",     "Shemot",     "Vaera",       "Bo",
    "Beshalach",   "Yitro",       "Mishpatim",  "Terumah",     "Tetzaveh",
    "Ki Tisa" ,    "Vayakhel",    "Pekudei",    "Vayikra",     "Tzav",
    "Shemini",     "Tazria",      "Metzora",    "Acharei Mot", "Kedoshim",
    "Emor",        "Behar",       "Bechukotai", "Bemidbar",    "Naso",
    "Behaalotcha", "Shelach",     "Korach",     "Chukat",      "Balak",
    "Pinchas",     "Matot",       "Masei",      "Devarim",     "Vaetchanan",
    "Ekev",        "Reeh",        "Shoftim",    "Ki Tetze",    "Ki Tavo",
    "Nitzavim",    "Vayelech",    "Haazinu", ]


// Tables for each of the year types.  XX indicates that it is a Holiday, and
// a special parsha is read that week.  For some year types, Israel is different
// than the diaspora.
//
// The names indicate the day of the week on which Rosh Hashanah fell, whether
// it is a short/normal/long year (kvia=0,1,2), and whether it is a leap year.
// Some year types also have an _Israel version.
//
// Numbers are indices into the table above for a given week.  Numbers > 100 indicate
// a double parsha.  E.g. 150 means read both table entries 50 and 51.
//
// These tables were stolen (with some massaging) from the GNU code.

let XX = 255

let saturdayShort = [
    XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25,
    126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,]

let saturdayLong = [
    XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25,
    126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49, 150 ]

let mondayShort = [
    51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25, 126,
    128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,  45,
    46,  47,  48,  49, 150 ]

let mondayLong = [
    51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25, 126,
    128,  30, 131,  33,  XX,  34,  35,  36,  37, 138,  40, 141,  43,  44,  45,
    46,  47,  48,  49, 150, ]

let mondayLongIsrael = mondayShort

let tuesdayNormal = mondayLong
let tuesdayNormalIsrael = mondayShort

let thursdayNormal = [
    52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  XX,  25,
    126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,]

let thursdayNormalIsrael = [
    52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20, 121,  23,  24,  XX,  25, 126,
    128,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,]

let thursdayLong = [
    52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  XX,  25,
    126, 128,  30, 131,  33,  34,  35,  36,  37,  38,  39,  40, 141,  43,  44,
    45,  46,  47,  48,  49,  50,]

let saturdayShortLeap = [
   XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,
    26,  27,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,
    40, 141,  43,  44,  45,  46,  47,  48,  49, 150, ]

let saturdayLongLeap = [
    XX,  52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,
    11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,
    26,  27,  XX,  28,  29,  30,  31,  32,  33,  XX,  34,  35,  36,  37, 138,
    40, 141,  43,  44,  45,  46,  47,  48,  49, 150, ]

let saturdayLongLeapIsrael = saturdayShortLeap

let mondayShortLeap = [
    51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  28,  29,  30,  31,  32,  33,  XX,  34,  35,  36,  37, 138,  40,
    141,  43,  44,  45,  46,  47,  48,  49, 150 ]

let mondayShortLeapIsrael = [
  51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    141,  43,  44,  45,  46,  47,  48,  49, 150,]

let mondayLongLeap = [
    51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,
    40, 141,  43,  44,  45,  46,  47,  48,  49,  50,]

let mondayLongLeapIsrael = [
    51,  52,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  XX,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49,  50,]

let tuesdayNormalLeap = mondayLongLeap
let tuesdayNormalLeapIsrael = mondayLongLeapIsrael

let thursdayShortLeap = [
    52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  28,  XX,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49,  50, ]

let thursdayLongLeap = [
    52,  XX,  XX,   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,
    12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,
    27,  28,  XX,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
    41,  42,  43,  44,  45,  46,  47,  48,  49, 150, ]

fileprivate func _key(_ day: DayOfWeek, _ kvia: Int, _ isLeap: Bool) -> Int {
    return day.rawValue * 100 + kvia * 10 + (isLeap ? 1 : 0)
}

let parshaTable = [
    //      RH      kvia leap      disapora        israel
    _key(.Saturday, 0, false): (saturdayShort,  saturdayShort),
    _key(.Saturday, 2, false): (saturdayLong,   saturdayLong),
    _key(.Monday,   0, false): (mondayShort,    mondayShort),
    _key(.Monday,   2, false): (mondayLong,     mondayLongIsrael),
    _key(.Tuesday,  1, false): (tuesdayNormal,  tuesdayNormalIsrael),
    _key(.Thursday, 1, false): (thursdayNormal, thursdayNormalIsrael),
    _key(.Thursday, 2, false): (thursdayLong,   thursdayLong),
    
    _key(.Saturday, 0, true):  (saturdayShortLeap,  saturdayShortLeap),
    _key(.Saturday, 2, true):  (saturdayLongLeap,   saturdayLongLeapIsrael),
    _key(.Monday,   0, true):  (mondayShortLeap,    mondayShortLeapIsrael),
    _key(.Monday,   2, true):  (mondayLongLeap,     mondayLongLeapIsrael),
    _key(.Tuesday,  1, true):  (tuesdayNormalLeap,  tuesdayNormalLeapIsrael),
    _key(.Thursday, 0, true):  (thursdayShortLeap,  thursdayShortLeap),
    _key(.Thursday, 2, true):  (thursdayLongLeap,   thursdayLongLeap)
]

/* Find the parsha for a given day of the year.  daynumber is the day of the year.
 * kvia and leap_p refer to the year type.
 */
func findParshaName(_ dayNumber: Int, _ kvia: Int, _ isLeap: Bool, _ isIsrael: Bool) -> String? {
    let week = dayNumber/7;                // week of the year
    let roshHashanahWeekday : DayOfWeek
    switch (dayNumber % 7) {
        case 1: roshHashanahWeekday = .Saturday
        case 3: roshHashanahWeekday = .Thursday
        case 5: roshHashanahWeekday = .Tuesday
        case 6: roshHashanahWeekday = .Monday
        default: assertionFailure(); return nil
    }
    let (diasporaArray, israelArray) = parshaTable[_key(roshHashanahWeekday, kvia, isLeap)]!
    let parshaArray = isIsrael ? israelArray : diasporaArray
    let parshaIndex = parshaArray[week]
    if parshaIndex == XX {
        return nil
    } else if parshaIndex < 100 {
        return parshiotNames[parshaIndex]
    } else {
        return parshiotNames[parshaIndex - 100] + "/" + parshiotNames[parshaIndex - 99]
    }
}
