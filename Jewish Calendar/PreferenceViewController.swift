//
//  PreferenceViewController.swift
//  Jewish Calendar
//
//  Created by Frank Yellin on 8/16/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {
    @IBOutlet weak var parshaCheckBox: NSButton!
    @IBOutlet weak var cholHamoedCheckBox: NSButton!
    @IBOutlet weak var omerCheckBox: NSButton!
    
    @IBOutlet weak var diasporaRadioButton: NSButton!
    @IBOutlet weak var israelRadioButton: NSButton!
    
    @IBOutlet weak var gregorianRadioButton: NSButton!
    @IBOutlet weak var julianRadioButton: NSButton!
    
    var callbackOnChange: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateChoices()
    }
    
    @IBAction func parshaButtonPushed(_ sender: NSButton) {
        Preference.showParsha.flip()
        callbackOnChange?()
    }
    
    @IBAction func cholHamoedButtonPushed(_ sender: NSButton) {
        Preference.showCholHamoed.flip()
        callbackOnChange?()
    }
    
    @IBAction func omerButtonPushed(_ sender: NSButton) {
        Preference.showOmer.flip()
        callbackOnChange?()
    }
    
    @IBAction func locationButtonPushed(_ sender: NSButton) {
        Preference.inIsrael.set(value: (sender.tag == 1))
        callbackOnChange?()
    }
    
    @IBAction func calendarButtonPushed(_ sender: NSButton) {
        if sender.tag == 1 {
            guard doubleCheckJulian() else {
                updateChoices()
                return
            }
        }
        Preference.useJulian.set(value: (sender.tag == 1))
        callbackOnChange?()
    }
    
    func updateChoices() {
        let useJulian = Preference.useJulian.get()
        gregorianRadioButton.state = useJulian ? .off : .on
        julianRadioButton.state = useJulian ? .on : .off
        
        let inIsrael = Preference.inIsrael.get()
        diasporaRadioButton.state = inIsrael ? .off : .on
        israelRadioButton.state = inIsrael ? .on : .off
        
        parshaCheckBox.state = Preference.showParsha.get() ? .on : .off
        omerCheckBox.state = Preference.showOmer.get() ? .on : .off
        cholHamoedCheckBox.state = Preference.showCholHamoed.get() ? .on : .off
    }
    
    static var suppressWarningMessage = false
    
    fileprivate func doubleCheckJulian() -> Bool {
        guard !PreferenceViewController.suppressWarningMessage else {
            return true
        }
        let today = todaysYearMonthDay(isJulian: true)
        let (jyear, jmonth, jday) = (today.year, today.month, today.day)
        let monthNames = DateFormatter().standaloneMonthSymbols!
        let date = "\(jday) \(monthNames[jmonth - 1]), \(jyear)"
        
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "Please don't use the Julian calendar unless you understand " +
            "the difference between the Gregorian and Julian calendar. " +
            "This option only makes sense for dates before 1927 in rare cases, and before " +
            "1582 in much of Europe.\n\n" +
            "Today's Julian date is \(date).  If you are confused, please hit 'cancel'."
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        alert.showsSuppressionButton = true
        
        let result = alert.runModal() == .alertSecondButtonReturn
        PreferenceViewController.suppressWarningMessage = alert.suppressionButton!.state == .on
        return result
    }
}
