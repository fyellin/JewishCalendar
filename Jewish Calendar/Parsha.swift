// Parsha.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

let parshiotNames = [
  "Bereshit", "Noach", "Lech L'cha", "Vayera", "Chaye Sarah",
  "Toldot", "Vayetze", "Vayishlach", "Vayeshev", "Miketz",
  "Vayigash", "Vayechi", "Shemot", "Vaera", "Bo",
  "Beshalach", "Yitro", "Mishpatim", "Terumah", "Tetzaveh",
  "Ki Tisa", "Vayakhel", "Pekudei", "Vayikra", "Tzav",
  "Shemini", "Tazria", "Metzora", "Acharei Mot", "Kedoshim",
  "Emor", "Behar", "Bechukotai", "Bemidbar", "Naso",
  "Behaalotcha", "Shelach", "Korach", "Chukat", "Balak",
  "Pinchas", "Matot", "Masei", "Devarim", "Vaetchanan",
  "Ekev", "Reeh", "Shoftim", "Ki Tetze", "Ki Tavo",
  "Nitzavim", "Vayelech", "Haazinu"
]

// Tables for each of the year types.  nil  indicates that it is a Holiday, and
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

let saturdayShort = [
  nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25,
  126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
  45, 46, 47, 48, 49, 50
]

let saturdayLong = [
  nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25,
  126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
  45, 46, 47, 48, 49, 150
]

let mondayShort = [
  51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25, 126,
  128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44, 45,
  46, 47, 48, 49, 150
]

let mondayLong = [
  51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25, 126,
  128, 30, 131, 33, nil, 34, 35, 36, 37, 138, 40, 141, 43, 44, 45,
  46, 47, 48, 49, 150
]

let mondayLongIsrael = mondayShort

let tuesdayNormal = mondayLong
let tuesdayNormalIsrael = mondayShort

let thursdayNormal = [
  52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, nil, 25,
  126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
  45, 46, 47, 48, 49, 50
]

let thursdayNormalIsrael = [
  52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25, 126,
  128, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
  45, 46, 47, 48, 49, 50
]

let thursdayLong = [
  52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, nil, 25,
  126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
  45, 46, 47, 48, 49, 50
]

let saturdayShortLeap = [
  nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
  26, 27, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
  40, 141, 43, 44, 45, 46, 47, 48, 49, 150
]

let saturdayLongLeap = [
  nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
  26, 27, nil, 28, 29, 30, 31, 32, 33, nil, 34, 35, 36, 37, 138,
  40, 141, 43, 44, 45, 46, 47, 48, 49, 150
]

let saturdayLongLeapIsrael = saturdayShortLeap

let mondayShortLeap = [
  51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, nil, 28, 29, 30, 31, 32, 33, nil, 34, 35, 36, 37, 138, 40,
  141, 43, 44, 45, 46, 47, 48, 49, 150
]

let mondayShortLeapIsrael = [
  51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  141, 43, 44, 45, 46, 47, 48, 49, 150
]

let mondayLongLeap = [
  51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, nil, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
  40, 141, 43, 44, 45, 46, 47, 48, 49, 50
]

let mondayLongLeapIsrael = [
  51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50
]

let tuesdayNormalLeap = mondayLongLeap
let tuesdayNormalLeapIsrael = mondayLongLeapIsrael

let thursdayShortLeap = [
  52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, 28, nil, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50
]

let thursdayLongLeap = [
  52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, 28, nil, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 150
]

/* Find the parsha for a given day of the year.  daynumber is the day of the year.
 * kvia and leap_p refer to the year type.
 */
func findParshaName(_ dayNumber: Int, _ yearLength: Int, _ isIsrael: Bool) -> String? {
  // Today is Saturday, so we can figure out the day of week of RH from the day number
  let roshHashanahWeekday = DayOfWeek.Saturday - (dayNumber - 1)

  var t: (diaspora: [Int?], israel: [Int?])
  switch (roshHashanahWeekday, yearLength) {
    case(.Saturday, 353): t = (saturdayShort, saturdayShort)
    case(.Saturday, 355): t = (saturdayLong, saturdayLong)
    case(.Monday, 353): t = (mondayShort, mondayShort)
    case(.Monday, 355): t = (mondayLong, mondayLongIsrael)
    case(.Tuesday, 354): t = (tuesdayNormal, tuesdayNormalIsrael)
    case(.Thursday, 354): t = (thursdayNormal, thursdayNormalIsrael)
    case(.Thursday, 355): t = (thursdayLong, thursdayLong)

    case(.Saturday, 383): t = (saturdayShortLeap, saturdayShortLeap)
    case(.Saturday, 385): t = (saturdayLongLeap, saturdayLongLeapIsrael)
    case(.Monday, 383): t = (mondayShortLeap, mondayShortLeapIsrael)
    case(.Monday, 385): t = (mondayLongLeap, mondayLongLeapIsrael)
    case(.Tuesday, 384): t = (tuesdayNormalLeap, tuesdayNormalLeapIsrael)
    case(.Thursday, 383): t = (thursdayShortLeap, thursdayShortLeap)
    case(.Thursday, 385): t = (thursdayLongLeap, thursdayLongLeap)
    default: preconditionFailure("Unknown year type")
  }
  let parshaArray = isIsrael ? t.israel : t.diaspora
  let week = dayNumber / 7 // week of the year
  if let parshaIndex = parshaArray[week] {
    if parshaIndex < 100 {
      return parshiotNames[parshaIndex]
    } else {
      return parshiotNames[parshaIndex - 100] + "/" + parshiotNames[parshaIndex - 99]
    }
  }
  return nil
}
