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
    static let shortDayNames = DateFormatter().shortWeekdaySymbols!
    
    let boldFontSizeMultiplier = CGFloat(1.2)
    let captionFontSizeMultiplier = CGFloat(1.4)

    var fontSize : CGFloat!
    var normalFont, boldFont, captionFont: NSFont!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    private func initialize() {
        addObserver(NSFontManager.shared, forKeyPath: "selectedFont", options: [.new], context: nil)
    }
        
    var dataModel : CalendarViewDataModel? = nil {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        fontSize = NSFontManager.shared.selectedFont?.pointSize ?? 13
        normalFont = NSFont.systemFont(ofSize: fontSize)
        boldFont = NSFont.boldSystemFont(ofSize: fontSize * boldFontSizeMultiplier)
        captionFont = NSFont.boldSystemFont(ofSize: fontSize * captionFontSizeMultiplier)
        
        let captionTop = self.bounds.maxY
        let captionBottom = captionTop - captionFont.pointSize - 4

        let weekdayInfoTop = captionBottom
        let weekdayInfoBottom = weekdayInfoTop - boldFont.pointSize - 5
        
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
        
        drawCenteredAt(getBanner(), NSPoint(x: bounds.midX, y: captionBottom), captionFont)
        for (i, dayName) in CalendarView.shortDayNames.enumerated() {
            drawCenteredAt(dayName, NSPoint(x: rectArray[i].midX, y: weekdayInfoBottom), boldFont)
        }
        
        let dayOfWeekStart = dataModel!.dayOfWeekFirst.rawValue
        let dateInfoArray = dataModel!.dateInfoArray
        for (i, dateInfo) in dateInfoArray.enumerated() {
            let rect = rectArray[i + dayOfWeekStart]
            drawOneDay(i + 1, rect, dateInfo)
        }
    }
    
    private func drawOneDay(_ dayOfMonth: Int, _ rect: NSRect, _ dateInfo: DateInfo) {
        NSBezierPath(rect: rect).stroke()
        let irect = rect.insetBy(dx: 1.0, dy: 2.0)
        let lineSpacing = irect.height / (4 + boldFontSizeMultiplier)
        let top = irect.maxY - (boldFontSizeMultiplier * lineSpacing)
        
        let secularDayString = String(dayOfMonth)
        let hebrewDayString = "\(dateInfo.hebrewDay) \(hebrewMonthNameOf(dateInfo))"
        let holidays = dateInfo.holidays
        drawCenteredAt(secularDayString, NSPoint(x: irect.midX, y: top), boldFont)
        drawCenteredAt(hebrewDayString, NSPoint(x: irect.midX, y: top - lineSpacing))
        for (i, holiday) in holidays.enumerated() {
            if holiday.contains("/") && holidays.count < 3 {
                if stringWidth(holiday) > irect.width {
                    let slashIndex = holiday.firstIndex(of: "/")!
                    let prefix = String(holiday[...slashIndex])
                    let suffix = String(holiday[holiday.index(after: slashIndex)...])
                    drawLeftAt(String(prefix),
                               NSPoint(x: irect.minX, y: top - CGFloat(i + 2) * lineSpacing))
                    drawRightAt(String(suffix),
                                NSPoint(x: irect.maxX, y: top - CGFloat(i + 3) * lineSpacing))
                    continue
                }
            }
            drawCenteredAt(holiday, NSPoint(x: irect.midX, y: top - CGFloat(i + 2) * lineSpacing))
        }
    }
    
    private func drawCenteredAt(_ text: String, _ point: NSPoint, _ font: NSFont? = nil) {
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font ?? normalFont!,
            .foregroundColor: NSColor.labelColor]
        let stringWidth = text.size(withAttributes: attributes).width
        let startPoint = NSPoint(x: point.x - stringWidth / 2, y: point.y)
        text.draw(at: startPoint, withAttributes: attributes)
    }
    
    private func drawLeftAt(_ text: String, _ point: NSPoint, _ font: NSFont? = nil) {
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font ?? normalFont!,
            .foregroundColor: NSColor.labelColor]
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func drawRightAt(_ text: String, _ point: NSPoint, _ font: NSFont? = nil) {
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font ?? normalFont!,
            .foregroundColor: NSColor.labelColor]
        let stringWidth = text.size(withAttributes: attributes).width
        let startPoint = NSPoint(x: point.x - stringWidth, y: point.y)
        text.draw(at: startPoint, withAttributes: attributes)
    }
    
    private func stringWidth(_ text: String, _ font: NSFont? = nil) -> CGFloat {
        let attributes : [NSAttributedString.Key : Any] = [
            .font: font ?? normalFont!,
            .foregroundColor: NSColor.labelColor]
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
        let hebrewMonthName = ((dateInfo.hebrewMonth < 12) || isHebrewLeapYear(dateInfo.hebrewYear)) ?
            HebrewMonthNames[dateInfo.hebrewMonth] :
            HebrewMonthNames[14]
        return hebrewMonthName

    }
}
