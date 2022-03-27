//
//  GameScene.swift
//  Patrick
//
//  Created by Ilya Katulin on 4/1/19.
//  Copyright © 2019 SimpleBeat. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

// MARK: This is a prototype, code refactoring is a must!
// To make the prototype into a full-fledged game with features to be added easily
// the refactoring the code below is necessary. Some of the work to be done includes:
// decoupling, getting rid of magic numbers, introducing enums instead of strings as entities names,
// re-building the initializations using 'factories', adding a proper state machine implementation, etc.

class GameScene: SKScene {
    
    let gameFrame = SKSpriteNode(imageNamed: "gameFrame") // the frame around the graphics
    let patrick = SKSpriteNode(imageNamed: "patrickLeft") // the 'hero' dog
    var corridor = SKNode() // all graphics inside the game frame
    var gameOn = false // is the hero hidden? if not, then no touch input
    var rightDoorIsOnTheRight = true // is the right door closed?
    var leftDoorIsOnTheLeft = true // is the left door closed?
    
    // MARK: Refactor to an enum!
    var objectsToHideIn = [String]() // names of the entities reacting to touches where the hero can 'hide'
    
    var hereIAm = "" // name of the object wehre the hero is hidden
    
    override func didMove(to view: SKView) {
        gameFrame.anchorPoint = CGPoint(x: 0, y: 0)
        gameFrame.position = CGPoint(x: 0, y: 0)
        gameFrame.zPosition = 100
        gameFrame.name = "frame"
        addChild(gameFrame)
        
        setUpCorridor() // Need to refactor to a better constructor
        
        corridor.position = CGPoint(x: 0, y: 134)
        addChild(corridor)
        
        patrick.anchorPoint = CGPoint(x: 0, y: 0)
        patrick.position = CGPoint(x: 170, y: 154)
        patrick.zPosition = 50
        patrick.name = "patrick"
        addChild(patrick)
        
        run(SKAction.playSoundFileNamed("breathe.mp3", waitForCompletion: false))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.bark(node: self.patrick); self.hide() }
    }
    
    // MARK: refactor the sound and the sprite animation into separate functions
    func bark(node: SKSpriteNode) {
        // a better implementation of the randomizer function is needed
        if node == patrick {
            let r = Int.random(in: 0...1)
            if r == 0 {
                run(SKAction.playSoundFileNamed("huff1.mp3", waitForCompletion: false))
            } else if r == 1 {
                run(SKAction.playSoundFileNamed("huff2.mp3", waitForCompletion: false))
            } else {
                run(SKAction.playSoundFileNamed("tick.mp3", waitForCompletion: false))
            }
        } else {
            let r = Int.random(in: 0...9)
            if r == 0 {
                run(SKAction.playSoundFileNamed("huff1.mp3", waitForCompletion: false))
            } else if r == 1 {
                run(SKAction.playSoundFileNamed("huff2.mp3", waitForCompletion: false))
            } else {
                run(SKAction.playSoundFileNamed("tick.mp3", waitForCompletion: false))
            }
        }
        
        // animation of the sprite should be separate from the sound
        let s1 = SKAction.scaleY(to: 1.1, duration: 0.1)
        let s2 = SKAction.scaleY(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([s1, s2])
        
        node.run(sequence)
    }
    
    // hide the hero
    func hide() {
        run(SKAction.playSoundFileNamed("breathe.mp3", waitForCompletion: false))
        hereIAm = objectsToHideIn.randomElement()!
        patrick.run(SKAction.fadeOut(withDuration: 0.3))
        gameOn = true
    }
    
    // MARK: state machine implementation needs reworking!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOn == false { return }
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            if location.y < 134 { return }
            if location.y > 634 { return }
            
            let tappedNodes = nodes(at: location)
            
            for node in tappedNodes {
                if node.name == "rightDoor" {
                    slideRightDoor(door: node as! SKSpriteNode)
                    return
                }
                if node.name == "leftDoor" {
                    slideLeftDoor(door: node as! SKSpriteNode)
                    return
                }
                if node.name == hereIAm {
                    gameOn = false
                    run(SKAction.playSoundFileNamed("wow.mp3", waitForCompletion: false))
                    patrick.position = node.position
                    patrick.position.y += 134
                    patrick.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.1), SKAction.move(to: CGPoint(x: 170, y: 154), duration: 0.3)]))
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) { self.bark(node: self.patrick); self.hide() }
                }
                for object in objectsToHideIn {
                    if node.name == object {
                        bark(node: node as! SKSpriteNode)
                    }
                }
            }
        }
    }
    
    // MARK: refactor, get rid of magic numbers
    func slideRightDoor(door: SKSpriteNode) {
        if rightDoorIsOnTheRight {
            door.run(SKAction.moveTo(x: 416, duration: 0.3))
            rightDoorIsOnTheRight = false
            run(SKAction.playSoundFileNamed("door1.mp3", waitForCompletion: false))
        } else {
            door.run(SKAction.moveTo(x: 716, duration: 0.3))
            rightDoorIsOnTheRight = true
            run(SKAction.playSoundFileNamed("door2.mp3", waitForCompletion: false))
        }
    }
    
    // MARK: refactor, get rid of magic numbers
    func slideLeftDoor(door: SKSpriteNode) {
        if leftDoorIsOnTheLeft {
            door.run(SKAction.moveTo(x: 716, duration: 0.3))
            leftDoorIsOnTheLeft = false
            run(SKAction.playSoundFileNamed("door1.mp3", waitForCompletion: false))
        } else {
            door.run(SKAction.moveTo(x: 416, duration: 0.3))
            leftDoorIsOnTheLeft = true
            run(SKAction.playSoundFileNamed("door2.mp3", waitForCompletion: false))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    // MARK: Refactor! Move to a separate file (use a better constructor/initializer approach)
    func setUpCorridor() {
        let wallpaper = SKSpriteNode(imageNamed: "wallpaper")
        wallpaper.anchorPoint = CGPoint(x: 0, y: 0)
        wallpaper.position = CGPoint(x: 0, y: 0)
        wallpaper.zPosition = -50
        corridor.addChild(wallpaper)
        
        let closet = SKSpriteNode(imageNamed: "closetBackground")
        closet.anchorPoint = CGPoint(x: 0, y: 0)
        closet.position = CGPoint(x: 412, y: 60)
        closet.zPosition = -40
        corridor.addChild(closet)
        
        let floor = SKSpriteNode(imageNamed: "floor")
        floor.anchorPoint = CGPoint(x: 0, y: 0)
        floor.position = CGPoint(x: 0, y: 0)
        floor.zPosition = -10
        corridor.addChild(floor)
        
        let cabinet = SKSpriteNode(imageNamed: "mirror")
        cabinet.anchorPoint = CGPoint(x: 0, y: 0)
        cabinet.position = CGPoint(x: 8, y: 60)
        cabinet.zPosition = 10
        cabinet.name = "mirror"
        objectsToHideIn.append(cabinet.name!)
        corridor.addChild(cabinet)
        
        let door = SKSpriteNode(imageNamed: "door")
        door.anchorPoint = CGPoint(x: 0, y: 0)
        door.position = CGPoint(x: 124, y: 62)
        door.zPosition = -20
        door.name = "entrance"
        objectsToHideIn.append(door.name!)
        corridor.addChild(door)
        
        let bin = SKSpriteNode(imageNamed: "bin")
        bin.anchorPoint = CGPoint(x: 0, y: 0)
        bin.position = CGPoint(x: 912, y: 70)
        bin.zPosition = 10
        bin.name = "bin"
        objectsToHideIn.append(bin.name!)
        corridor.addChild(bin)
        
        let washingMachine = SKSpriteNode(imageNamed: "washingMachine")
        washingMachine.anchorPoint = CGPoint(x: 0, y: 0)
        washingMachine.position = CGPoint(x: 740, y: 68)
        washingMachine.zPosition = 10
        washingMachine.name = "washingMachine"
        objectsToHideIn.append(washingMachine.name!)
        corridor.addChild(washingMachine)
        
        let dryingMachine = SKSpriteNode(imageNamed: "dryingMachine")
        dryingMachine.anchorPoint = CGPoint(x: 0, y: 0)
        dryingMachine.position = CGPoint(x: 740, y: 244)
        dryingMachine.zPosition = 10
        dryingMachine.name = "dryingMachine"
        objectsToHideIn.append(dryingMachine.name!)
        corridor.addChild(dryingMachine)
        
        let boots = SKSpriteNode(imageNamed: "boots")
        boots.anchorPoint = CGPoint(x: 0, y: 0)
        boots.position = CGPoint(x: 610, y: 70)
        boots.zPosition = 10
        boots.name = "boots"
        objectsToHideIn.append(boots.name!)
        corridor.addChild(boots)
        
        let whiteBox = SKSpriteNode(imageNamed: "whiteBox")
        whiteBox.anchorPoint = CGPoint(x: 0, y: 0)
        whiteBox.position = CGPoint(x: 428, y: 72)
        whiteBox.zPosition = 10
        whiteBox.name = "whiteBox"
        objectsToHideIn.append(whiteBox.name!)
        corridor.addChild(whiteBox)
        
        let blueBox = SKSpriteNode(imageNamed: "blueBox")
        blueBox.anchorPoint = CGPoint(x: 0, y: 0)
        blueBox.position = CGPoint(x: 900, y: 426)
        blueBox.zPosition = 10
        blueBox.name = "blueBox"
        objectsToHideIn.append(blueBox.name!)
        corridor.addChild(blueBox)
        
        let greenBox = SKSpriteNode(imageNamed: "greenBox")
        greenBox.anchorPoint = CGPoint(x: 0, y: 0)
        greenBox.position = CGPoint(x: 760, y: 426)
        greenBox.zPosition = 10
        greenBox.name = "greenBox"
        objectsToHideIn.append(greenBox.name!)
        corridor.addChild(greenBox)
        
        let redBox = SKSpriteNode(imageNamed: "redBox")
        redBox.anchorPoint = CGPoint(x: 0, y: 0)
        redBox.position = CGPoint(x: 500, y: 426)
        redBox.zPosition = 10
        redBox.name = "redBox"
        objectsToHideIn.append(redBox.name!)
        corridor.addChild(redBox)
        
        let dress = SKSpriteNode(imageNamed: "dress")
        dress.anchorPoint = CGPoint(x: 0, y: 0)
        dress.position = CGPoint(x: 430, y: 205)
        dress.zPosition = 10
        dress.name = "dress"
        objectsToHideIn.append(dress.name!)
        corridor.addChild(dress)
        
        let hook = SKSpriteNode(imageNamed: "hook")
        hook.anchorPoint = CGPoint(x: 0, y: 0)
        hook.position = CGPoint(x: 516, y: 360)
        hook.zPosition = 10
        corridor.addChild(hook)
        
        let clothes = SKSpriteNode(imageNamed: "clothes")
        clothes.anchorPoint = CGPoint(x: 0, y: 0)
        clothes.position = CGPoint(x: 590, y: 164)
        clothes.zPosition = 10
        clothes.name = "clothes"
        objectsToHideIn.append(clothes.name!)
        corridor.addChild(clothes)
        
        let door1 = SKSpriteNode(imageNamed: "doorLeft")
        door1.anchorPoint = CGPoint(x: 0, y: 0)
        door1.position = CGPoint(x: 416, y: 58)
        door1.zPosition = 20
        door1.name = "leftDoor"
        corridor.addChild(door1)
        
        let door2 = SKSpriteNode(imageNamed: "doorRight")
        door2.anchorPoint = CGPoint(x: 0, y: 0)
        door2.position = CGPoint(x: 716, y: 58)
        door2.zPosition = 30
        door2.name = "rightDoor"
        corridor.addChild(door2)
    }
}
