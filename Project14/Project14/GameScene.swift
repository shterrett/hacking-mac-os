//
//  GameScene.swift
//  Project14
//
//  Created by Stuart Terrett on 1/2/17.
//  Copyright © 2017 Stuart Terrett. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var bulletsSprite: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var targetSpeed = 4.0
    var targetDelay = 0.8
    var targetsCreated = 0
    var isGameOver = false

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var bulletsTextures = [
        SKTexture(image: #imageLiteral(resourceName: "shots0")),
        SKTexture(image: #imageLiteral(resourceName: "shots1")),
        SKTexture(image: #imageLiteral(resourceName: "shots2")),
        SKTexture(image: #imageLiteral(resourceName: "shots3"))
    ]

    var bulletsInClip = 3 {
        didSet {
            bulletsSprite.texture = bulletsTextures[bulletsInClip]
        }
    }

    override func didMove(to view: SKView) {
        createBackground()
        createWater()
        createOverlay()
        levelUp()
    }

    override func mouseDown(with event: NSEvent) {
        if isGameOver {
            if let newGame = SKScene(fileNamed: "GameScene") {
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(newGame, transition: transition)
            }
        } else {
            if bulletsInClip > 0 {
                run(SKAction.playSoundFileNamed("shot.wav", waitForCompletion: false))
                bulletsInClip -= 1

                shot(at: event.location(in: self))
            } else {
                run(SKAction.playSoundFileNamed("empty.wav", waitForCompletion: false))
            }
        }
    }

    func shot(at location: CGPoint) {
        guard let hitNode = (nodes(at: location).filter {
            $0.name == "target"
        }.first?.parent as? Target) else { return }

        hitNode.hit()

        score += 3
    }

    override func keyDown(with event: NSEvent) {
        if isGameOver {
            if let newGame = SKScene(fileNamed: "GameScene") {
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(newGame, transition: transition)
            }
        } else {
            if event.charactersIgnoringModifiers == " " {
                run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
                bulletsInClip = 3
                score -= 1
            }
        }
    }

    func createBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x:400, y:300)
        background.blendMode = .replace
        addChild(background)

        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 400, y: 300)
        addChild(grass)
        grass.zPosition = 100
    }

    func createWater() {
        func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
            let movementUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
            let repeatForever = SKAction.repeatForever(
                SKAction.sequence([movementUp, movementUp.reversed()])
            )
            node.run(repeatForever)
        }

        let waterBackground = SKSpriteNode(imageNamed: "water-bg")
        waterBackground.position = CGPoint(x: 400, y: 180)
        waterBackground.zPosition = 200
        addChild(waterBackground)

        let waterForeground = SKSpriteNode(imageNamed: "water-fg")
        waterForeground.position = CGPoint(x: 400, y: 120)
        waterForeground.zPosition = 300
        addChild(waterForeground)

        animate(waterBackground, distance: 8, duration: 1.3)
        animate(waterForeground, distance: 12, duration: 1)
    }

    func createOverlay() {
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: 400, y: 300)
        curtains.zPosition = 400
        addChild(curtains)

        bulletsSprite = SKSpriteNode(imageNamed: "shots3")
        bulletsSprite.position = CGPoint(x: 170, y: 60)
        bulletsSprite.zPosition = 500
        addChild(bulletsSprite)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 680, y: 50)
        scoreLabel.zPosition = 500
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }

    func createTarget() {
        let target = Target().setup()
        let level =  GKRandomSource.sharedRandom().nextInt(upperBound: 3)

        let move: SKAction

        switch level {
        case 0:
            move = SKAction.moveTo(x: 800, duration: targetSpeed * 1.2)
            target.position = CGPoint(x: 0, y: 280)
            target.zPosition = 250
            target.setScale(0.7)
        case 1:
            move = SKAction.moveTo(x: 0, duration: targetSpeed * 1.0)
            target.position = CGPoint(x: 800, y: 190)
            target.zPosition = 350
            target.xScale = -0.85
            target.yScale = 0.85
        default:
            move = SKAction.moveTo(x: 800, duration: targetSpeed * 0.8)
            target.position = CGPoint(x: 0, y: 100)
            target.zPosition = 450
        }

        let sequence = SKAction.sequence([move, SKAction.removeFromParent()])
        target.run(sequence)
        addChild(target)

        levelUp()
    }

    func levelUp() {
        targetSpeed *= 0.99
        targetDelay *= 0.99
        targetsCreated += 1

        if targetsCreated <= 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + targetDelay) { [unowned self] in
                self.createTarget()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                self.gameOver()
            }
        }
    }

    func gameOver() {
        isGameOver = true

        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: 400, y: 300)
        gameOverTitle.setScale(2)
        gameOverTitle.alpha = 0

        let animation = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1, duration: 0.3)
        ])

        gameOverTitle.run(animation)
        gameOverTitle.zPosition = 900
        addChild(gameOverTitle)
    }
}
