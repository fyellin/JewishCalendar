//
//  KeyboardShortcutViewController.swift
//  Jewish Calendar
//
//  Created by Frank Yellin on 8/20/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa

class KeyboardShortcutViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handled by the storyboard
        // tableView.dataSource = self
        // tableView.delegate = self
        for tableColumn in tableView.tableColumns {
            tableColumn.headerCell.alignment = .center
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return shortcutData.count
    }
    
    let shortcutData = [
        ("◀",   "previous month"),
        ("▶",   "next month"),
        ("▼",   "previous year"),
        ("▲",   "next year"),
        ("⌘T",  "today"),
    ]
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id : String
        let value : String
        if tableColumn == tableView.tableColumns[0] {
            id = "shortcut"
            value = shortcutData[row].0
        } else {
            id = "meaning"
            value = shortcutData[row].1
        }
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(id), owner: nil) as? NSTableCellView
        view?.textField?.stringValue = value
        if id == "shortcut" {
            view?.textField?.alignment = .center
        }
        return view
    }
}
