// CompactMonthView.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// The layout for narrow (iPhone-width) screens: a compact month grid showing
/// the secular day, the Hebrew day, and a dot marking days with holidays, with
/// a card giving full details for the selected day.  In portrait the card sits
/// below the grid; in landscape, where height is scarce, it sits alongside and
/// the day cells flatten to a single line.
struct CompactMonthView: View {
    let month: CalendarMonth
    let today: AbsoluteDay
    let fontSize: Double

    /// Forces the side-by-side landscape layout.  Previews use this, since
    /// they cannot vary the window's size classes.
    var forcesLandscape = false

    @State private var selectedDate: SecularDate?

    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    /// A landscape phone is too short to stack the grid above the detail card.
    private var isLandscape: Bool {
        #if os(iOS)
            forcesLandscape || verticalSizeClass == .compact
        #else
            forcesLandscape
        #endif
    }

    private static let weekdayLetters = DateFormatter().veryShortWeekdaySymbols!

    var body: some View {
        let detailCard = DayDetailCard(
            day: selectedDay, holidays: month.holidays(on: selectedDay), fontSize: fontSize)
        VStack(spacing: isLandscape ? 6 : 10) {
            Text(month.hebrewDateRange)
                .font(.system(size: fontSize * 1.15, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if isLandscape {
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 6) {
                        weekdayHeader
                        grid
                    }
                    detailCard
                        .frame(maxWidth: 300)
                }
            } else {
                weekdayHeader
                grid
                detailCard
            }

            Spacer(minLength: 0)
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 4) {
            ForEach(Array(Self.weekdayLetters.enumerated()), id: \.offset) { _, letter in
                Text(letter)
                    .font(.system(size: fontSize * 0.9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        let cells = month.paddedCells
        return VStack(spacing: isLandscape ? 2 : 4) {
            ForEach(0..<6) { row in
                HStack(spacing: 4) {
                    ForEach(0..<7) { column in
                        let day = cells[row * 7 + column]
                        CompactDayCell(
                            day: day,
                            hasHolidays: day.map { !month.holidays(on: $0).isEmpty } ?? false,
                            isToday: day?.absoluteDay == today,
                            isSelected: day?.secularDate == selectedDay.secularDate,
                            fontSize: fontSize,
                            singleLine: isLandscape)
                            .onTapGesture {
                                if let day {
                                    selectedDate = day.secularDate
                                }
                            }
                    }
                }
            }
        }
    }

    /// The day whose details are shown: the tapped day if it is in this month,
    /// otherwise today, otherwise the first of the month.
    private var selectedDay: CalendarDay {
        month.days.first { $0.secularDate == selectedDate }
            ?? month.days.first { $0.absoluteDay == today }
            ?? month.days[0]
    }
}

/// One compact day: the secular day number and the Hebrew day number, with a
/// dot if any holiday falls on the day.  The two numbers stack in portrait
/// and share a line in landscape.
private struct CompactDayCell: View {
    let day: CalendarDay?
    let hasHolidays: Bool
    let isToday: Bool
    let isSelected: Bool
    let fontSize: Double
    let singleLine: Bool

    var body: some View {
        ZStack {
            if let day {
                if singleLine {
                    HStack(spacing: 3) {
                        secularText(day)
                        hebrewText(day)
                        dot
                    }
                } else {
                    VStack(spacing: 0) {
                        secularText(day)
                        hebrewText(day)
                        dot
                    }
                }
            }
        }
        .padding(.vertical, 3)
        .frame(maxWidth: .infinity, minHeight: singleLine ? 24 : 44)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.3) : Color.clear))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.accentColor, lineWidth: isToday ? 1.5 : 0))
        .contentShape(Rectangle())
    }

    private func secularText(_ day: CalendarDay) -> some View {
        Text(String(day.secularDate.day))
            .font(.system(size: fontSize * 1.05, weight: .bold))
    }

    private func hebrewText(_ day: CalendarDay) -> some View {
        Text(String(day.hebrewDate.day))
            .font(.system(size: fontSize * 0.8))
            .foregroundStyle(.secondary)
    }

    private var dot: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 4, height: 4)
            .opacity(hasHolidays ? 1 : 0)
    }
}

/// Full details for the selected day.
private struct DayDetailCard: View {
    let day: CalendarDay
    let holidays: [String]
    let fontSize: Double

    private static let monthNames = DateFormatter().standaloneMonthSymbols!
    private static let weekdayNames = DateFormatter().weekdaySymbols!

    var body: some View {
        // Interpolating numbers directly into Text would add locale grouping
        // separators ("5,786"), so build plain strings first.
        let secularLine = "\(Self.weekdayNames[day.weekday.rawValue]), " +
            "\(Self.monthNames[day.secularDate.month - 1]) \(day.secularDate.day)" +
            ", \(day.secularDate.year)"
        let hebrewLine = "\(day.hebrewDate.day) \(day.hebrewMonthName) \(day.hebrewDate.year)"
        VStack(alignment: .leading, spacing: 5) {
            Text(secularLine)
                .font(.system(size: fontSize * 1.1, weight: .bold))
            Text(hebrewLine)
                .font(.system(size: fontSize, weight: .semibold))
            if holidays.isEmpty {
                Text("No holidays")
                    .font(.system(size: fontSize))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(holidays, id: \.self) { holiday in
                    // The detail card has plenty of room, so always spell
                    // out abbreviated names in full.
                    Text(holiday.expandingAbbreviations)
                        .font(.system(size: fontSize))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.08)))
    }
}

#Preview {
    CompactMonthView(month: CalendarMonth(year: 2026, month: 7), today: .today(), fontSize: 13)
        .padding()
        .frame(width: 375, height: 700)
}

#Preview("Landscape") {
    CompactMonthView(
        month: CalendarMonth(year: 2026, month: 7), today: .today(), fontSize: 16,
        forcesLandscape: true)
        .padding()
}
