// MonthGridView.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The month grid: a banner giving the Hebrew date range, a weekday header,
/// and six rows of day cells.
struct MonthGridView: View {
    let month: CalendarMonth
    let fontSize: Double

    private static let weekdayNames = DateFormatter().shortWeekdaySymbols!

    var body: some View {
        let cells = self.cells
        let today = month.today
        VStack(spacing: 6) {
            Text(banner)
                .font(.system(size: fontSize * 1.4, weight: .bold))

            HStack(spacing: 0) {
                ForEach(Self.weekdayNames, id: \.self) { name in
                    Text(name)
                        .font(.system(size: fontSize * 1.2, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(spacing: 0) {
                ForEach(0..<6) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7) { column in
                            let day = cells[row * 7 + column]
                            DayCellView(
                                day: day,
                                holidays: day.map { month.holidays(on: $0) } ?? [],
                                isToday: day?.secularDate == today,
                                fontSize: fontSize)
                        }
                    }
                }
            }
        }
    }

    /// The days of the month, padded with empty cells to fill a 6-by-7 grid
    /// aligned on weekdays.
    private var cells: [CalendarDay?] {
        var cells = Array(repeating: CalendarDay?.none, count: month.days[0].weekday.rawValue)
        cells += month.days.map(Optional.init)
        cells += Array(repeating: nil, count: 42 - cells.count)
        return cells
    }

    /// The range of Hebrew dates covered by this secular month, such as
    /// "6 Tamuz — 7 Ab 5786".
    private var banner: String {
        let firstDay = month.days.first!
        let lastDay = month.days.last!
        let startBanner: String
        if firstDay.hebrewDate.month == lastDay.hebrewDate.month {
            startBanner = "\(firstDay.hebrewDate.day)"
        } else if firstDay.hebrewDate.year == lastDay.hebrewDate.year {
            startBanner = "\(firstDay.hebrewDate.day) \(firstDay.hebrewMonthName)"
        } else {
            startBanner = "\(firstDay.hebrewDate.day) \(firstDay.hebrewMonthName) \(firstDay.hebrewDate.year)"
        }
        let endBanner = "\(lastDay.hebrewDate.day) \(lastDay.hebrewMonthName) \(lastDay.hebrewDate.year)"
        return "\(startBanner) — \(endBanner)"
    }
}

/// A single day of the calendar: the secular day number, the Hebrew date, and
/// any holidays.  An empty cell (nil day) pads the start and end of the grid.
struct DayCellView: View {
    let day: CalendarDay?
    let holidays: [String]
    let isToday: Bool
    let fontSize: Double

    var body: some View {
        VStack(spacing: 1) {
            if let day {
                Text(String(day.secularDate.day))
                    .font(.system(size: fontSize * 1.2, weight: .bold))
                Text("\(day.hebrewDate.day) \(day.hebrewMonthName)")
                    .font(.system(size: fontSize, weight: .bold))
                ForEach(holidays, id: \.self) { holiday in
                    Text(holiday)
                        .font(.system(size: fontSize))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .padding(2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(isToday ? Color.accentColor.opacity(0.25) : Color.clear)
        .border(.quaternary)
    }
}

#Preview {
    MonthGridView(month: CalendarMonth(year: 2027, month: 1), fontSize: 13)
        .padding()
}
