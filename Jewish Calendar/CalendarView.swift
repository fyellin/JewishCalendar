// CalendarView.swift
// Copyright (c) 2019 Frank Yellin.

import Cocoa

/// This class is responsible for showing the calendar view that fills most of the lower half
/// of the user's screen
@IBDesignable
class CalendarView: NSView {
  /// The following two fields are our complete data model.

  var dataModel: CalendarViewDataModel? {
    didSet { needsDisplay = true }
  }

  @IBInspectable
  private var fontSize: CGFloat = 13 {
    didSet { needsDisplay = true }
  }

  private enum Constants {
    /// The names of the weekdays
    static let shortDayNames = DateFormatter().shortWeekdaySymbols!
    /// How much bigger the font showing the weeksdays should be
    static let weekdayFontSizeMultiplier = CGFloat(1.2)
    /// How much bigger the font showing the caption should be
    static let captionFontSizeMultiplier = CGFloat(1.4)
    static let HebrewMonthNames = [
      "",
      "Nissan", "Iyar", "Sivan", "Tamuz", "Ab", "Elul",
      "Tishrei", "Cheshvan", "Kislev", "Tevet", "Shvat", "Adar I", "Adar II", "Adar"
    ]
  }

  /// Called from the AppDelegate what the user clicks to change the size of the menu
  func modifyFont(_ sender: NSMenuItem) {
    switch sender.tag {
      case 3:
        fontSize += 1
      case 4:
        fontSize = max(5, fontSize - 1)
      default:
        break
    }
    needsDisplay = true
  }

  private var normalFont, weekdayFont, hebrewDateFont, captionFont: NSFont!

  private var fakeTodayFromInterfaceBuilder: YearMonthDay?

  private var today: YearMonthDay!

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    normalFont = NSFont.systemFont(ofSize: fontSize)
    hebrewDateFont = NSFont.boldSystemFont(ofSize: fontSize)
    weekdayFont = NSFont.boldSystemFont(ofSize: fontSize * Constants.weekdayFontSizeMultiplier)
    captionFont = NSFont.boldSystemFont(ofSize: fontSize * Constants.captionFontSizeMultiplier)

    today = fakeTodayFromInterfaceBuilder ?? dataModel!.getToday()

    let captionBottom = bounds.maxY - captionFont.pointSize - 4

    let weekdayInfoBottom = captionBottom - weekdayFont.pointSize - 8

    let dateInfoTop = weekdayInfoBottom - 6
    let dateInfoBottom = CGFloat(2.0)
    let dateInfoHeight = (dateInfoTop - dateInfoBottom) / 6

    let dateInfoLeft = CGFloat(2.0)
    let dateInfoRight = bounds.maxX - 2
    let dateInfoWidth = (dateInfoRight - dateInfoLeft) / 7

    // Divide the grid into a 6x7 array
    var rectArray = [NSRect]()
    for row in 0...5 {
      for column in 0...6 {
        let rect = NSRect(
          x: dateInfoLeft + CGFloat(column) * dateInfoWidth,
          y: dateInfoTop - CGFloat(row + 1) * dateInfoHeight,
          width: dateInfoWidth, height: dateInfoHeight)
        rectArray.append(rect)
      }
    }

    // Draw the banner
    drawCenteredAt(getBanner(), NSPoint(x: bounds.midX, y: captionBottom), captionFont)

    // Draw the weekdays
    for (i, dayName) in Constants.shortDayNames.enumerated() {
      drawCenteredAt(dayName, NSPoint(x: rectArray[i].midX, y: weekdayInfoBottom), weekdayFont)
    }

