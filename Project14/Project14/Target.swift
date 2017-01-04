//
//  Target.swift
//  Project14
//
//  Created by Stuart Terrett on 1/2/17.
//  Copyright © 2017 Stuart Terrett. All rights reserved.
//

import Cocoa
import GameplayKit
import SpriteKit

class Target: SKNode {
    var target: SKSpriteNode!
    var stick: SKSpriteNode!

    func setup() -> Target {
        let stickType = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
        let targetType = GKRandomSource.sharedRandom().nextInt(upperBound: 4)

        stick = SKSpriteNode(imageNamed: "stick\(stickType)")
        target = SKSpriteNode(imageNamed: "target\(targetType)")

        target.name = "target"
        target.position.y += 116

        addChild(stick)
        addChild(target)
        return self
    }

    func hit() {
        removeAllActions()
        target.name = nil

        let animationTime = 0.2
        target.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        stick.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        run(SKAction.fadeOut(withDuration: animationTime))
        run(SKAction.moveBy(x: 0, y: -30, duration: animationTime))
        run(SKAction.scaleX(by: 0.8, y: 0.7, duration: animationTime))

        removeFromParent()
    }
}
