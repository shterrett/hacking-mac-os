//
//  Photo.swift
//  Project7
//
//  Created by Stuart Terrett on 12/3/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class Photo: NSCollectionViewItem {
    
    let selectedBorderThickness: CGFloat = 3
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderWidth = selectedBorderThickness
            } else {
                view.layer?.borderWidth = 0
            }
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            if highlightState == .forSelection {
                view.layer?.borderWidth = selectedBorderThickness
            } else {
                if !isSelected {
                    view.layer?.borderWidth = 0
                }
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.blue.cgColor
    }
    
}
