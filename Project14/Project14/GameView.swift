//
//  GameView.swift
//  Project14
//
//  Created by Stuart Terrett on 1/2/17.
//  Copyright © 2017 Stuart Terrett. All rights reserved.
//

import Cocoa
import SpriteKit

class GameView: SKView {
    override func resetCursorRects() {
        let targetImage = #imageLiteral(resourceName: "cursor")
        let cursor = NSCursor(image: targetImage, hotSpot: CGPoint(x: targetImage.size.width/2, y: targetImage.size.height / 2))
        addCursorRect(frame, cursor: cursor)
    }
}
