//
//  SourceViewController.swift
//  Project1
//
//  Created by Stuart Terrett on 11/24/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class SourceViewController: NSViewController,
NSTableViewDataSource, NSTableViewDelegate {

    
    
    @IBOutlet var tableView: NSTableView!
    var pictures = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath
        let items = try! fm.contentsOfDirectory(atPath: path!)
        
        for item in items {
            if item.hasSuffix("pdf") {
                pictures.append(item)
            }
        }
        
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return pictures.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        vw.textField?.stringValue = pictures[row]
        return vw
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard self.tableView.selectedRow != -1 else { return }
        guard let splitVC = self.parent as! NSSplitViewController? else { return }
        
        if let detail = splitVC.childViewControllers[1] as? DetailViewController {
            detail.imageSelected(name: pictures[self.tableView.selectedRow])
        }
    }
}
