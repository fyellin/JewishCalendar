// JewishCalendarViewController.swift
// Copyright (c) 2019 Frank Yellin.

import Cocoa

/// This is the main view controller for the program.
///
/// The monthPicker and the yearEditor have bindings so that they always show currentMonth
/// and currentYear.
class JewishCalendarViewController: NSViewController {
  @IBOutlet var monthPicker: NSPopUpButton!
  @IBOutlet var calendarView: CalendarView!

  @IBOutlet var previousMonthButton: NSButton!
  @IBOutlet var nextMonthButton: NSButton!
  @IBOutlet var previousYearButton: NSButton!
  @IBOutlet var nextYearButton: NSButton!

  @IBOutlet var previousYearTouchBar: NSButton!
  @IBOutlet var nextYearTouchBar: NSButton!
  @IBOutlet var previousMonthTouchBar: NSButton!
  @IBOutlet var nextMonthTouchBar: NSButton!

  @IBOutlet var yearEditor: NSTextField!

  @objc dynamic var currentMonth = 0
  @objc dynamic var currentYear = 1
  @objc dynamic var minimumYear = 1000
  @objc dynamic var maximumYear = 3999
  @objc dynamic var longMonthNames = DateFormatter().standaloneMonthSymbols!

  override func viewDidLoad() {
    super.viewDidLoad()

    let color: NSColor
    if #available(OSX 10.14, *) {
      color = NSColor.textBackgroundColor
    } else {
      color = NSColor.white
    }
    view.layer?.backgroundColor = color.cgColor

    // I don't like how the year is completely selected, so this gives us a hook to turn it off.
    yearEditor.delegate = self

    goToToday(self)
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    turnOffSelectionOnYearEditor()
  }

  // MARK: Actions

  /// Called when currentMonth or currentYear changes because of a cocoa binding
  @IBAction func cocoaBindingChanged(_ sender: Any) {
    dataDidChange()
  }

  /// Called when asked to increment or decrement by a year or by a month.  The button's
  /// tag gives the delta in months.  This is also used by the touch bar buttons.
  @IBAction func changeMonthByDelta(_ sender: NSButton) {
    let delta = sender.tag
    assert(abs(delta) == 1 || abs(delta) == 12, "Delta must be one month or one year")
    let temp = currentYear * 12 + currentMonth + delta
    guard temp >= 1, temp <= 12 * (maximumYear + 1) else {
      print("Date out of range.  Button shouldn't have been highlighted")
      return
    }
    currentYear = (temp - 1) / 12
    currentMonth = temp - 12 * currentYear
    dataDidChange()
  }

  /// Called when the "today" button is clicked
  @IBAction func goToToday(_ sender: Any) {
    let calendar = SecularCalendar.forUsingJulian(Preference.useJulian.get())
    (currentYear, currentMonth, _) = todaysYearMonthDay(calendar)
    dataDidChange()
  }
  
  /// Called when the "today" button is clicked
  @IBAction func buttonPressed(_ sender: Any) {
    let calendar = SecularCalendar.forUsingJulian(Preference.useJulian.get())
    (currentYear, currentMonth, _) = todaysYearMonthDay(calendar)
    dataDidChange()
  }



  // MARK: Segues

  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    switch segue.identifier {
      case "presentPreferences":
        let destinationViewController = segue.destinationController as! PreferenceViewController
        destinationViewController.callbackOnChange = {
          self.dataDidChange()
        }
      case "presentHelp":
        // Nothing to do here
        break
      default:
        preconditionFailure("Unknown segue.  Should never reach here")
    }
  }

  // MARK: Cocoa bindings

  @objc dynamic var currentMonthSelectionIndex: Int {
    get { return currentMonth - 1 }
    set { currentMonth = newValue + 1 }
  }

  @objc dynamic var enablePreviousMonth: Bool {
    return (currentYear, currentMonth) > (minimumYear, 1)
  }

  @objc dynamic var enableNextMonth: Bool {
    return (currentYear, currentMonth) < (maximumYear, 12)
  }

  @objc dynamic var enablePreviousYear: Bool {
    return currentYear > minimumYear
  }

  @objc dynamic var enableNextYear: Bool {
    return currentYear < maximumYear
  }

  @objc dynamic var dataModel: [Int] { return [currentYear, currentMonth] }

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

/// This used to be required so that the TextView doesn't try to take over the touch bar.
/// It is no longer required, but we keep it around anyway, just in case it's needed in the
/// future.
extension NSTextView {
  @available(OSX 10.12.2, *)
  open override func makeTouchBar() -> NSTouchBar? {
    let touchBar = super.makeTouchBar()
    touchBar?.delegate = self
    return touchBar
  }
}

/// As a delegate, we modify the selection of the text every time we finish editing.
extension JewishCalendarViewController: NSTextFieldDelegate {
  func controlTextDidEndEditing(_ obj: Notification) {
    turnOffSelectionOnYearEditor()
  }
}

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
  static let lastYearItem = NSTouchBarItem.Identifier("com.jewcal.LastYear")
  static let lastMonthItem = NSTouchBarItem.Identifier("com.jewcal.LastMonth")
  static let nextYearItem = NSTouchBarItem.Identifier("com.jewcal.NextYear")
  static let nextMonthItem = NSTouchBarItem.Identifier("com.jewcal.NextMonth")
  static let todayItem = NSTouchBarItem.Identifier("com.jewcal.Today")

}

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
  static let touchBar = NSTouchBar.CustomizationIdentifier("com.jewcal.JewishCalendarViewController.touchbar")
}


@available(OSX 10.12.2, *)
extension JewishCalendarViewController: NSTouchBarDelegate {
  override func makeTouchBar() -> NSTouchBar? {
      let touchBar = NSTouchBar()
      touchBar.delegate = self
      touchBar.customizationIdentifier = .touchBar
    touchBar.defaultItemIdentifiers = [
      .todayItem, .fixedSpaceSmall,.lastYearItem, .lastMonthItem,
      .nextMonthItem, .nextYearItem, .flexibleSpace, .otherItemsProxy]
      return touchBar
  }
  
  func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) ->
    NSTouchBarItem? {
      let custom = NSCustomTouchBarItem(identifier: identifier)

      switch identifier {
      case NSTouchBarItem.Identifier.lastYearItem:
        let button = NSButton(image: NSImage(named: NSImage.touchBarRewindTemplateName)!,
                 target: self, action:#selector(changeMonthByDelta(_:)))
        button.tag = -12
        custom.view = button

      case NSTouchBarItem.Identifier.nextYearItem:
          let button = NSButton(image: NSImage(named: NSImage.touchBarFastForwardTemplateName)!,
                   target: self, action:#selector(changeMonthByDelta(_:)))
          button.tag = +12
          custom.view = button

      case NSTouchBarItem.Identifier.lastMonthItem:
        let button = NSButton(image: NSImage(named: NSImage.goBackTemplateName)!,
                 target: self, action:#selector(changeMonthByDelta(_:)))
        button.tag = -1
        custom.view = button

      case NSTouchBarItem.Identifier.nextMonthItem:
        let button = NSButton(image: NSImage(named: NSImage.goForwardTemplateName)!,
                 target: self, action:#selector(changeMonthByDelta(_:)))
        button.tag = +1
        custom.view = button

      case NSTouchBarItem.Identifier.todayItem:
        let button = NSButton(title: "Today", target: self, action: #selector(goToToday(_:)))
        custom.view = button

      default:
          return nil
      }
      return custom
  }
}
