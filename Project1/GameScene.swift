//
//  GameScene.swift
//  Project1
//
//  Created by Markus Varner on 12/29/18.
//  Copyright © 2018 Markus Varner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Properties
    let player = SKSpriteNode(imageNamed: "player-motorbike.png")
    var touchingPlayer = false
    var gameTimer: Timer?
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    let music = SKAudioNode(fileNamed: "cyborg-ninja.mp3")
    var score = 0 {
        didSet{
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        //Background initial setup
        let background = SKSpriteNode(imageNamed: "road.jpg")
        background.zPosition = -1
        addChild(background)
        if let particles = SKEmitterNode(fileNamed: "Mud") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            addChild(particles)
        }
        //Player Initial Setup
        player.position.x = -200
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.affectedByGravity = false
        //assign players physicsbody a unique identifier so we can call events if player is collided
        player.physicsBody?.categoryBitMask = 1
        addChild(player)
        //set Enemy Initialization timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true, block: { (timer) in
            self.createEnemy()
        })
        physicsWorld.contactDelegate = self
        scoreLabel.zPosition = 2
        scoreLabel.position.y = 145
        addChild(scoreLabel)
        addChild(music)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        //determine any nodes of the game scene that have been touched
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        // if the player node was touched set the touching player value to true
        if tappedNodes.contains(player) {
            touchingPlayer = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchingPlayer else {return}
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    //this method gets called immediately when the user lifts their finger from the screen
        touchingPlayer = false
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        for node in children {
            if node.position.x < -700 {
                node.removeFromParent()
            }
        }
        
        if player.position.x < -400 {
            player.position.x = -400
        } else if player.position.x > 400 {
            player.position.x = 400
        }
        
        if player.position.y < -300 {
            player.position.y = -3000
        } else if player.position.y > 300 {
            player.position.y = 300
        }
        
        
    }
    
    func createEnemy() {
        createBonus()
        //setup enemy sprite node and randomized position
        let texture = SKTexture(imageNamed: "barrel")
//        texture.cgImage().width = 30
//        texture.cgImage().height = 30
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: 1000, y: Int.random(in: -350...350))
        sprite.name = "enemy"
        sprite.zPosition = 1
        //assign a physics body to sprite node base off its size
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        addChild(sprite)
        //assign enemies velocity
        sprite.physicsBody!.velocity = CGVector(dx: -500, dy: 0)
        //for this game friction isnt really a concern...
        sprite.physicsBody!.linearDamping = 0
        sprite.physicsBody!.affectedByGravity = false
        //this tells the barrels that a collision has happened with the player
        sprite.physicsBody?.contactTestBitMask = 1
        //assign a categorybitmask (uid) to barrels physics body
        sprite.physicsBody?.categoryBitMask = 0
    }
    
    func createBonus() {
        //Set up coin sprites
        let texture = SKTexture(imageNamed: "coin.png")
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: 1000, y: Int.random(in: -350...350))
        sprite.name = "bonus"
        sprite.zPosition = 1
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        addChild(sprite)
        sprite.physicsBody!.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody!.linearDamping = 0
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.categoryBitMask = 0
        sprite.physicsBody?.collisionBitMask = 0
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        if nodeA == player {
            playerHit(nodeB)
        } else {
            playerHit(nodeA)
        }
    }
    
    func playerHit(_ node: SKNode) {
        if node.name == "bonus" {
            score += 1
            let sound = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
            run(sound)
            node.removeFromParent()
           
            return
        } else {
            let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
            run(sound)
            if let particles = SKEmitterNode(fileNamed: "Explosion.sks") {
                particles.position = player.position
                particles.zPosition = 3
                addChild(particles)
            }
            player.removeFromParent()
            music.removeFromParent()
            let gameOver = SKSpriteNode(imageNamed: "gameOver-3")
            gameOver.zPosition = 10
            gameOver.position.y = 0
            gameOver.position.x = 0
            addChild(gameOver)
            //wait for two seconds then execute the following code
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                //create a new game scene
                if let scene = GameScene(fileNamed: "GameScene") {
                    //strecth the scene to fitr the screen
                    scene.scaleMode = .aspectFill
                    //present it immediately
                    self.view?.presentScene(scene)
                }
            }
        }
        
    }
    
}
