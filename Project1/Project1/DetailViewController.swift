//
//  DetailViewController.swift
//  Project1
//
//  Created by Stuart Terrett on 11/24/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController {

    @IBOutlet var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func imageSelected(name: String) {
        imageView.image = NSImage(named: name)
        imageView.imageScaling = NSImageScaling.scaleProportionallyDown
    }
}
