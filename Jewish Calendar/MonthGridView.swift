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

            // Every cell gets exactly a sixth of the height, so a day with many
            // holidays can't stretch its row; its text is clipped instead.
            GeometryReader { proxy in
                let rowHeight = proxy.size.height / 6
                VStack(spacing: 0) {
                    ForEach(0..<6) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<7) { column in
                                let day = cells[row * 7 + column]
                                DayCellView(
                                    day: day,
                                    holidays: day.map { month.holidays(on: $0) } ?? [],
                                    isToday: day?.absoluteDay == today,
                                    fontSize: fontSize,
                                    height: rowHeight)
                            }
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
    let height: Double

    /// The natural height of the cell's text, measured as it is laid out.
    /// When it exceeds the space inside the cell, the text is clipped and a
    /// click shows the full list in a popover.
    @State private var contentHeight = 0.0

    @State private var showingDetails = false

    private var overflows: Bool {
        contentHeight > height - 4 // 4 = the cell's vertical padding
    }

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
        .onGeometryChange(for: Double.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            contentHeight = newHeight
        }
        .padding(2)
        // Pinning both height bounds keeps the cell rigid even when the text
        // inside wants more room; the overflow is clipped away.
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .top)
        .clipped()
        .overlay(alignment: .bottomTrailing) {
            if overflows {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: fontSize * 0.9))
                    .foregroundStyle(.secondary)
                    .padding(1)
            }
        }
        .background(isToday ? Color.accentColor.opacity(0.25) : Color.clear)
        .border(.quaternary, width: day == nil ? 0 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            if overflows {
                showingDetails = true
            }
        }
        .popover(isPresented: $showingDetails) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(holidays, id: \.self) { holiday in
                    Text(holiday.expandingAbbreviations)
                        .font(.system(size: fontSize))
                }
            }
            .padding()
        }
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
