//
//  AppDelegate.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/7/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var gregorianMenuItem: NSMenuItem!
    @IBOutlet weak var julianMenuItem: NSMenuItem!
    @IBOutlet weak var diasporaMenuItem: NSMenuItem!
    @IBOutlet weak var israelMenuItem: NSMenuItem!
    @IBOutlet weak var parshaMenuItem: NSMenuItem!
    @IBOutlet weak var omerMenuItem: NSMenuItem!
    @IBOutlet weak var cholHamoedMenuItem: NSMenuItem!
    
    var hebrewCalendarController : JewishCalendarViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateMenuAndController()
        let application = aNotification.object as! NSApplication
        let controller = application.mainWindow?.contentViewController
        hebrewCalendarController = controller as? JewishCalendarViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func selectedGregorian(_ sender: NSMenuItem) {
        Preference.useJulian.set(value: false)
        updateMenuAndController()
    }
    
    @IBAction func selectedJulian(_ sender: Any) {
        Preference.useJulian.set(value: true)
        updateMenuAndController()
    }
    
    @IBAction func selectedDiaspora(_ sender: Any) {
        Preference.inIsrael.set(value: false)
        updateMenuAndController()
    }
    
    @IBAction func selectedIsrael(_ sender: Any) {
        Preference.inIsrael.set(value: true)
        updateMenuAndController()
    }
    
    @IBAction func selectedShowParsha(_ sender: Any) {
        Preference.showParsha.flip()
        updateMenuAndController()
    }
    
    @IBAction func selectedShowOmer(_ sender: Any) {
        Preference.showOmer.flip()
        updateMenuAndController()
    }
    
    @IBAction func selectedShowCholHamoed(_ sender: Any) {
        Preference.showCholHamoed.flip()
        updateMenuAndController()
    }
    
    func updateMenuAndController() {
        let useJulian = Preference.useJulian.get()
        gregorianMenuItem.state = useJulian ? .off : .on
        julianMenuItem.state = useJulian ? .on : .off
        
        let inIsrael = Preference.inIsrael.get()
        diasporaMenuItem.state = inIsrael ? .off : .on
        israelMenuItem.state = inIsrael ? .on : .off
        
        parshaMenuItem.state = Preference.showParsha.get() ? .on : .off
        omerMenuItem.state = Preference.showOmer.get() ? .on : .off
        cholHamoedMenuItem.state = Preference.showCholHamoed.get() ? .on : .off

        hebrewCalendarController?.dataDidChange()
    }
}

enum Preference : String {
    case useJulian = "julian"
    case inIsrael = "israel"
    case showParsha = "parsha"
    case showOmer = "omer"
    case showCholHamoed = "chol"
    
    
    static let userDefaults : UserDefaults = {
        let result = UserDefaults.standard
        initialize(result)
        return result
    }()
    
    func get() -> Bool {
        return Preference.userDefaults.bool(forKey: self.rawValue)
    }
    
    func set(value: Bool) {
        Preference.userDefaults.set(value, forKey: self.rawValue)
    }
    
    func flip() {
        set(value: !get())
    }
    
    private static func initialize(_ defaults: UserDefaults) {
        defaults.register(defaults: [
            useJulian.rawValue:      false,
            inIsrael.rawValue:       false,
            showParsha.rawValue:     true,
            showOmer.rawValue:       true,
            showCholHamoed.rawValue: true
        ])
    }
}
