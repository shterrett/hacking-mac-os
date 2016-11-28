//
//  ViewController.swift
//  Project1
//
//  Created by Stuart Terrett on 11/24/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class ViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func shareClicked(_ sender: NSView) {
        guard let detail = childViewControllers[1] as? DetailViewController else { return }
        guard let image = detail.imageView.image else { return }
        let sharingService = NSSharingServicePicker(items: [image])
        sharingService.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
    }
}

