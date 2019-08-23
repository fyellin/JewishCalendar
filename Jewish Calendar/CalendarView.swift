//
//  CalendarView.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/13/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa


@IBDesignable
class CalendarView: NSView {
    @IBInspectable
    var fontSize : CGFloat = 13

    static let shortDayNames = DateFormatter().shortWeekdaySymbols!
    
    let boldFontSizeMultiplier = CGFloat(1.2)
    let captionFontSizeMultiplier = CGFloat(1.4)

    var normalFont,weekdayFont, hebrewDateFont, captionFont: NSFont!
    
    func modifyFont(_ sender: NSMenuItem) {
        switch (sender.tag) {
        case 3:
            fontSize += 1
        case 4:
            fontSize = max(5, fontSize - 1)
        default:
            break
        }
        print("Set Font Size = \(fontSize)")
        needsDisplay = true
    }
    
    var dataModel : CalendarViewDataModel? = nil {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        normalFont = NSFont.systemFont(ofSize: fontSize)
        hebrewDateFont = NSFont.boldSystemFont(ofSize: fontSize)
        weekdayFont = NSFont.boldSystemFont(ofSize: fontSize * boldFontSizeMultiplier)
        captionFont = NSFont.boldSystemFont(ofSize: fontSize * captionFontSizeMultiplier)
        
        let captionBottom = bounds.maxY - captionFont.pointSize - 4

        let weekdayInfoBottom = captionBottom - weekdayFont.pointSize - 8
        
        let dateInfoTop = weekdayInfoBottom - 6
        let dateInfoBottom = CGFloat(2.0)
        let dateInfoHeight = (dateInfoTop - dateInfoBottom) / 6
        
        let dateInfoLeft = CGFloat(2.0)
        let dateInfoRight = self.bounds.maxX - 2
        let dateInfoWidth = (dateInfoRight - dateInfoLeft) / 7
        
        var rectArray = [NSRect]()
        for row in 0...5 {
            for column in 0...6 {
                let rect = NSRect(x: dateInfoLeft + CGFloat(column) * dateInfoWidth,
                                  y: dateInfoTop - CGFloat(row + 1) * dateInfoHeight,
                                  width: dateInfoWidth, height: dateInfoHeight)
                rectArray.append(rect)
            }
        }
        
        // Draw the banner
        drawCenteredAt(getBanner(), NSPoint(x: bounds.midX, y: captionBottom), captionFont)
        
        // Draw the weekdays
        for (i, dayName) in CalendarView.shortDayNames.enumerated() {
            drawCenteredAt(dayName, NSPoint(x: rectArray[i].midX, y: weekdayInfoBottom), weekdayFont)
        }
        
        let dayOfWeekStart = dataModel!.dayOfWeekFirst.rawValue
        let dateInfoArray = dataModel!.dateInfoArray
        for (i, dateInfo) in dateInfoArray.enumerated() {
            let rect = rectArray[i + dayOfWeekStart]
            drawOneDay(i + 1, rect, dateInfo)
        }
    }
    
    enum Justification {
        case left, center, right
    }
    
    private func drawOneDay(_ dayOfMonth: Int, _ rect: NSRect, _ dateInfo: DateInfo) {
        NSBezierPath(rect: rect).stroke()
        let irect = rect.insetBy(dx: 1.0, dy: 1.0)
        let lineSpacing = irect.height / (4 + boldFontSizeMultiplier)
        let top = irect.maxY - (boldFontSizeMultiplier * lineSpacing)
        
        
        let secularDayString = String(dayOfMonth)
        let hebrewDayString = "\(dateInfo.hebrewDay) \(hebrewMonthNameOf(dateInfo))"
        let holidays = dateInfo.holidays
        drawCenteredAt(secularDayString, NSPoint(x: irect.midX, y: top), weekdayFont)
        drawCenteredAt(hebrewDayString, NSPoint(x: irect.midX, y: top - lineSpacing), hebrewDateFont)
        
        guard !holidays.isEmpty else { return }
        var lines = holidays.map{(text: $0, justification: Justification.center)}
        for i in (0..<lines.count).reversed() {
            let holiday = lines[i].text
            if stringWidth(holiday) > irect.width {
                if lines.count < 3 && holiday.contains("/") {
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
                } else if lines.count < 3 && holiday.contains(" ") {
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
                drawLeftAt(String(line.text),
                           NSPoint(x: irect.minX, y: top - CGFloat(i + 2) * lineSpacing))
            case .right:
                drawRightAt(String(line.text),
                            NSPoint(x: irect.maxX, y: top - CGFloat(i + 2) * lineSpacing))
            case .center:
                drawCenteredAt(line.text, NSPoint(x: irect.midX, y: top - CGFloat(i + 2) * lineSpacing))

            }
        }
    }
    
    private func drawCenteredAt(_ text: String, _ point: NSPoint, _ font: NSFont? = nil, _ color: NSColor? = nil) {
        let font = font ?? normalFont!
        let color = color ?? NSColor.textColor
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: color]
        let stringWidth = text.size(withAttributes: attributes).width
        let startPoint = NSPoint(x: point.x - stringWidth / 2, y: point.y)
        text.draw(at: startPoint, withAttributes: attributes)
    }
    
    private func drawLeftAt(_ text: String, _ point: NSPoint, _ font: NSFont? = nil) {
        let font = font ?? normalFont!
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor]
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func drawRightAt(_ text: String, _ point: NSPoint, _ font: NSFont? = nil) {
        let font = font ?? normalFont!
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font,
            .foregroundColor: NSColor.labelColor]
        let stringWidth = text.size(withAttributes: attributes).width
        let startPoint = NSPoint(x: point.x - stringWidth, y: point.y)
        text.draw(at: startPoint, withAttributes: attributes)
    }
    
    private func stringWidth(_ text: String, _ font: NSFont? = nil) -> CGFloat {
        let font = font ?? normalFont!
        let attributes : [NSAttributedString.Key : Any] = [.font: font]
        let stringWidth = text.size(withAttributes: attributes).width
        return stringWidth
    }
    

    override func prepareForInterfaceBuilder() {
        dataModel = CalendarViewDataModel(year: 2027, month: 1)
    }
    
    func getBanner() -> String {
        let firstDay = dataModel!.dateInfoArray.first!
        let lastDay = dataModel!.dateInfoArray.last!
        let startBanner : String
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
    
    private let HebrewMonthNames = [
        "",
        "Nissan", "Iyar", "Sivan", "Tamuz", "Ab", "Elul",
        "Tishrei", "Cheshvan", "Kislev", "Tevet", "Shvat", "Adar I", "Adar II", "Adar"
    ]
    
    private func hebrewMonthNameOf(_ dateInfo: DateInfo)  -> String{
        let hebrewMonthName = ((dateInfo.hebrewMonth < 12) || isLeapYear(hebrewYear: dateInfo.hebrewYear)) ?
            HebrewMonthNames[dateInfo.hebrewMonth] :
            HebrewMonthNames[14]
        return hebrewMonthName

    }
}
