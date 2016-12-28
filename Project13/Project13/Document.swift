//
//  Document.swift
//  Project13
//
//  Created by Stuart Terrett on 12/24/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

enum ScreenshotError: Error {
    case BadData
}

class Document: NSDocument {

    var screenshot = Screenshot()

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: screenshot)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let loadedScreenshot = NSKeyedUnarchiver.unarchiveObject(with: data) as? Screenshot else { throw ScreenshotError.BadData }
        self.screenshot = loadedScreenshot
    }
}

