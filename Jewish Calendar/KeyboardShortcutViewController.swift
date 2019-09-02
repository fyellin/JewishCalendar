// KeyboardShortcutViewController.swift
// Copyright (c) 2019 Frank Yellin.

import Cocoa

class KeyboardShortcutViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
  @IBOutlet var tableView: NSTableView!

  override func viewDidLoad() {
    // We are set up as the TableView's delegate and datasource in the storyboard
    super.viewDidLoad()

    // It's ugly that I have to set the font and alignment here, rather than in the storyboard
    let font = NSFont.boldSystemFont(ofSize: 15)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    for tableColumn in tableView.tableColumns {
      tableColumn.headerCell.alignment = .center
      tableColumn.headerCell.attributedStringValue =
        NSAttributedString(
          string: tableColumn.title,
          attributes: [.font: font, .paragraphStyle: paragraphStyle])
    }
  }

  @objcMembers
  class ShortcutInfo: NSObject {
    let name: String
    let meaning: String
    
    init(_ name: String, _ meaning: String) {
      self.name = name
      self.meaning = meaning
    }
  }
  
  /** The table is bound to the information here. */
  @objc let shortcuts: [ShortcutInfo] = [
    ShortcutInfo("◀", "previous month"),
    ShortcutInfo("▶", "next month"),
    ShortcutInfo("▼", "previous year"),
    ShortcutInfo("▲", "next year"),
    ShortcutInfo("⌘T", "today"),
  ]
}
