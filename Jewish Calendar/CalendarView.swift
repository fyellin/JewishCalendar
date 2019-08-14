//
//  CalendarView.swift
//  MyFirstApplication
//
//  Created by Frank Yellin on 8/13/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa

struct DateInfo {
    let secularDay: Int
    let hebrewDay: Int
    let hebrewMonth: Int
    let hebrewMonthName: String
    let holidays: [String]
}

@IBDesignable
class CalendarView: NSView {
    
    static let fontSize = CGFloat(10)
    
    static let shortDayNames = DateFormatter().shortWeekdaySymbols!
    static let normalFont = NSFont.systemFont(ofSize: fontSize)
    static let boldFont = NSFont.boldSystemFont(ofSize: fontSize)
    
    var dateInfoArray = [DateInfo]()
    var absoluteStart = 0
    
    func updateView(dateInfoArray: [DateInfo], absoluteStart: Int) {
        self.dateInfoArray = dateInfoArray
        self.absoluteStart = absoluteStart
        self.needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let weekdayInfoTop = self.bounds.maxY
        let weekdayInfoBottom = weekdayInfoTop - 20
        
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
        
        let topLeft = self.bounds.maxY
        let width = self.bounds.width
        
        for i in 0...6 {
            let centerX = (CGFloat(i) + 0.5) * width / 7
            let text = CalendarView.shortDayNames[i]
            drawCenteredAt(text, NSPoint(x: centerX, y: topLeft - 20), CalendarView.boldFont)
        }
        
        let dayOfWeekStart = (7 + absoluteStart) % 7
        for (i, dateInfo) in dateInfoArray.enumerated() {
            let rect = rectArray[i + dayOfWeekStart]
            drawOneDay(i + 1, rect, dateInfo)
        }
    }
    
    func drawOneDay(_ dayOfMonth: Int, _ rect: NSRect, _ dateInfo: DateInfo) {
        NSBezierPath(rect: rect).stroke()
        let irect = rect.insetBy(dx: 1.0, dy: 2.0)
        let lineSpacing = irect.height / CGFloat(5)
        let top = irect.maxY
        
        let secularDayString = String(dayOfMonth)
        let hebrewDayString = "\(dateInfo.hebrewDay) \(dateInfo.hebrewMonthName)"
        let holidays = dateInfo.holidays
        drawCenteredAt(secularDayString, NSPoint(x: irect.midX, y: top - lineSpacing), CalendarView.boldFont)
        drawCenteredAt(hebrewDayString, NSPoint(x: irect.midX, y: top - 2 * lineSpacing))
        for (i, holiday) in holidays.enumerated() {
            drawCenteredAt(holiday, NSPoint(x: irect.midX, y: top - CGFloat(i + 3) * lineSpacing))
        }
    }
    
    func drawCenteredAt(_ text: String, _ point: NSPoint, _ font: NSFont = CalendarView.normalFont) {
        let attributes = [NSAttributedString.Key.font: font]
        let stringWidth = text.size(withAttributes: attributes).width
        let startPoint = NSPoint(x: point.x - stringWidth / 2, y: point.y)
        text.draw(at: startPoint, withAttributes: attributes)
    }
    
}
