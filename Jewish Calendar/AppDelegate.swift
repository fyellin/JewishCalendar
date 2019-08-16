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
    
    var hebrewCalendarController : JewishCalendarViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let application = aNotification.object as! NSApplication
        let controller = application.mainWindow?.contentViewController
        hebrewCalendarController = controller as? JewishCalendarViewController
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func handlePrintMenu(_ sender: Any) {
        if let view = hebrewCalendarController?.view {
            NSPrintOperation(view: view).run()
        }
    }
}
