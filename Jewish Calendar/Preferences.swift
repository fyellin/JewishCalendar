// Preferences.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// The user's preferences, backed by UserDefaults.
enum Preferences {
    static var useJulian: Bool {
        get { defaults.bool(forKey: Key.useJulian) }
        set { defaults.set(newValue, forKey: Key.useJulian) }
    }

    static var inIsrael: Bool {
        get { defaults.bool(forKey: Key.inIsrael) }
        set { defaults.set(newValue, forKey: Key.inIsrael) }
    }

    static var showParsha: Bool {
        get { defaults.bool(forKey: Key.showParsha) }
        set { defaults.set(newValue, forKey: Key.showParsha) }
    }

    static var showOmer: Bool {
        get { defaults.bool(forKey: Key.showOmer) }
        set { defaults.set(newValue, forKey: Key.showOmer) }
    }

    static var showCholHamoed: Bool {
        get { defaults.bool(forKey: Key.showCholHamoed) }
        set { defaults.set(newValue, forKey: Key.showCholHamoed) }
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

    private enum Key {
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
