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

  func numberOfRows(in tableView: NSTableView) -> Int {
    return shortcutData.count
  }

  let shortcutData: [(name: String, meaning: String)] = [
    ("◀", "previous month"),
    ("▶", "next month"),
    ("▼", "previous year"),
    ("▲", "next year"),
    ("⌘T", "today")
  ]

  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
    // Note, cocoa bindings insure that this object gets shown in the table cell.
    if tableView.tableColumns[0] == tableColumn {
      return shortcutData[row].name
    } else {
      return shortcutData[row].meaning
    }
  }
}
