//
//  StarField.swift
//  SpaceRun
//
//  Created by Greg Cedarblade on 4/18/16.
//  Copyright (c) 2016 Greg Cedarblade. All rights reserved.
//

import SpriteKit

class StarField: SKNode {
    
    override init() {
        super.init()
        
        initSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()
        
        initSetup()
    }
    
    
    func initSetup() {
        
        
        //
        // Because we need to call a method on self from inside a code block, 
        // we must create a weak reference to it.  This is what we are doing
        // with our weakSelf constant.
        //
        // Why?  The action holds a strong reference to the code block and
        // the node (self) holds a strong reference to the action.  If the 
        // code block held a strong reference to the node (self in this case)
        // then the action, the block, and the node would form a retain cycle
        // of strong references that never get deallocated -> memory leak.
        //
        // The fix here is to make sure the block's reference to our node (self)
        // is weak rather than strong.
        //
        let update = SKAction.run {
            [weak self] in
            
            if arc4random_uniform(10) < 6 {
                
                if let weakSelf = self {
                    weakSelf.launchStar()
                }
                
            }
            
        }
        
        let delay = SKAction.wait(forDuration: 0.01)
        
        let updateLoop = SKAction.sequence([delay, update])
        
        run(SKAction.repeatForever(updateLoop))
        
    }
    
    
    func launchStar() {
        
        // We need a reference to the scene (GameScene)
        if let scene = self.scene {
            
            // Calculate a random starting point at top of screen for our star
            let randX = Double(arc4random_uniform(uint(scene.size.width)))
            
            let startY = Double(scene.size.height)
            
            let star = SKSpriteNode(imageNamed: "shootingstar")
            
            star.position = CGPoint(x: randX, y: startY)
            
            star.size = CGSize(width: 2.0, height: 10.0)
            star.alpha = 0.1 + (CGFloat(arc4random_uniform(10)) / 10.0)
            
            addChild(star)
            
            // Move the star toward the bottom of the screen using
            // a random duration between .1 to 1 second removing the
            // star when it passes the bottom edge.
            //
            // The different speeds (duration) gives the illusion we
            // call parallax.
            let destY = 0.0 - scene.size.height - star.size.height
            let duration = 0.1 + (Double(arc4random_uniform(10)) / 10.0)
            
            star.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: destY, duration: duration), SKAction.removeFromParent()]))
            
        }
        
    }
    
}
