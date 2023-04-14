import SpriteKit

public class N05_Level01Gameplay_Village: SKScene, SKPhysicsContactDelegate {
    
    let mouseSpeed: CGFloat = 155.0
    let catSpeed: CGFloat = 80.0
    
    var exitHole: SKSpriteNode?
    var mouse: SKSpriteNode?
    var mice: [SKSpriteNode] = []
    var leadingMouse: SKSpriteNode?
    var cat: SKSpriteNode?
    var cats: [SKSpriteNode] = []
    var N05_background: SKSpriteNode?
    
    var lastTouch: CGPoint? = nil
    // var miceCount: Int = 0
    
    override public func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        N05_background = childNode(withName: "N05_background") as? SKSpriteNode
        N05_background?.zPosition = -1

        // animation moving up and down
        let moveUpDown: SKAction = SKAction.sequence([SKAction.moveBy(x: 0, y: 10, duration: 0.5), SKAction.moveBy(x: 0, y: -10, duration: 0.5)])
        let moveUpDownContinuously: SKAction = SKAction.repeatForever(moveUpDown)
        // animation moving left and right
        let moveLeftRight: SKAction = SKAction.sequence([SKAction.moveBy(x: 20, y: 0, duration: 0.5), SKAction.moveBy(x: -20, y: 0, duration: 0.5)])
        let moveLeftRightContinuously: SKAction = SKAction.repeatForever(moveLeftRight)
        // animation fading in and out
        let flashDuration = 4.0 // The duration of each flash
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: flashDuration / 2)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: flashDuration / 2)
        let flash = SKAction.sequence([fadeIn, fadeOut])
        let repeatFlash = SKAction.repeatForever(flash)
        
        exitHole = childNode(withName: "exitHole") as? SKSpriteNode
        exitHole?.run(repeatFlash)
        exitHole?.zPosition = 1
        exitHole?.physicsBody = SKPhysicsBody(rectangleOf: exitHole!.size)
        exitHole?.physicsBody?.categoryBitMask = 2 // 2: exitHole
        exitHole?.physicsBody?.collisionBitMask = 1 // 1: mouse
        exitHole?.physicsBody?.contactTestBitMask = 1 // 1: mouse
        exitHole?.physicsBody?.affectedByGravity = false
        exitHole?.physicsBody?.allowsRotation = false
                
        for child in self.children {
            if child.name == "cat" {
                if let child = child as? SKSpriteNode {
                    child.run(moveUpDownContinuously)
                    child.zPosition = 1
                    child.physicsBody = SKPhysicsBody(rectangleOf: child.size)
                    child.physicsBody?.categoryBitMask = 4 // 4: cat
                    child.physicsBody?.collisionBitMask = 1 // 1: mouse
                    child.physicsBody?.contactTestBitMask = 1 // 1: mouse
                    child.physicsBody?.affectedByGravity = false
                    child.physicsBody?.allowsRotation = false
                    cats.append(child)
                }
            } else if let nodeName = child.name, nodeName.hasPrefix("mouse_") { // declare the name of the node in the scene
            //    child.run(moveUpDownContinuously)
                if let child = child as? SKSpriteNode {
                    child.run(moveLeftRightContinuously)
                    child.zPosition = 1
                    child.physicsBody = SKPhysicsBody(rectangleOf: child.size)
                    child.physicsBody?.categoryBitMask = 1 // 1: mouse
                    child.physicsBody?.collisionBitMask = 2 | 4 // 2: exitHole, 4: cat
                    child.physicsBody?.contactTestBitMask = 2 | 4 // 2: exitHole, 4: cat
                    child.physicsBody?.affectedByGravity = false
                    child.physicsBody?.allowsRotation = false
                    mice.append(child)
                }
            }
        }
        mouse = mice.first
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?) { handleTouches(touches) }
    
    override public func touchesMoved(_ touches: Set<UITouch>,with event: UIEvent?) { handleTouches(touches) }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { handleTouches(touches) }
    
    fileprivate func handleTouches(_ touches: Set<UITouch>) { lastTouch = touches.first?.location(in: self) }
    
    override public func didSimulatePhysics() {
        if mouse != nil {
            updateMice()
            updateCats()
        }
    }
    
    fileprivate func shouldMove(currentPosition: CGPoint,
                                touchPosition: CGPoint) -> Bool {
        guard let mouse = mouse else { return false }
        return abs(currentPosition.x - touchPosition.x) > mouse.frame.width / 2 ||
            abs(currentPosition.y - touchPosition.y) > mouse.frame.height / 2
    }
    
    fileprivate func updateMice() {
        guard let mouse = mouse,
            let touch = lastTouch
            else { return }
        let currentPosition = mouse.position
        if shouldMove(currentPosition: currentPosition,
                      touchPosition: touch) {
            updateMicePosition(for: mouse, to: touch, speed: mouseSpeed)
        } else {
            mouse.physicsBody?.isResting = true
        }
    }
    
    func updateCats() {
        guard let mouse = mouse else { return }
        let targetPosition = mouse.position
        
        for cat in cats {
            updatePosition(for: cat, to: targetPosition, speed: catSpeed)
        }
    }
    
    fileprivate func updatePosition(for sprite: SKSpriteNode, to target: CGPoint, speed: CGFloat) {
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y, currentPosition.x - target.x)
        // let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5), duration: 0)
        // sprite.run(rotateAction)
        
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
    }

    fileprivate func updateMicePosition(for sprite: SKSpriteNode, to target: CGPoint, speed: CGFloat) {
        
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y, currentPosition.x - target.x)
        // let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5), duration: 0)
        // sprite.run(rotateAction)
        
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity

        //update mice moving after the leading mouse
        let distanceBetweenMice: CGFloat = 70
        if mice.count > 1 {
            for i in (1..<mice.count).reversed() {
                let mouse: SKSpriteNode = mice[i]
                let previousMouse: SKSpriteNode = mice[i - 1]
                let newPosition: CGPoint = CGPoint(x: previousMouse.position.x - distanceBetweenMice, y: previousMouse.position.y)
                let moveAction: SKAction = SKAction.move(to: newPosition, duration: 0.2)
                mouse.run(moveAction)
                mouse.zPosition = previousMouse.zPosition + 1 // Ensure nodes are layered properly
            }
        }
    }

    public func didBegin(_ contact: SKPhysicsContact) {

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Check contact
        if firstBody.categoryBitMask == mouse?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == cats[0].physicsBody?.categoryBitMask {
            print("mouse contact with cat")
            upLevel(false)
        } else if firstBody.categoryBitMask == mouse?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == exitHole?.physicsBody?.categoryBitMask {
            print("mouse contact with exitHole")
            upLevel(true)
        }
    }
    
    fileprivate func upLevel(_ didWin: Bool) {
        let transition: SKTransition = SKTransition.fade(withDuration: 1.0)
        let resultScene = LevelDecision(didWin: didWin, jumpToLevel: 1, size: size)
        view?.presentScene(resultScene, transition: transition)
    }
}
