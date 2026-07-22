// Preferences.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// The user's preferences, backed by UserDefaults.  The views write them
/// through @AppStorage, so everything here is read-only.
enum Preferences {
    static var useJulian: Bool {
        defaults.bool(forKey: Key.useJulian)
    }

    static var inIsrael: Bool {
        defaults.bool(forKey: Key.inIsrael)
    }

    static var showParsha: Bool {
        defaults.bool(forKey: Key.showParsha)
    }

    static var showOmer: Bool {
        defaults.bool(forKey: Key.showOmer)
    }

    static var showCholHamoed: Bool {
        defaults.bool(forKey: Key.showCholHamoed)
    }

    /// The secular calendar the user has selected.
    static var secularCalendar: SecularCalendar {
        useJulian ? .julian : .gregorian
    }

    /// The holiday display options the user has selected.
    static var holidayOptions: HolidayOptions {
        HolidayOptions(
            inIsrael: inIsrael, showParsha: showParsha,
            showOmer: showOmer, showCholHamoed: showCholHamoed)
    }

    /// The UserDefaults keys, shared with the views' @AppStorage properties.
    enum Key {
        static let useJulian = "julian"
        static let inIsrael = "israel"
        static let showParsha = "parsha"
        static let showOmer = "omer"
        static let showCholHamoed = "chol"
    }

    private static let defaults: UserDefaults = {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            Key.useJulian: false,
            Key.inIsrael: false,
            Key.showParsha: true,
            Key.showOmer: true,
            Key.showCholHamoed: true
        ])
        return defaults
    }()
}
