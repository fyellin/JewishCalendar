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
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        currentYear = components.value(for: .year)!
        currentMonth = components.value(for: .month)!
        super.viewDidLoad()
        dataDidChange()
    }

    // Called when currentMonth or currentYear changes because of a cocoa binding
    @IBAction func cocoaBindingChanged(_ sender: Any) {
        dataDidChange()
    }
    
    @IBAction func changeMonthByDelta(_ sender: NSButton) {
        let delta = sender.tag
        assert(abs(delta) == 1, "Delta must be +1 or -1")
        let temp = currentYear * 12 + currentMonthSelectionIndex + delta
        guard temp >= 0 && temp < 12 * (maximumYear + 1) else {
            print("Date out of range.  Button shouldn't have been highlighted")
            return
        }
        currentYear = temp / 12
        currentMonthSelectionIndex = temp % 12
        dataDidChange()
    }
    
    func dataDidChange() {
        // yearLabel.stringValue = "\(currentYear)"
        // yearStepper.intValue = Int32(currentYear)
        // monthPicker.selectItem(at: currentMonth - 1)

        let inIsrael = Preference.inIsrael.get()
        let showParsha = Preference.showParsha.get()
        let showChol = Preference.showCholHamoed.get()
        let showOmer = Preference.showOmer.get()
        let useJulian = Preference.useJulian.get()
        
        var result = DateResult(fromSecularYear: currentYear, month: currentMonth, day: 1, isJulian: useJulian)
        let firstResult = result
        var secularDay = 1
        var hebrewDay = result.hebrewDay
        var hebrewDayNumber = result.hebrewDayNumber
        var absolute = result.absolute

        var dateInfoArray = [DateInfo]()

        while secularDay <= result.secularMonthLength {
            // at this point, we're either on the first of the secular month, or the first day of the Hebrew month
            if (secularDay > 1) {
                result = DateResult(fromSecularYear: currentYear, month: currentMonth, day: secularDay, isJulian: useJulian)
                assert(result.hebrewDay == 1)
                assert(result.hebrewMonth == 7 ? result.hebrewDayNumber == 1 : result.hebrewDayNumber == hebrewDayNumber)
                assert(result.absolute == absolute)
                hebrewDay = 1
                hebrewDayNumber = result.hebrewDayNumber
            }
            while secularDay <= result.secularMonthLength && hebrewDay <= result.hebrewMonthLength {
                let holidays = FindHolidays(
                    year: result.hebrewYear, month: result.hebrewMonth, day: hebrewDay, absolute: absolute,
                    kvia: result.kvia, leap_year_p: result.hebrew_leap_year_p, day_number: hebrewDayNumber,
                    inIsrael: inIsrael, showParsha: showParsha, showOmer: showOmer, showChol: showChol)
                // print(secular_day, result.hebrew_year, result.hebrew_month_name, hebrew_day, hebrew_day_number, holidays)
                let dateInfo = DateInfo(
                    secularDay: secularDay, hebrewDay: hebrewDay, hebrewMonth: result.hebrewMonth,
                    hebrewMonthName: result.hebrewMonthName, holidays: holidays)
                dateInfoArray.append(dateInfo)
                secularDay += 1
                hebrewDay += 1
                hebrewDayNumber += 1
                absolute += 1
            }
        }
        let finalResult = result
        let startBanner: String
        if firstResult.hebrewMonth == finalResult.hebrewMonth {
            startBanner = "\(firstResult.hebrewDay)"
        } else if firstResult.hebrewYear == finalResult.hebrewYear {
            startBanner = "\(firstResult.hebrewDay) \(firstResult.hebrewMonthName)"
        } else {
            startBanner = "\(firstResult.hebrewDay) \(firstResult.hebrewMonthName) \(firstResult.hebrewYear)"
        }
        let endBanner = "\(hebrewDay - 1) \(finalResult.hebrewMonthName) \(finalResult.hebrewYear)"
        let banner = "\(startBanner) — \(endBanner)"
        
        previousMonthButton.isEnabled = (currentYear, currentMonth) > (minimumYear, 1)
        nextMonthButton.isEnabled = (currentYear, currentMonth) < (maximumYear, 12)
        dateRangeLabel.stringValue = banner

        calendarView.updateView(dateInfoArray: dateInfoArray, absoluteStart: firstResult.absolute)
    }
}
