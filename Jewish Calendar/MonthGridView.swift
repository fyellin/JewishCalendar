// MonthGridView.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The month grid: a banner giving the Hebrew date range, a weekday header,
/// and six rows of day cells.
struct MonthGridView: View {
    let month: CalendarMonth
    let today: AbsoluteDay
    let fontSize: Double

    private static let weekdayNames = DateFormatter().shortWeekdaySymbols!

    var body: some View {
        let cells = month.paddedCells
        VStack(spacing: 6) {
            Text(month.hebrewDateRange)
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
                                isToday: day?.absoluteDay == today,
                                fontSize: fontSize)
                        }
                    }
                }
            }
        }
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
                    // Prefer "Shabbat Shirah" when the cell is wide enough,
                    // fall back to "Sh. Shirah", and shrink as a last resort.
                    ViewThatFits(in: .horizontal) {
                        holidayText(holiday.expandingAbbreviations)
                        holidayText(holiday)
                        holidayText(holiday)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
        .padding(2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(isToday ? Color.accentColor.opacity(0.25) : Color.clear)
        .border(.quaternary)
    }

    private func holidayText(_ name: String) -> some View {
        Text(name)
            .font(.system(size: fontSize))
            .lineLimit(1)
    }
}

#Preview {
    MonthGridView(month: CalendarMonth(year: 2027, month: 1), today: .today(), fontSize: 13)
        .padding()
}
