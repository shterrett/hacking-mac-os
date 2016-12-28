//
//  AppDelegate.swift
//  Project13
//
//  Created by Stuart Terrett on 12/24/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSColorPanel.shared().showsAlpha = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

