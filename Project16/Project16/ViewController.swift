//
//  ViewController.swift
//  Project16
//
//  Created by Stuart Terrett on 1/8/17.
//  Copyright © 2017 Stuart Terrett. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    dynamic  var reviews = [Review]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

