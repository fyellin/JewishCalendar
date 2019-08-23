//
//  Testing.swift
//  Jewish Calendar
//
//  Created by Frank Yellin on 8/26/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

/*****
 5780 120 Monday long false
 5781 600 Saturday short false
 5782 211 Tuesday normal true
 5784 601 Saturday short true
 5785 420 Thursday long false
 5786 210 Tuesday normal false
 5787 621 Saturday long true
 5788 620 Saturday long false
 5789 410 Thursday normal false
 5790 101 Monday short true
 5795 421 Thursday long true
 5797 100 Monday short false
 5803 121 Monday long true
 5812 401 Thursday short true
 ******/
func printGoldenInformation() {
    let fileName = "Testing3.1"
    var fh = FileHandle(forWritingAtPath: fileName)
    if fh == nil {
        FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
        fh = FileHandle(forWritingAtPath: fileName)!
    }
    defer {
        fh?.closeFile()
    }
    let isJulian = false
    let years = [5780, 5781, 5782, 5784, 5785, 5786, 5787, 5788, 5789, 5790, 5795, 5797, 5803, 5812]
    for year in years {
        let yearStart = absoluteFromHebrew(year, 7, 1)
        let yearEnd = absoluteFromHebrew(year + 1, 7, 1)
        print(year, yearStart, yearEnd)
        for absolute in yearStart ..< yearEnd {
            let dr = DateResult(fromAbsolute: absolute, isJulian: isJulian)
            assert(dr.absolute == absolute)
            assert(dr.hebrewYear == year)
            assert(absolute == absoluteFromHebrew(year, dr.hebrewMonth, dr.hebrewDay))
            assert(absolute == absoluteFromSecular(dr.secularYear, dr.secularMonth, dr.secularDay, isJulian))
            assert(dr.hebrewDayNumber == absolute - yearStart + 1)
            let a = FindHolidays(year: dr.hebrewYear, month: dr.hebrewMonth, day: dr.hebrewDay,
                                 absolute: absolute, kvia: dr.kvia, isLeapYear: dr.isHebrewLeapYear,
                                 dayNumber: dr.hebrewDayNumber,
                                 inIsrael: false, showParsha: true, showOmer: true, showChol: true)
            let b = FindHolidays(year: dr.hebrewYear, month: dr.hebrewMonth, day: dr.hebrewDay,
                                 absolute: absolute, kvia: dr.kvia, isLeapYear: dr.isHebrewLeapYear,
                                 dayNumber: dr.hebrewDayNumber,
                                 inIsrael: true, showParsha: true, showOmer: true, showChol: true)
            var output = """
            \(absolute) \(dr.hebrewDayNumber) \(dr.hebrewYear) \(dr.hebrewMonth) \(dr.hebrewDay) \
            \(dr.secularYear) \(dr.secularMonth) \(dr.secularDay) \(dr.secularMonthLength) \(dr.secularMonthLength) \(a)
            """
            if a != b {
                output = "\(output) \(b)\n"
            } else {
                output = output + "\n"
            }
            fh!.write(Data(output.utf8))
        }
    }
}