    // Draw the calendar entries
    let dateResultArray = dataModel!.dateResultMonthArray
    let dayOfWeekStart = dateResultArray[0].dayOfWeek.rawValue
    for (i, dateResult) in dateResultArray.enumerated() {
      let rect = rectArray[i + dayOfWeekStart]
      drawOneDay(i + 1, rect, dateResult)
    }
  }

  enum Justification {
    case left, center, right
  }

  private func drawOneDay(_ dayOfMonth: Int, _ rect: NSRect, _ dateResult: DateResult) {
    assert(dayOfMonth == dateResult.secularDay)
    NSBezierPath(rect: rect).stroke()
    if (dateResult.secularYear, dateResult.secularMonth, dateResult.secularDay) == today! {
      // NSGraphicsContext.saveGraphicsState()
      if #available(OSX 10.14, *) {
        NSColor.selectedTextBackgroundColor.set()
      } else {
        #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).set()
      }
      NSBezierPath(rect: rect).fill()
      // NSGraphicsContext.restoreGraphicsState()
    }
    let irect = rect.insetBy(dx: 1.0, dy: 1.0)
    let lineSpacing = irect.height / (4 + Constants.weekdayFontSizeMultiplier)
    let top = irect.maxY - (Constants.weekdayFontSizeMultiplier * lineSpacing)
    let secularDayString = String(dayOfMonth)
    let hebrewDayString = "\(dateResult.hebrewDay) \(hebrewMonthNameOf(dateResult))"
    let holidays = dataModel!.getHolidaysFor(dateResult: dateResult)
    drawCenteredAt(secularDayString, NSPoint(x: irect.midX, y: top), weekdayFont)
    drawCenteredAt(hebrewDayString, NSPoint(x: irect.midX, y: top - lineSpacing), hebrewDateFont)

    guard !holidays.isEmpty else { return }
    var lines = holidays.map { (text: $0, justification: Justification.center) }
    for i in (0..<lines.count).reversed() {
      let holiday = lines[i].text
      if stringWidth(holiday) > irect.width {
        if lines.count < 3, holiday.contains("/") {
          let slashIndex = holiday.firstIndex(of: "/")!
          let prefix = String(holiday[...slashIndex])
          let suffix = String(holiday[holiday.index(after: slashIndex)...])
          lines[i] = (text: prefix, justification: .left)
          lines.insert((text: suffix, justification: .right), at: i + 1)
        } else if holiday.starts(with: "Yom ") {
          lines[i].text = holiday.replacingOccurrences(of: "Yom", with: "Y. ")
        } else if holiday.starts(with: "Rosh ") {
          lines[i].text = holiday.replacingOccurrences(of: "Rosh", with: "R. ")
        } else if holiday.contains("evening") {
          lines[i].text = holiday.replacingOccurrences(of: "evening", with: "even.")
        } else if lines.count < 3, holiday.contains(" ") {
          let spaceIndex = holiday.firstIndex(of: " ")!
          let prefix = String(holiday[..<spaceIndex])
          let suffix = String(holiday[holiday.index(after: spaceIndex)...])
          lines[i] = (text: prefix, justification: .left)
          lines.insert((text: suffix, justification: .right), at: i + 1)
        }
      }
    }
    for (i, line) in lines.enumerated() {
      switch line.justification {
        case .left:
          drawLeftAt(
            String(line.text),
            NSPoint(x: irect.minX, y: top - CGFloat(i + 2) * lineSpacing))
        case .right:
          drawRightAt(
            String(line.text),
            NSPoint(x: irect.maxX, y: top - CGFloat(i + 2) * lineSpacing))
        case .center:
          drawCenteredAt(line.text, NSPoint(x: irect.midX, y: top - CGFloat(i + 2) * lineSpacing))
      }
    }
  }

  /// Draws the text centered at the specified point.  Optionally specify font and color
  private func drawCenteredAt(
    _ text: String, _ point: NSPoint, _ font: NSFont? = nil, _ color: NSColor? = nil) {
    let attributedText = NSAttributedString(string: text, attributes: [
      .font: font ?? normalFont!,
      .foregroundColor: color ?? NSColor.textColor
    ])
    let width = attributedText.size().width
    attributedText.draw(at: NSPoint(x: point.x - width / 2, y: point.y))
  }

  /// Draws the text left justified at the specified point.  Optionally specify font and color
  private func drawLeftAt(
    _ text: String, _ point: NSPoint, _ font: NSFont? = nil, _ color: NSColor? = nil) {
    let attributedText = NSAttributedString(string: text, attributes: [
      .font: font ?? normalFont!,
      .foregroundColor: color ?? NSColor.textColor
    ])
    attributedText.draw(at: point)
  }

  /// Draws the text with its right end at the specified point.  Optionally specify font and color
  private func drawRightAt(
    _ text: String, _ point: NSPoint, _ font: NSFont? = nil, _ color: NSColor? = nil) {
    let attributedText = NSAttributedString(string: text, attributes: [
      .font: font ?? normalFont!,
      .foregroundColor: color ?? NSColor.textColor
    ])
    let width = attributedText.size().width
    text.draw(at: NSPoint(x: point.x - width, y: point.y))
  }

  /// Returns the width of the string in the specified font.
  private func stringWidth(_ text: String, _ font: NSFont? = nil) -> CGFloat {
    let font = font ?? normalFont!
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let stringWidth = text.size(withAttributes: attributes).width
    return stringWidth
  }

  /// Returns the banner that should be displayed at the top of the calendar
  private func getBanner() -> String {
    let firstDay = dataModel!.dateResultMonthArray.first!
    let lastDay = dataModel!.dateResultMonthArray.last!
    let startBanner: String
    if firstDay.hebrewMonth == lastDay.hebrewMonth {
      startBanner = "\(firstDay.hebrewDay)"
    } else if firstDay.hebrewYear == lastDay.hebrewYear {
      startBanner = "\(firstDay.hebrewDay) \(hebrewMonthNameOf(firstDay))"
    } else {
      startBanner = "\(firstDay.hebrewDay) \(hebrewMonthNameOf(firstDay)) \(firstDay.hebrewYear)"
    }
    let endBanner = "\(lastDay.hebrewDay) \(hebrewMonthNameOf(lastDay)) \(lastDay.hebrewYear)"
    return "\(startBanner) — \(endBanner)"
  }

  /// Returns the name of the Hebrew month
  private func hebrewMonthNameOf(_ dateResult: DateResult) -> String {
    let hebrewMonthName = ((dateResult.hebrewMonth < 12) || dateResult.isHebrewLeapYear) ?
      Constants.HebrewMonthNames[dateResult.hebrewMonth] :
      Constants.HebrewMonthNames[14]
    return hebrewMonthName
  }

  /// Allows us to see a sample date in the storyboard
  override func prepareForInterfaceBuilder() {
    dataModel = CalendarViewDataModel(year: 2027, month: 1)
    fakeTodayFromInterfaceBuilder = (2027, 1, 18)
  }
}
