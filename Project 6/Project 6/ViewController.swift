//
//  ViewController.swift
//  Project 6
//
//  Created by Stuart Terrett on 12/2/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // createVFL()
        // createAnchors()
        // createStackView()
        createGridView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    func makeView(_ number: Int) -> NSView {
        let vw = NSTextField(labelWithString: "View \(number)")
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.alignment = .center
        vw.wantsLayer = true
        vw.layer?.backgroundColor = NSColor.cyan.cgColor
        return vw
    }
    
    func createVFL() {
        let textFields = [
            "view1": makeView(1),
            "view2": makeView(2),
            "view3": makeView(3),
            "view4": makeView(4)
        ]
        
        for (name, textField) in textFields {
            view.addSubview(textField)
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[\(name)]|", options: [], metrics: nil, views: textFields
            ))
        }
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[view1]-[view2]-[view3]-[view4]|", options: [], metrics: nil, views: textFields
        ))
    }
    
    func createAnchors() {
        let views = [1, 2, 3, 4].map() { makeView($0) }
        
        _ = views.reduce(nil) { (previous, current) -> NSView in
            self.view.addSubview(current)
            
            current.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            current.heightAnchor.constraint(equalToConstant: 88).isActive = true
            
            if let previousView = previous {
                current.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10).isActive = true
            } else {
                current.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            }
            
            return current
        }
        
        views.last!.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func createStackView() {
        let views = [1, 2, 3, 4].map() { makeView($0) }
        let stackView = NSStackView(views: views)
        stackView.distribution = .fillEqually
        stackView.orientation = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        for textField in stackView.arrangedSubviews {
            textField.setContentHuggingPriority(1, for: .horizontal)
            textField.setContentHuggingPriority(1, for: .vertical)
        }
    }
    
    func createGridView() {
        let empty = NSGridCell.emptyContentView
        
        let gridView = NSGridView(views: [
            [makeView(0)],
            [makeView(1), empty, makeView(2)],
            [makeView(3), makeView(4), makeView(5), makeView(6)],
            [makeView(7), empty, makeView(8)],
            [makeView(9)]
        ])
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gridView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        (0..<gridView.numberOfColumns).forEach() {
            gridView.column(at: $0).width = 128
            gridView.column(at: $0).xPlacement = .center
        }
        
        (0..<gridView.numberOfRows).forEach() {
            gridView.row(at: $0).height = 32
            gridView.row(at: $0).yPlacement = .center
        }
        
        gridView.row(at: 0).mergeCells(in: NSRange(location: 0, length: 4))
        gridView.row(at: 1).mergeCells(in: NSRange(location: 0, length: 2))
        gridView.row(at: 1).mergeCells(in: NSRange(location: 2, length: 2))
        gridView.row(at: 3).mergeCells(in: NSRange(location: 0, length: 2))
        gridView.row(at: 3).mergeCells(in: NSRange(location: 2, length: 2))
        gridView.row(at: 4).mergeCells(in: NSRange(location: 0, length: 4))
    }
}

