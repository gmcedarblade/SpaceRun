//
//  SKEmitterNodeExtension.swift
//  SpaceRun
//
//  Created by Greg Cedarblade on 4/18/16.
//  Copyright (c) 2016 Greg Cedarblade. All rights reserved.
//

import SpriteKit

// Use a Swift extension to extend the String class to have a length property
extension String {
    var length: Int {
        return self.characters.count
    }
}


extension SKEmitterNode {
    
    // Helper method to fetch the passed-in particle effect file
    class func pdc_nodeWithFile(_ filename: String) -> SKEmitterNode? {
        
        // We will check the file basename and extension.
        // If there is no extension, set it to "sks".
        let basename = (filename as NSString).deletingPathExtension
        
        var fileExt = (filename as NSString).pathExtension
        
        if fileExt.length == 0 {
            fileExt = "sks"
        }
        
        // We will grab the main bundle of our project and ask for
        // the path to a resource that has the calculated basename
        // and file extension.
        if let path = Bundle.main.path(forResource: basename, ofType: fileExt) {
            
            // Particle effects are automatically archived when created and
            // we need to unarchive the effect file so it can be treated as
            // an SKEmitterNode object.
            let node = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            
            return node
            
        }
        
        return nil
        
    }
    
    
    //
    // We want to add explosions to the two collisions involving photo vs obstacle
    // and ship vs obstacle.  We don't want the emitters to keep running indefinitely
    // for these explosions so we will make the die out after a short duration.
    //
    func pdc_dieOutInDuration(_ duration: TimeInterval) {
        
        // Define two waiting periods because once we set the birthrate to 
        // zero, we will still need to wait before the particles die out.  
        // Otherwise, the particles will vanish from the screen immediately.
        let firstWait = SKAction.wait(forDuration: duration)
        
        // Set the birthrate property to zero in order to make the particle
        // effect disappear using an SKAction code block.
        let stop = SKAction.run {
            [weak self] in
            
            if let weakSelf = self {
                weakSelf.particleBirthRate = 0
            }
        }
        
        // Get the second wait time
        let secondWait = SKAction.wait(forDuration: TimeInterval(self.particleLifetime))
        
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([firstWait, stop, secondWait, remove]))
        
    }
    
}
