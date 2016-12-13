//
//  ViewController.swift
//  Project8
//
//  Created by Stuart Terrett on 12/12/16.
//  Copyright © 2016 Stuart Terrett. All rights reserved.
//

import Cocoa
import GameplayKit

class ViewController: NSViewController {
    var visualEffectView: NSVisualEffectView!
    var gameOverView: GameOverView!
    
    var gridViewButtons = [NSButton]()
    let gridSize = 10
    let gridMargin: CGFloat = 5
    var currentLevel = 1
    var images = ["elephant", "giraffe", "hippo", "monkey",
                  "panda", "parrot", "penguin", "pig", "rabbit", "snake"]
    
    override func loadView() {
        super.loadView()
        
        visualEffectView = NSVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.material = .dark
        visualEffectView.state = .active
        view.addSubview(visualEffectView)
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let title = createTitle()
        let buttons = createButtonArray()
        createGridView(relativeTo: title, withButtons: buttons)
        gridViewButtons = buttons.flatMap() { $0 }
    }
    
    func createTitle() -> NSTextField {
        let title = NSTextField(labelWithString: "Odd One Out")
        title.font = NSFont.systemFont(ofSize: 36, weight: NSFontWeightThin)
        title.textColor = NSColor.white
        title.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(title)
        title.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: gridMargin).isActive = true
        title.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor).isActive = true
        
        return title
    }
    
    func createButtonArray() -> [[NSButton]] {
        return (0..<gridSize).map() { _ -> [NSButton] in
            return (0..<gridSize).map() { _ -> NSButton in
                let button = NSButton(frame: NSRect(x: 0, y: 0, width: 64, height: 64))
                button.setButtonType(.momentaryChange)
                button.imagePosition = .imageOnly
                button.focusRingType = .none
                button.isBordered = false
                
                button.action = #selector(imageClicked)
                button.target = self
                
                return button
            }
        }
    }
    
    func createGridView(relativeTo title: NSTextField, withButtons rows: [[NSButton]]) {
        let gridView = NSGridView(views: rows)
        
        gridView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(gridView)
        
        gridView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: gridMargin).isActive = true
        gridView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -gridMargin).isActive = true
        gridView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: gridMargin).isActive = true
        gridView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -gridMargin).isActive = true
        
        gridView.columnSpacing = gridMargin / 2
        gridView.rowSpacing = gridMargin / 2
        
        (0..<gridSize).forEach() {
            gridView.row(at: $0).height = 64
            gridView.column(at: $0).width = 64
        }
    }
    
    func imageClicked(_ sender: NSButton) {
        guard sender.tag != 0 else { return }
        
        if sender.tag == 1 {
            if currentLevel > 1 {
                currentLevel -= 1
            }
        } else {
            currentLevel += 1
        }
        
        createLevel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createLevel()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func generateLayout(items: Int) {
        gridViewButtons.forEach() {
            $0.tag = 0
            $0.image = nil
        }
        
        gridViewButtons = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: gridViewButtons) as! [NSButton]
        images = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: images) as! [String]
        
        var numUsed = 0
        var itemCount = 1
        let firstButton = gridViewButtons[0]
        firstButton.tag = 2
        firstButton.image = NSImage(named: images[0])
        
        for i in 1..<items {
            let currentButton = gridViewButtons[i]
            currentButton.tag = 1
            currentButton.image = NSImage(named: images[itemCount])
            numUsed += 1
            
            if numUsed == 2 {
                numUsed = 0
                itemCount += 1
            }
            
            if itemCount == images.count {
                itemCount = 1
            }
        }
    }
    
    func createLevel() {
        guard currentLevel < 9 else {
            gameOver()
            return
        }
        
        let limits = [5, 15, 25, 35, 49, 65, 81, 100]
        
        generateLayout(items: limits[currentLevel - 1])
    }
    
    func gameOver() {
        gameOverView = GameOverView()
        gameOverView.alphaValue = 0
        gameOverView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameOverView)
        
        gameOverView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gameOverView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gameOverView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gameOverView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        gameOverView.layoutSubtreeIfNeeded()
        
        gameOverView.startEmitting()
        
        NSAnimationContext.current().duration = 1
        gameOverView.animator().alphaValue = 1
    }
}

