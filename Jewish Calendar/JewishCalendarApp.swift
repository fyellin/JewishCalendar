// JewishCalendarApp.swift
// Copyright (c) 2019 Frank Yellin.
//
// The SwiftUI application entry point.

import SwiftUI

@main
struct JewishCalendarApp: App {
    @State private var model = CalendarViewModel()

    #if os(macOS)
        @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    var body: some Scene {
        #if os(macOS)
            Window("Jewish Calendar", id: "calendar") {
                CalendarScreen()
                    .environment(model)
            }
            .defaultSize(width: 720, height: 600)
            .commands {
                CalendarCommands(model: model)
            }

            Settings {
                SettingsView()
            }
        #else
            WindowGroup {
                CalendarScreen()
                    .environment(model)
            }
            .commands {
                CalendarCommands(model: model)
            }
        #endif
    }
}

#if os(macOS)
    /// The one remaining piece of AppKit lifecycle: quit when the window closes,
    /// as this app always has.
    final class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            true
        }
    }
#endif
