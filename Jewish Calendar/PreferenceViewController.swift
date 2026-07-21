// PreferenceViewController.swift
// Copyright (c) 2019 Frank Yellin.

import Cocoa

class PreferenceViewController: NSViewController {
    @IBOutlet var parshaCheckBox: NSButton!
    @IBOutlet var cholHamoedCheckBox: NSButton!
    @IBOutlet var omerCheckBox: NSButton!

    @IBOutlet var diasporaRadioButton: NSButton!
    @IBOutlet var israelRadioButton: NSButton!

    @IBOutlet var gregorianRadioButton: NSButton!
    @IBOutlet var julianRadioButton: NSButton!

    /// Call this method whenever a change is made to the preferences
    var callbackOnChange: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateChoices()
    }

    @IBAction func parshaButtonPushed(_ sender: NSButton) {
        Preferences.showParsha.toggle()
        callbackOnChange?()
    }

    @IBAction func cholHamoedButtonPushed(_ sender: NSButton) {
        Preferences.showCholHamoed.toggle()
        callbackOnChange?()
    }

    @IBAction func omerButtonPushed(_ sender: NSButton) {
        Preferences.showOmer.toggle()
        callbackOnChange?()
    }

    @IBAction func locationButtonPushed(_ sender: NSButton) {
        Preferences.inIsrael = sender.tag == 1
        callbackOnChange?()
    }

    @IBAction func calendarButtonPushed(_ sender: NSButton) {
        if sender.tag == 1 {
            guard doubleCheckJulian() else {
                updateChoices()
                return
            }
        }
        Preferences.useJulian = sender.tag == 1
        callbackOnChange?()
    }

    private func updateChoices() {
        let useJulian = Preferences.useJulian
        gregorianRadioButton.state = useJulian ? .off : .on
        julianRadioButton.state = useJulian ? .on : .off

        let inIsrael = Preferences.inIsrael
        diasporaRadioButton.state = inIsrael ? .off : .on
        israelRadioButton.state = inIsrael ? .on : .off

        parshaCheckBox.state = Preferences.showParsha ? .on : .off
        omerCheckBox.state = Preferences.showOmer ? .on : .off
        cholHamoedCheckBox.state = Preferences.showCholHamoed ? .on : .off
    }

    private static var suppressWarningMessage = false

    private func doubleCheckJulian() -> Bool {
        guard !PreferenceViewController.suppressWarningMessage else {
            return true
        }
        let today = SecularCalendar.julian.today()
        let monthNames = DateFormatter().standaloneMonthSymbols!
        let date = "\(today.day) \(monthNames[today.month - 1]), \(today.year)"

        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = """
        Clicking here is probably a mistake. \
        Please don't use this option unless you understand the difference between \
        the Gregorian and the Julian calendar.\n
        Most of Europe switched from the Julian to the Gregorian calendar in 1582, \
        Great Britain (including its American colonies) switched in 1752, \
        and Turkey in 1926.\n
        Today's date in the Julian calendar is \(date).  If you are confused, please hit 'Cancel'.
        """
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        alert.showsSuppressionButton = true

        let result = alert.runModal() == .alertSecondButtonReturn
        PreferenceViewController.suppressWarningMessage = alert.suppressionButton!.state == .on
        return result
    }
}
