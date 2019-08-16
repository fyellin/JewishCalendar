//
//  CalendarViewDataModel.swift
//  Jewish Calendar
//
//  Created by Frank Yellin on 8/16/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Foundation

struct DateInfo {
    let secularDay: Int
    let hebrewDay: Int
    let hebrewMonth: Int
    let hebrewYear : Int
    let holidays: [String]
}

class CalendarViewDataModel {
    let inIsrael = Preference.inIsrael.get()
    let showParsha = Preference.showParsha.get()
    let showChol = Preference.showCholHamoed.get()
    let showOmer = Preference.showOmer.get()
    let useJulian = Preference.useJulian.get()
    
    let currentYear : Int
    let currentMonth : Int
    let dayOfWeekFirst : DayOfWeek
    let dateInfoArray : [DateInfo]
    
    init(year: Int, month: Int) {
        currentYear = year
        currentMonth = month
        
        var result = DateResult(fromSecularYear: currentYear, month: currentMonth, day: 1, isJulian: useJulian)
        self.dayOfWeekFirst = DayOfWeek(from_absolute: result.absolute)

        var dateInfoArray = [DateInfo]()
        
        for secularDay in 1...result.secularMonthLength {
            if result.hebrewDay + (secularDay - result.secularDay) > result.hebrewMonthLength {
                let previousResult = result
                result = DateResult(fromSecularYear: currentYear, month: currentMonth, day: secularDay, isJulian: useJulian)
                assert(result.hebrewDay == 1)
                assert(result.absolute - result.secularDay == previousResult.absolute - previousResult.secularDay)
            }
            let offset = secularDay - result.secularDay
            let holidays = FindHolidays(
                year: result.hebrewYear, month: result.hebrewMonth, day: result.hebrewDay + offset,
                absolute: result.absolute + offset,
                kvia: result.kvia, leap_year_p: result.hebrew_leap_year_p, day_number: result.hebrewDayNumber + offset,
                inIsrael: inIsrael, showParsha: showParsha, showOmer: showOmer, showChol: showChol)
                // print(secular_day, result.hebrew_year, result.hebrew_month_name, hebrew_day, hebrew_day_number, holidays)
            let dateInfo = DateInfo(
                secularDay: secularDay, hebrewDay: result.hebrewDay + offset, hebrewMonth: result.hebrewMonth, hebrewYear: result.hebrewYear,
                holidays: holidays)
            dateInfoArray.append(dateInfo)
        }
        self.dateInfoArray = dateInfoArray
    }
}

