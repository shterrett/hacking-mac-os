//
//  WindowController.swift
//  Project4
//
//  Created by Stuart Terrett on 11/27/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var urlEntry: NSTextField!
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }

}
