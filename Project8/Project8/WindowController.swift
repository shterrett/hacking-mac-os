//
//  WindowController.swift
//  Project8
//
//  Created by Stuart Terrett on 12/13/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.styleMask = [window!.styleMask, .fullSizeContentView]
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.isMovableByWindowBackground = true
    }

}
