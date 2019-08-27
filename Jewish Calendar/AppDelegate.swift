// AppDelegate.swift
// Copyright (c) 2019 Frank Yellin.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet var fontMenu: NSMenuItem!

  var jewishCalendarController: JewishCalendarViewController?

  let showFontMenu = true
  let enableFontMenu = true

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller = NSApplication.shared.mainWindow?.contentViewController
    jewishCalendarController = controller as? JewishCalendarViewController
    fontMenu.isEnabled = enableFontMenu
    fontMenu.isHidden = !showFontMenu

    let window = NSApplication.shared.mainWindow
    window?.windowController?.shouldCascadeWindows = false
    window?.setFrameUsingName("JewishCalendar")
    window?.setFrameAutosaveName("JewishCalendar")
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  @IBAction func handlePrintMenu(_ sender: Any) {
    if let view = jewishCalendarController?.view {
      NSPrintOperation(view: view).run()
    }
  }

  @IBAction func modifyFont(_ sender: NSMenuItem) {
    // NSFontManager.shared.modifyFont(sender)
    jewishCalendarController?.calendarView.modifyFont(sender)
  }
}
