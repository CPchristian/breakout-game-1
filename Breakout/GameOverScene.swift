//
//  GameOverScene.swift
//  Breakout
//
//  Created by Feng Zhichao on 2/2/15.
//  Copyright (c) 2015 Feng Zhichao. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, score: Int) {
        super.init(size: size)
        
        let backgroundImage = SKSpriteNode(imageNamed: "bgRed")
        backgroundImage.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        self.addChild(backgroundImage)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Black")
        gameOverLabel.fontSize = 46
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 30)
        gameOverLabel.text = "Game Over"
        self.addChild(gameOverLabel)
        
        showScore(score)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showScore(score: Int) {
        let scoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
        scoreLabel.fontSize = 32
        scoreLabel.text = "Score: \(score)"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 20)
        scoreLabel.zPosition = 10
        
        self.addChild(scoreLabel)
    }
}
