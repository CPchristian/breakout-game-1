//
//  GameScene.swift
//  Breakout
//
//  Created by Feng Zhichao on 2/2/15.
//  Copyright (c) 2015 Feng Zhichao. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    let scoreCategoryName = "score"
    let dropShadowCategoryName = "dropShadow"
    
    let backgroundMusicPlayer = AVAudioPlayer()
    
    var fingerIsOnPaddle = false
    
    let ballCategory:UInt32 = 0x1 << 0
    let bottomCategory:UInt32 = 0x1 << 1
    let brickCategory:UInt32 = 0x1 << 2
    let paddleCategory:UInt32 = 0x1 << 3
    
    var currentScore = 0
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.physicsWorld.contactDelegate = self
        
        let bgMusicUrl = NSBundle.mainBundle().URLForResource("bgMusic", withExtension: "wav")

        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bgMusicUrl, error: nil)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        
        let backgroundImage = SKSpriteNode(imageNamed: "bgRed")
        backgroundImage.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        self.addChild(backgroundImage)
        
        initScore()
     
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        let worldBorder = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody = worldBorder
        self.physicsBody?.friction = 0
        
        let ball = SKSpriteNode(imageNamed: "ball")
        ball.name = ballCategoryName
        ball.position = CGPointMake(self.frame.size.width / 3, self.frame.size.height / 4)
        self.addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width / 2)
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = false
        
        ball.physicsBody?.applyImpulse(CGVectorMake(2, 2))
        
        let paddle = SKSpriteNode(imageNamed: "paddle")
        paddle.name = paddleCategoryName
        paddle.position = CGPointMake(CGRectGetMidX(self.frame), paddle.frame.size.height * 5)
        self.addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.frame.size)
        paddle.physicsBody?.friction = 0.4
        paddle.physicsBody?.restitution = 0.1
        paddle.physicsBody?.dynamic = false
        
        let bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        self.addChild(bottom)
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        
        ball.physicsBody?.contactTestBitMask = bottomCategory | paddleCategory
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        let body:SKPhysicsBody? = self.physicsWorld.bodyAtPoint(touchLocation)
        if body?.node?.name == paddleCategoryName {
            println("Paddle touched")
            fingerIsOnPaddle = true
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if fingerIsOnPaddle {
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(self)
            let prevTouchLocation = touch.previousLocationInNode(self)
            
            let paddle = self.childNodeWithName(paddleCategoryName) as SKSpriteNode
            
            var newX = paddle.position.x + (touchLocation.x - prevTouchLocation.x)
            newX = max(newX, paddle.size.width / 2)
            newX = min(newX, self.size.width - paddle.size.width / 2)
            
            paddle.position = CGPointMake(newX, paddle.position.y)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        fingerIsOnPaddle = false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            println("You lose")
            let gameOverScene = GameOverScene(size: self.frame.size, score: currentScore)
            self.view?.presentScene(gameOverScene)
        } else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory {
            println("Ball hit paddle")
            
            currentScore += 1
            updateScore()
        
            let ball = self.childNodeWithName(ballCategoryName) as SKSpriteNode
            let currentVelocity = ball.physicsBody?.velocity
            ball.physicsBody?.velocity = CGVectorMake(currentVelocity!.dx * 1.2, currentVelocity!.dy * 1.2)
        }
    }
    
    func initScore() {
        let scoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
        scoreLabel.name = scoreCategoryName
        scoreLabel.fontSize = 28
        scoreLabel.text = "Hits: \(currentScore)"
        scoreLabel.position = CGPointMake(CGRectGetMaxX(self.frame) - 50, CGRectGetMaxY(self.frame) - 50)
        scoreLabel.zPosition = 10

        let dropShadow = SKLabelNode(fontNamed: "Avenir-Black")
        dropShadow.name = dropShadowCategoryName
        dropShadow.fontSize = 28
        dropShadow.fontColor = SKColor.blackColor()
        dropShadow.text = "Hits: \(currentScore)"
        dropShadow.position = CGPointMake(scoreLabel.position.x + 1, scoreLabel.position.y - 1)
        
        self.addChild(dropShadow)
        self.addChild(scoreLabel)
    }
    
    func updateScore() {
        let scoreLabel = self.childNodeWithName(scoreCategoryName) as SKLabelNode
        scoreLabel.text = "Hits: \(currentScore)"
        let dropShadowLabel = self.childNodeWithName(dropShadowCategoryName) as SKLabelNode
        dropShadowLabel.text = "Hits: \(currentScore)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
