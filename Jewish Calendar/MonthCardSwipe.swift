// MonthCardSwipe.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// A card-toss gesture for the month display.  The view follows the drag with a
/// slight tilt; released past the threshold it flies off screen and the new
/// month slides in from the opposite side.
///
/// Swipe direction mirrors the arrow-key shortcuts: left/right changes the
/// month, up/down changes the year.
struct MonthCardSwipe: ViewModifier {
    let model: CalendarViewModel

    /// How far the card must be dragged (or flicked) to change the month.
    private static let threshold = 100.0

    /// Far enough to be off screen on any device.
    private static let exitDistance = 1200.0

    @State private var offset = CGSize.zero

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .rotationEffect(.degrees(offset.width / 25), anchor: UnitPoint(x: 0.5, y: 1.5))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { value in
                        release(value)
                    })
    }

    private func release(_ value: DragGesture.Value) {
        // Using the predicted end lets a quick flick succeed even if the finger
        // only moved a short distance.
        let projected = value.predictedEndTranslation
        let isHorizontal = abs(projected.width) >= abs(projected.height)

        let delta: Int
        let exit: CGSize
        switch (isHorizontal, projected.width, projected.height) {
            case (true, ..<(-Self.threshold), _): // pushed off to the left: next month
                delta = 1
                exit = CGSize(width: -Self.exitDistance, height: projected.height)
            case (true, Self.threshold..., _): // pushed off to the right: previous month
                delta = -1
                exit = CGSize(width: Self.exitDistance, height: projected.height)
            case (false, _, ..<(-Self.threshold)): // pushed off the top: next year
                delta = 12
                exit = CGSize(width: projected.width, height: -Self.exitDistance)
            case (false, _, Self.threshold...): // pushed off the bottom: previous year
                delta = -12
                exit = CGSize(width: projected.width, height: Self.exitDistance)
            default: // not a decisive swipe: snap back
                withAnimation(.spring(duration: 0.3)) {
                    offset = .zero
                }
                return
        }

        guard canApply(delta) else {
            withAnimation(.spring(duration: 0.4)) {
                offset = .zero
            }
            return
        }

        withAnimation(.easeIn(duration: 0.18)) {
            offset = exit
        } completion: {
            model.addMonths(delta)
            // The new month enters from the side opposite the exit.
            offset = CGSize(
                width: isHorizontal ? -exit.width : 0,
                height: isHorizontal ? 0 : -exit.height)
            withAnimation(.spring(duration: 0.35)) {
                offset = .zero
            }
        }
    }

    private func canApply(_ delta: Int) -> Bool {
        switch delta {
            case 1: return model.canShowLaterMonth
            case -1: return model.canShowEarlierMonth
            case 12: return model.canShowLaterYear
            case -12: return model.canShowEarlierYear
            default: return false
        }
    }
}

extension View {
    /// Lets the user change months (horizontal) and years (vertical) by
    /// swiping this view away like a card.
    func monthCardSwipe(model: CalendarViewModel) -> some View {
        modifier(MonthCardSwipe(model: model))
    }
}
