// Parsha.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// The parsha read on the Shabbat that falls on the given day of the Hebrew
/// year, or nil if a holiday reading replaces the regular cycle that week.
///
/// - Parameters:
///   - dayOfHebrewYear: the 1-based day of the year, which must be a Saturday.
///   - yearLength: the number of days in the year, which identifies the year type.
///   - inIsrael: Israel and the diaspora fall out of step after some holidays.
func parshaName(dayOfHebrewYear: Int, yearLength: Int, inIsrael: Bool) -> String? {
    // Since this day is a Saturday, the weekday of Rosh Hashanah follows from it.
    let roshHashanahWeekday = Weekday.saturday - (dayOfHebrewYear - 1)

    let tables: (diaspora: [Int?], israel: [Int?])
    switch (roshHashanahWeekday, yearLength) {
        case (.saturday, 353): tables = (saturdayShort, saturdayShort)
        case (.saturday, 355): tables = (saturdayLong, saturdayLong)
        case (.monday, 353): tables = (mondayShort, mondayShort)
        case (.monday, 355): tables = (mondayLong, mondayLongIsrael)
        case (.tuesday, 354): tables = (tuesdayNormal, tuesdayNormalIsrael)
        case (.thursday, 354): tables = (thursdayNormal, thursdayNormalIsrael)
        case (.thursday, 355): tables = (thursdayLong, thursdayLong)

        case (.saturday, 383): tables = (saturdayShortLeap, saturdayShortLeap)
        case (.saturday, 385): tables = (saturdayLongLeap, saturdayLongLeapIsrael)
        case (.monday, 383): tables = (mondayShortLeap, mondayShortLeapIsrael)
        case (.monday, 385): tables = (mondayLongLeap, mondayLongLeapIsrael)
        case (.tuesday, 384): tables = (tuesdayNormalLeap, tuesdayNormalLeapIsrael)
        case (.thursday, 383): tables = (thursdayShortLeap, thursdayShortLeap)
        case (.thursday, 385): tables = (thursdayLongLeap, thursdayLongLeap)
        default: preconditionFailure("Unknown year type")
    }

    let table = inIsrael ? tables.israel : tables.diaspora
    guard let entry = table[dayOfHebrewYear / 7] else { return nil }
    return entry < 100
        ? parshiotNames[entry]
        : parshiotNames[entry - 100] + "/" + parshiotNames[entry - 99]
}

private let parshiotNames = [
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

// Tables for each of the year types.  Each entry is one week of the year; nil
// indicates that a holiday falls on that Shabbat and a special parsha is read.
// For some year types, Israel is different from the diaspora.
//
// The names indicate the day of the week on which Rosh Hashanah fell, whether
// it is a short/normal/long year, and whether it is a leap year.  Some year
// types also have an Israel version.
//
// Numbers are indices into the table above for a given week.  Numbers > 100
// indicate a double parsha.  E.g. 150 means read both table entries 50 and 51.
//
// These tables were stolen (with some massaging) from the GNU code.

private let saturdayShort: [Int?] = [
    nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25,
    126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
    45, 46, 47, 48, 49, 50
]

private let saturdayLong: [Int?] = [
    nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25,
    126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
    45, 46, 47, 48, 49, 150
]

private let mondayShort: [Int?] = [
    51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25, 126,
    128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44, 45,
    46, 47, 48, 49, 150
]

private let mondayLong: [Int?] = [
    51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25, 126,
    128, 30, 131, 33, nil, 34, 35, 36, 37, 138, 40, 141, 43, 44, 45,
    46, 47, 48, 49, 150
]

private let mondayLongIsrael = mondayShort

private let tuesdayNormal = mondayLong
private let tuesdayNormalIsrael = mondayShort

private let thursdayNormal: [Int?] = [
    52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, nil, 25,
    126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
    45, 46, 47, 48, 49, 50
]

private let thursdayNormalIsrael: [Int?] = [
    52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 121, 23, 24, nil, 25, 126,
    128, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
    45, 46, 47, 48, 49, 50
]

private let thursdayLong: [Int?] = [
    52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, nil, 25,
    126, 128, 30, 131, 33, 34, 35, 36, 37, 38, 39, 40, 141, 43, 44,
    45, 46, 47, 48, 49, 50
]

private let saturdayShortLeap: [Int?] = [
    nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
    26, 27, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 141, 43, 44, 45, 46, 47, 48, 49, 150
]

private let saturdayLongLeap: [Int?] = [
    nil, 52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
    26, 27, nil, 28, 29, 30, 31, 32, 33, nil, 34, 35, 36, 37, 138,
    40, 141, 43, 44, 45, 46, 47, 48, 49, 150
]

private let saturdayLongLeapIsrael = saturdayShortLeap

private let mondayShortLeap: [Int?] = [
    51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, nil, 28, 29, 30, 31, 32, 33, nil, 34, 35, 36, 37, 138, 40,
    141, 43, 44, 45, 46, 47, 48, 49, 150
]

private let mondayShortLeapIsrael: [Int?] = [
    51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    141, 43, 44, 45, 46, 47, 48, 49, 150
]

private let mondayLongLeap: [Int?] = [
    51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, nil, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 141, 43, 44, 45, 46, 47, 48, 49, 50
]

private let mondayLongLeapIsrael: [Int?] = [
    51, 52, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, nil, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50
]

private let tuesdayNormalLeap = mondayLongLeap
private let tuesdayNormalLeapIsrael = mondayLongLeapIsrael

private let thursdayShortLeap: [Int?] = [
    52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, 28, nil, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50
]

private let thursdayLongLeap: [Int?] = [
    52, nil, nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
    12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, 28, nil, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 150
]
