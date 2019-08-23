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
    @IBOutlet weak var calendarView: CalendarView!
    
    @IBOutlet weak var previousMonthButton: NSButton!
    @IBOutlet weak var nextMonthButton: NSButton!
    @IBOutlet weak var previousYearButton: NSButton!
    @IBOutlet weak var nextYearButton: NSButton!
    
    @IBOutlet weak var previousYearTouchBar: NSButton!
    @IBOutlet weak var nextYearTouchBar: NSButton!
    @IBOutlet weak var previousMonthTouchBar: NSButton!
    @IBOutlet weak var nextMonthTouchBar: NSButton!
  
    @IBOutlet weak var yearEditor: NSTextField!
    
    @objc dynamic var currentYear = 1
    @objc dynamic var minimumYear = 1000
    @objc dynamic var maximumYear = 3999
    @objc dynamic var currentMonth = 0
    @objc dynamic var longMonthNames = DateFormatter().standaloneMonthSymbols!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let color : NSColor
        if #available(OSX 10.14, *) {
            color = NSColor.textBackgroundColor
        } else {
            color = NSColor.white
        }
        self.view.layer?.backgroundColor = color.cgColor
        
        yearEditor.delegate = self
        
        let today = todaysYearMonthDay(isJulian: Preference.useJulian.get())
        (currentYear, currentMonth) = (today.year, today.month)

        if (_isDebugAssertConfiguration()) {
            // printGoldenInformation()
        }
        dataDidChange()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        turnOffSelectionOnYearEditor()
    }
    
    // MARK: Actions
    
    // Called when currentMonth or currentYear changes because of a cocoa binding
    @IBAction func cocoaBindingChanged(_ sender: Any) {
        dataDidChange()
    }
    
    @IBAction func changeMonthByDelta(_ sender: NSButton) {
        let delta = sender.tag
        assert(abs(delta) == 1 || abs(delta) == 12, "Delta must be one month or one year")
        let temp = currentYear * 12 + currentMonth + delta
        guard temp >= 1 && temp <= 12 * (maximumYear + 1) else {
            print("Date out of range.  Button shouldn't have been highlighted")
            return
        }
        currentYear = (temp - 1) / 12
        currentMonth =  temp - 12 * currentYear
        dataDidChange()
    }
    
    @IBAction func goToToday(_ sender: Any) {
        let today = todaysYearMonthDay(isJulian: Preference.useJulian.get())
        (currentYear, currentMonth) = (today.year, today.month)
        dataDidChange()
    }
    
    // MARK: Segues
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // So far, the only segue we have is bringing up the preference window.
        switch segue.identifier {
        case "presentPreferences":
            let destinationViewController = segue.destinationController as! PreferenceViewController
            destinationViewController.callbackOnChange = {
                self.dataDidChange()
            }
        case "presentHelp":
            break
        default:
            preconditionFailure("Unknown segue.  Should never reach here")
        }
    }
    
    // MARK:  bindings
    
    @objc dynamic var currentMonthSelectionIndex : Int {
        get { return currentMonth - 1}
        set { currentMonth = newValue + 1}
    }
    
    @objc dynamic var enablePreviousMonth : Bool {
        return (currentYear, currentMonth) > (minimumYear, 1)
    }
    
    @objc dynamic var enableNextMonth : Bool {
        return (currentYear, currentMonth) < (maximumYear, 12)
    }
    
    @objc dynamic var enablePreviousYear : Bool {
        return currentYear > minimumYear
    }
    
    @objc dynamic var enableNextYear : Bool {
        return currentYear < maximumYear
    }
    
    @objc dynamic var dataModel : [Int] { return [currentYear, currentMonth] }

    public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        switch key {
        case "enablePreviousMonth", "enableNextMonth", "dataModel":
            return ["currentMonth", "currentYear"]
        case "enablePreviousYear", "enableNextYear":
            return ["currentYear"]
        case "currentMonthSelectionIndex":
            return ["currentMonth"]
        default:
            return super.keyPathsForValuesAffectingValue(forKey: key)
        }
    }
    
    func dataDidChange() {
        calendarView.dataModel = CalendarViewDataModel(year: currentYear, month: currentMonth)
    }
    
    fileprivate func turnOffSelectionOnYearEditor() {
        if yearEditor.currentEditor()?.selectedRange != nil {
            DispatchQueue.main.async {
                self.yearEditor.currentEditor()?.selectedRange =
                    NSRange(location: self.yearEditor.stringValue.count, length: 0)
            }
        }
    }
}

/**
 * This is required so that the TextView doesn't munge the touch bar.
 *
 * This is no longer necessary since we've fixed the storyboard.  But it's nice to keep around.
 */
extension NSTextView {
    @available(OSX 10.12.2, *)
    override open func makeTouchBar() -> NSTouchBar? {
        let touchBar = super.makeTouchBar()
        touchBar?.delegate = self
        return touchBar
    }
}

extension JewishCalendarViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        turnOffSelectionOnYearEditor()
    }
}
