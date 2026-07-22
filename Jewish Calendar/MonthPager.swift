// MonthPager.swift
// Copyright (c) 2019 Frank Yellin.

import SwiftUI

/// An interactive pager for the month display.  Dragging slides the whole
/// grid, with the neighboring month (left/right) or year (up/down) visible
/// alongside; released past the threshold the pager settles on the neighbor,
/// otherwise the current month snaps back.
///
/// Swipe direction mirrors the arrow-key shortcuts: left/right changes the
/// month, up/down changes the year.
struct MonthPager<Card: View>: View {
    let model: CalendarViewModel
    @ViewBuilder let card: (_ year: Int, _ month: Int) -> Card

    /// How far the drag must go (or be flicked) to change the month.
    private let threshold = 100.0

    /// The gap between adjacent pages.
    private let gap = 40.0

    private enum Axis { case horizontal, vertical }

    /// How far the whole strip of pages is displaced from rest.
    @State private var dragOffset = CGSize.zero

    /// The drag direction, locked by the first movement of each drag and held
    /// until the pager settles.  Which neighbors are shown depends on it.
    @State private var axis: Axis?

    /// True while the release animation runs; drags are ignored until done.
    @State private var isSettling = false

    @State private var size = CGSize(width: 1200, height: 1200)

    var body: some View {
        let pageWidth = size.width + gap
        let pageHeight = size.height + gap
        ZStack {
            card(model.year, model.month)
                .offset(dragOffset)
            if axis == .horizontal {
                neighbor(-1, at: CGSize(width: -pageWidth, height: 0))
                neighbor(1, at: CGSize(width: pageWidth, height: 0))
            } else if axis == .vertical {
                neighbor(-12, at: CGSize(width: 0, height: -pageHeight))
                neighbor(12, at: CGSize(width: 0, height: pageHeight))
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .gesture(drag)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            size = newSize
        }
    }

    /// The month `delta` months away, one page beyond the current card, or
    /// nothing if the calendar can't go that far.
    @ViewBuilder private func neighbor(_ delta: Int, at position: CGSize) -> some View {
        if canApply(delta) {
            let total = model.year * 12 + (model.month - 1) + delta
            card(total / 12, total % 12 + 1)
                .offset(CGSize(
                    width: dragOffset.width + position.width,
                    height: dragOffset.height + position.height))
        }
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isSettling else { return }
                if axis == nil {
                    axis = abs(value.translation.width) >= abs(value.translation.height)
                        ? .horizontal : .vertical
                }
                dragOffset = constrained(value.translation)
            }
            .onEnded { value in
                guard !isSettling else { return }
                release(value)
            }
    }

    /// The translation limited to the locked axis, with resistance when there
    /// is no page to reveal in that direction.
    private func constrained(_ translation: CGSize) -> CGSize {
        switch axis {
            case .horizontal:
                let blocked = translation.width < 0 ? !canApply(1) : !canApply(-1)
                return CGSize(width: blocked ? translation.width / 3 : translation.width, height: 0)
            case .vertical:
                let blocked = translation.height < 0 ? !canApply(12) : !canApply(-12)
                return CGSize(width: 0, height: blocked ? translation.height / 3 : translation.height)
            case nil:
                return .zero
        }
    }

    private func release(_ value: DragGesture.Value) {
        // Using the predicted end lets a quick flick succeed even if the finger
        // only moved a short distance.
        let projected = value.predictedEndTranslation

        let delta: Int
        let settled: CGSize // where the current card sits once the neighbor is centered
        switch axis {
            case .horizontal where projected.width < -threshold && canApply(1):
                delta = 1
                settled = CGSize(width: -(size.width + gap), height: 0)
            case .horizontal where projected.width > threshold && canApply(-1):
                delta = -1
                settled = CGSize(width: size.width + gap, height: 0)
            case .vertical where projected.height < -threshold && canApply(12):
                delta = 12
                settled = CGSize(width: 0, height: -(size.height + gap))
            case .vertical where projected.height > threshold && canApply(-12):
                delta = -12
                settled = CGSize(width: 0, height: size.height + gap)
            default: // not a decisive swipe: snap back
                isSettling = true
                withAnimation(.spring(duration: 0.3)) {
                    dragOffset = .zero
                } completion: {
                    axis = nil
                    isSettling = false
                }
                return
        }

        isSettling = true
        withAnimation(.spring(duration: 0.35)) {
            dragOffset = settled
        } completion: {
            // The neighbor is now centered; make it the real current month and
            // jump the strip back to rest.  The screen shows the same pixels
            // before and after the swap, so the jump is invisible.
            model.addMonths(delta)
            dragOffset = .zero
            axis = nil
            isSettling = false
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
