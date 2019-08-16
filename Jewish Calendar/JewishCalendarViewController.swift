//
//  ViewController.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/7/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa

class JewishCalendarViewController: NSViewController {
    @IBOutlet weak var monthPicker: NSPopUpButton!
    @IBOutlet weak var dateRangeLabel: NSTextField!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var previousMonthButton: NSButton!
    @IBOutlet weak var nextMonthButton: NSButton!
    
    
    @IBOutlet weak var previousYearTouchBar: NSButton!
    @IBOutlet weak var nextYearTouchBar: NSButton!
    @IBOutlet weak var previousMonthTouchBar: NSButton!
    @IBOutlet weak var nextMonthTouchBar: NSButton!
  
    @IBOutlet weak var yearEditor: NSTextField!
    
    @objc dynamic var currentYear = 1
    @objc dynamic var minimumYear = 1000
    @objc dynamic var maximumYear = 3999
    
    @objc dynamic var currentMonthSelectionIndex = 0
    
    var currentMonth : Int {
        get { return currentMonthSelectionIndex + 1}
        set { currentMonthSelectionIndex = newValue - 1}
    }
    
    @objc dynamic var longMonthNames = DateFormatter().standaloneMonthSymbols!
    
    override func viewDidLoad() {
        // Make sure we set the year and month before the labels get their assigned values
        yearEditor.delegate = self
        let today = todaysYearMonthDay(isJulian: Preference.useJulian.get())
        (currentYear, currentMonth) = (today.year, today.month)
        super.viewDidLoad()
        dataDidChange()
    }
    
    // Called when currentMonthSelectionIndex or currentYear changes because of a cocoa binding
    @IBAction func cocoaBindingChanged(_ sender: Any) {
        dataDidChange()
    }
    
    @IBAction func changeMonthByDelta(_ sender: NSButton) {
        let delta = sender.tag
        assert(abs(delta) == 1 || abs(delta) == 12, "Delta must be one month or one year")
        let temp = currentYear * 12 + currentMonthSelectionIndex + delta
        guard temp >= 0 && temp < 12 * (maximumYear + 1) else {
            print("Date out of range.  Button shouldn't have been highlighted")
            return
        }
        currentYear = temp / 12
        currentMonthSelectionIndex = temp % 12
        dataDidChange()
    }
    
    @IBAction func goToToday(_ sender: Any) {
        let today = todaysYearMonthDay(isJulian: Preference.useJulian.get())
        (currentYear, currentMonth) = (today.year, today.month)
        dataDidChange()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // So far, the only segue we have is bringing up the preference window.
        switch segue.identifier {
        case "presentPreferences":
            let destinationViewController = segue.destinationController as! PreferenceViewController
            destinationViewController.callbackWhenDone = {
                self.dismiss(destinationViewController)
                self.dataDidChange()
            }
        default:
            preconditionFailure("Unknown segue.  Should never reach here")
        }
    }
    
    /*
     * Some code for when we want to try binding.
     
    @objc dynamic var enablePreviousMonth : Bool { return (currentYear, currentMonth) > (minimumYear, 1) }
    @objc dynamic var enableNextMonth : Bool { return (currentYear, currentMonth) < (maximumYear, 12) }
    @objc dynamic var enablePreviousYear : Bool { return currentYear > minimumYear }
    @objc dynamic var enableNextYear : Bool { return currentYear < maximumYear }
    
    @objc dynamic var dataModel : [Int] { return [currentMonth, currentYear] }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "enablePreviousMonth", "enableNextMonth", "dataModel":
            return ["currentMonth", "currentYear"]
        case "enablePreviousYear", "enableNextYear":
            return ["currentYear"]
        default:
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
    ******/

    func dataDidChange() {
        calendarView.dataModel = CalendarViewDataModel(year: currentYear, month: currentMonth)
        previousMonthButton.isEnabled = (currentYear, currentMonth) > (minimumYear, 1)
        nextMonthButton.isEnabled = (currentYear, currentMonth) < (maximumYear, 12)
        
        // TODO:  Is there some way of disabling the Touch Buttons?
    }
}

/**
 * This is required so that the TextView doesn't munge the touch bar.
 */
extension NSTextView {
    @available(OSX 10.12.2, *)
    override open func makeTouchBar() -> NSTouchBar? {
        let touchBar = super.makeTouchBar()
        touchBar?.delegate = self
        return touchBar
    }
}

//  Leaving this here for now, in case I ever figure out how to get rid of the text being
//  all chosen when I hit return.
extension JewishCalendarViewController: NSTextFieldDelegate {
    var responder : Any {
        get { return NSApplication.shared.windows.first!.firstResponder! }
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        return true
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
    }
}
