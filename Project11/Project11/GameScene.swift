import GameplayKit
import SpriteKit

class GameScene: SKScene {

    var bubbleTextures = [SKTexture]()
    var currentBubbleTexture = 0

    var maximumNumber = 0
    var bubbles = [SKSpriteNode]()
    var bubbleTimer: Timer!

    override func didMove(to view: SKView) {
        bubbleTextures = [#imageLiteral(resourceName: "bubbleRed"),
                          #imageLiteral(resourceName: "bubblePink"),
                          #imageLiteral(resourceName: "bubbleGray"),
                          #imageLiteral(resourceName: "bubbleCyan"),
                          #imageLiteral(resourceName: "bubbleBlue"),
                          #imageLiteral(resourceName: "bubbleGreen"),
                          #imageLiteral(resourceName: "bubbleOrange")
                         ].map() {
                             return SKTexture(image: $0)
                         }

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector.zero
        physicsBody?.restitution = 1.0

        for _ in 1...8 {
            createBubble()
        }

        bubbleTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(createBubble), userInfo: nil, repeats: true)
    }

    func nextBubble() {
        currentBubbleTexture = (currentBubbleTexture + 1) % bubbleTextures.count
        maximumNumber += GKRandomSource.sharedRandom().nextInt(upperBound: 3) + 1

        if ["6", "9"].contains(String(maximumNumber).characters.last!) {
            maximumNumber += 1
        }
    }

    func createBubble() {
        let bubble = SKSpriteNode(texture: bubbleTextures[currentBubbleTexture])
        bubble.name = String(maximumNumber)
        bubble.zPosition = 1

        let label = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        label.text = bubble.name
        label.color = NSColor.white
        label.fontSize = 64
        label.verticalAlignmentMode = .center
        label.zPosition = 2

        bubble.addChild(label)
        addChild(bubble)
        bubbles.append(bubble)

        let xPos = GKRandomSource.sharedRandom().nextInt(upperBound: 800)
        let yPos = GKRandomSource.sharedRandom().nextInt(upperBound: 600)

        bubble.position = CGPoint(x: xPos, y: yPos)

        let scale = max(GKRandomSource.sharedRandom().nextUniform(), 0.7)
        bubble.setScale(CGFloat(scale))
        bubble.alpha = 0
        bubble.run(SKAction.fadeIn(withDuration: 0.5))

        configurePhysics(for: bubble)
        nextBubble()
    }

    func configurePhysics(for bubble: SKSpriteNode) {
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2)
        bubble.physicsBody?.linearDamping = 0.0
        bubble.physicsBody?.angularDamping = 0.0
        bubble.physicsBody?.friction = 0.0
        bubble.physicsBody?.restitution = 1.0

        let motionX = GKRandomSource.sharedRandom().nextInt(upperBound: 400) - 200
        let motionY = GKRandomSource.sharedRandom().nextInt(upperBound: 400) - 200

        bubble.physicsBody?.velocity = CGVector(dx: motionX, dy: motionY)
        bubble.physicsBody?.angularVelocity = CGFloat(GKRandomSource.sharedRandom().nextUniform())
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let clickedNodes: [SKNode] = nodes(at: location).filter() {
            $0.name != nil
        }

        guard clickedNodes.count > 0 else { return }

        let lowestBubble: Int? = bubbles.flatMap() {
            $0.name
        }.flatMap() {
            Int($0)
        }.min()


        if let target = lowestBubble {
            let correctNodes = clickedNodes.filter() {
                Int($0.name!)! == target
            }

            guard correctNodes.count > 0 else {
                createBubble()
                createBubble()
                return
            }
            correctNodes.forEach() {
                pop($0 as! SKSpriteNode)
            }
        }
    }

    func pop(_ node: SKSpriteNode) {
        guard let index = bubbles.index(of: node) else { return }
        bubbles.remove(at: index)

        node.physicsBody = nil
        node.name = nil
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleUp = SKAction.scale(by: 1.5, duration: 0.3)
        scaleUp.timingMode = .easeOut
        let group = SKAction.group([fadeOut, scaleUp])
        let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
        node.run(sequence)

        run(SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false))

        if bubbles.count == 0 {
            bubbleTimer.invalidate()
        }
    }
}
