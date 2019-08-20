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
    
    var jewishCalendarController : JewishCalendarViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let controller = NSApplication.shared.mainWindow?.contentViewController
        jewishCalendarController = controller as? JewishCalendarViewController
        NSFontManager.shared.setSelectedFont(NSFont.systemFont(ofSize: 13.0), isMultiple: false)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func handlePrintMenu(_ sender: Any) {
        if let view = jewishCalendarController?.view {
            NSPrintOperation(view: view).run()
        }
    }
    
    @IBAction func showFont(_ sender: Any) {
        print(NSFontManager.shared.selectedFont ?? "none")
    }
    
    @IBAction func modifyFont(_ sender: Any) {
        NSFontManager.shared.modifyFont(sender)
        jewishCalendarController!.calendarView.needsDisplay = true
    }
}
