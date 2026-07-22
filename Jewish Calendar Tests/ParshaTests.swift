// ParshaTests.swift
// Copyright (c) 2026 Frank Yellin.

import Foundation
import Testing

@testable import Jewish_Calendar

/// One Hebrew year of each of the fourteen year types (see DateTests.swift).
private let testYears = [5780, 5781, 5782, 5784, 5785, 5786, 5787, 5788, 5789, 5790, 5795, 5797, 5803, 5812]

/// The 53 parshiot in reading order.  This is deliberately a separate copy of
/// the table in Parsha.swift, so that a typo there cannot hide from these tests.
private let orderedParshiot = [
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

/// The positions in reading order of the (possibly doubled) parsha, or nil if
/// any name is unrecognized.
private func readingOrderIndices(of parsha: String) -> [Int]? {
    let indices = parsha.split(separator: "/").map { orderedParshiot.firstIndex(of: String($0)) }
    guard !indices.contains(nil) else { return nil }
    return indices.compactMap { $0 }
}

struct ParshaTests {
    /// For every year type, in both Israel and the diaspora: every Shabbat has
    /// a parsha unless a festival displaces it, and the cycle reads every
    /// parsha exactly once, in order, restarting at Bereshit after Simchat
    /// Torah.  (The golden file checks the tables only through composite
    /// holiday strings; this checks their structure directly.)
    @Test(arguments: testYears, [false, true])
    func parshaCycleIsCompleteAndOrdered(year: Int, inIsrael: Bool) throws {
        let hebrewYear = HebrewYear(year)

        // The parsha (or nil) for each Saturday of the year, in order.
        let firstSaturday = 7 - hebrewYear.firstDay.weekday.rawValue
        #expect((hebrewYear.firstDay + (firstSaturday - 1)).weekday == .saturday)
        let saturdays = stride(from: firstSaturday, through: hebrewYear.length, by: 7).map {
            (day: $0, name: parshaName(dayOfHebrewYear: $0, yearLength: hebrewYear.length, inIsrael: inIsrael))
        }

        // A Saturday has no parsha exactly when a festival displaces the
        // weekly reading.
        func isFestival(_ date: HebrewDate) -> Bool {
            switch (date.month, date.day) {
                case (.tishrei, 1...2), (.tishrei, 10), (.tishrei, 15...22): return true
                case (.nisan, 15...21), (.sivan, 6): return true
                case (.tishrei, 23), (.nisan, 22), (.sivan, 7): return !inIsrael
                default: return false
            }
        }
        for saturday in saturdays {
            let date = hebrewYear.date(of: hebrewYear.firstDay + (saturday.day - 1))
            #expect((saturday.name == nil) == isFestival(date),
                "\(date.day) \(date.month) \(date.year): \(saturday.name ?? "no parsha")")
        }

        // Before Bereshit, the readings still belong to the previous cycle.
        let named = saturdays.compactMap { saturday in
            saturday.name.map { (day: saturday.day, name: $0) }
        }
        let bereshitIndex = try #require(named.firstIndex { $0.name == "Bereshit" })
        #expect(named[..<bereshitIndex].allSatisfy { $0.name == "Vayelech" || $0.name == "Haazinu" })

        // Bereshit is read on the first Shabbat after Simchat Torah.
        let simchatTorah = inIsrael ? 22 : 23
        let bereshitDay = named[bereshitIndex].day
        #expect(bereshitDay > simchatTorah && bereshitDay <= simchatTorah + 7)

        // From Bereshit on, the cycle reads every parsha exactly once, in
        // order (doubled parshiot must be adjacent pairs), ending the year at
        // Nitzavim or Nitzavim/Vayelech.
        let cycle = try named[bereshitIndex...].flatMap {
            try #require(readingOrderIndices(of: $0.name), "Unknown parsha \($0.name)")
        }
        #expect(cycle == Array(0..<cycle.count))
        #expect(cycle.count == 51 || cycle.count == 52)
    }
}
