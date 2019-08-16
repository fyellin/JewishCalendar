//
//  Preferences.swift
//  Jewish Calendar
//
//  Created by Frank Yellin on 8/16/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

enum Preference : String {
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
        return Preference.userDefaults.bool(forKey: self.rawValue)
    }
    
    func set(value: Bool) {
        Preference.userDefaults.set(value, forKey: self.rawValue)
    }
    
    func flip() {
        set(value: !get())
    }
    
    private static func getInitializedUserDefaults() -> UserDefaults {
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [
            useJulian.rawValue:      false,
            inIsrael.rawValue:       false,
            showParsha.rawValue:     true,
            showOmer.rawValue:       true,
            showCholHamoed.rawValue: true
            ])
        return userDefaults
    }
}
