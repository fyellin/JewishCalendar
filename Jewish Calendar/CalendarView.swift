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
    
    static let fontSize = CGFloat(10)
    
    static let shortDayNames = DateFormatter().shortWeekdaySymbols!
    static let normalFont = NSFont.systemFont(ofSize: fontSize)
    static let boldFont = NSFont.boldSystemFont(ofSize: fontSize)
    
    static let captionFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
    
    var dataModel : CalendarViewDataModel? = nil {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let captionTop = self.bounds.maxY
        let captionBottom = captionTop - 20
        
        let weekdayInfoTop = captionBottom
        let weekdayInfoBottom = weekdayInfoTop - 30
        
        let dateInfoTop = weekdayInfoBottom - 4
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
        
        let absoluteStart = dataModel!.dayOfWeekFirst.rawValue
        let dateInfoArray = dataModel!.dateInfoArray
        
        let width = self.bounds.width
        
        drawCenteredAt(getBanner(), NSPoint(x: bounds.midX, y: captionBottom), CalendarView.captionFont)
        
        for i in 0...6 {
            let centerX = (CGFloat(i) + 0.5) * width / 7
            let text = CalendarView.shortDayNames[i]
            drawCenteredAt(text, NSPoint(x: centerX, y: weekdayInfoBottom), CalendarView.boldFont)
        }
        
        let dayOfWeekStart = (7 + absoluteStart) % 7
        for (i, dateInfo) in dateInfoArray.enumerated() {
            let rect = rectArray[i + dayOfWeekStart]
            drawOneDay(i + 1, rect, dateInfo)
        }
    }
    
    private func drawOneDay(_ dayOfMonth: Int, _ rect: NSRect, _ dateInfo: DateInfo) {
        NSBezierPath(rect: rect).stroke()
        let irect = rect.insetBy(dx: 1.0, dy: 2.0)
        let lineSpacing = irect.height / CGFloat(5)
        let top = irect.maxY
        
        let secularDayString = String(dayOfMonth)
        let hebrewDayString = "\(dateInfo.hebrewDay) \(hebrewMonthNameOf(dateInfo))"
        let holidays = dateInfo.holidays
        drawCenteredAt(secularDayString, NSPoint(x: irect.midX, y: top - lineSpacing), CalendarView.boldFont)
        drawCenteredAt(hebrewDayString, NSPoint(x: irect.midX, y: top - 2 * lineSpacing))
        for (i, holiday) in holidays.enumerated() {
            drawCenteredAt(holiday, NSPoint(x: irect.midX, y: top - CGFloat(i + 3) * lineSpacing))
        }
    }
    
    private func drawCenteredAt(_ text: String, _ point: NSPoint, _ font: NSFont = CalendarView.normalFont) {
        let attributes = [NSAttributedString.Key.font: font,
                          NSAttributedString.Key.foregroundColor: NSColor.labelColor]
        let stringWidth = text.size(withAttributes: attributes).width
        let startPoint = NSPoint(x: point.x - stringWidth / 2, y: point.y)
        text.draw(at: startPoint, withAttributes: attributes)
    }
    
    override func prepareForInterfaceBuilder() {
        dataModel = CalendarViewDataModel(year: 2019, month: 12)
    }
    
    func getBanner() -> String {
        let firstDay = dataModel!.dateInfoArray.first!
        let lastDay = dataModel!.dateInfoArray.last!
        let startBanner : String
        if firstDay.hebrewMonth == lastDay.hebrewMonth {
            // must be February!
            startBanner = "\(firstDay.hebrewDay)"
        } else if firstDay.hebrewYear == lastDay.hebrewYear {
            startBanner = "\(firstDay.hebrewDay) \(hebrewMonthNameOf(firstDay))"
        } else {
            startBanner = "\(firstDay.hebrewDay) \(hebrewMonthNameOf(firstDay)) \(firstDay.hebrewYear)"
        }
        let endBanner = "\(lastDay.hebrewDay) \(hebrewMonthNameOf(lastDay)) \(lastDay.hebrewYear)"
        return  "\(startBanner) — \(endBanner)"
    }
    
    private let HebrewMonthNames = [
        "",
        "Nissan", "Iyar", "Sivan", "Tamuz", "Ab", "Elul",
        "Tishrei", "Cheshvan", "Kislev", "Tevet", "Shvat", "Adar I", "Adar II", "Adar"
    ]
    
    private func hebrewMonthNameOf(_ dateInfo: DateInfo)  -> String{
        let hebrewMonthName = ((dateInfo.hebrewMonth < 12) || isHebrewLeapYear(dateInfo.hebrewYear)) ?
            HebrewMonthNames[dateInfo.hebrewMonth] :
            HebrewMonthNames[14]
        return hebrewMonthName

    }
}
