// Preferences.swift
// Copyright (c) 2019 Frank Yellin.

import Foundation

/// This class serves as a bridge between the user's preferences and their representation
/// in UserDefaults.standard

enum Preference: String {
  case useJulian = "julian"
  case inIsrael = "israel"
  case showParsha = "parsha"
  case showOmer = "omer"
  case showCholHamoed = "chol"

  static let userDefaults = getInitializedUserDefaults()

  static func reset() {
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.synchronize()
  }

  func get() -> Bool {
    return Preference.userDefaults.bool(forKey: rawValue)
  }

  func set(value: Bool) {
    Preference.userDefaults.set(value, forKey: rawValue)
  }

  func flip() {
    set(value: !get())
  }

  private static func getInitializedUserDefaults() -> UserDefaults {
    let userDefaults = UserDefaults.standard
    userDefaults.register(defaults: [
      useJulian.rawValue: false,
      inIsrael.rawValue: false,
      showParsha.rawValue: true,
      showOmer.rawValue: true,
      showCholHamoed.rawValue: true
    ])
    return userDefaults
  }
}
