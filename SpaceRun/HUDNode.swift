//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Greg Cedarblade on 4/18/16.
//  Copyright (c) 2016 Greg Cedarblade. All rights reserved.
//


import SpriteKit

//
// Create a HUD (Heads-Up-Display) that will hold all of our display areas
//
// Once the node is added to the scene, we'll tell it to lay out its child nodes.
// The child node will not contain labels as we will use blank nodes as group
// containers and lay out the label nodes inside of them.
//

class HUDNode: SKNode {
    
    // Build two parent nodes as groups to hold the score and elapsed time info.
    // Each group will have title and value labels.
    // 
    
    // Properties
    fileprivate let ScoreGroupName = "scoreGroup"
    fileprivate let ScoreValueName = "scoreValue"
    
    fileprivate let ElapsedGroupName = "elapsedGroup"
    fileprivate let ElapsedValueName = "elapsedValue"
    fileprivate let TimerActionName = "elapsedGameTimer"
    
    fileprivate let PowerupGroupName = "powerupGroup"
    fileprivate let PowerupValueName = "powerupValue"
    fileprivate let PowerupTimerActionName = "powerupGameTimer"
    
    fileprivate let HealthPowerUpGroupName = "healthPowerUpGroup"
    fileprivate let HealthPowerUpValueName = "healthValue"
    
    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    var healthPoints: CGFloat = 2.0
    
  fileprivate func scoreFormatter(_ decimals: Int) -> String {
        
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = decimals
    return formatter.string(from: NSNumber(value: decimals))!
    
  }
    
    lazy fileprivate var healthFormatter: NumberFormatter = {
        
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
        
    }()
    
  fileprivate func timeFormatter(_ decimals: Double) -> String {
        
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: decimals))!
        
    }
    
    
    // Our class initializer
    override init() {
        super.init()
        
        //
        // Build an empty SKNode as our containing group and name it 
        // "scoreGroup" so we can get a reference to it later from the SceneGraph
        // 
        
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        addChild(scoreGroup)
        
        // Score Title setup
        
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        scoreTitle.horizontalAlignmentMode = .left
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        
        // The child nodes are positioned relative to the parent node's origin point.
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        
        // Score Value setup
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        scoreValue.horizontalAlignmentMode = .left
        scoreValue.verticalAlignmentMode = .top
        scoreValue.text = "0"
        scoreValue.name = ScoreValueName
        
        // The child nodes are positioned relative to the parent node's origin point.
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        
        
        
        // We need to do the same type of setup for our Elapsed Time
        
        
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        addChild(elapsedGroup)
        
        // Elapsed Title setup
        
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        elapsedTitle.horizontalAlignmentMode = .right
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = "TIME"
        
        // The child nodes are positioned relative to the parent node's origin point.
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        
        // Elapsed Value setup
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        elapsedValue.horizontalAlignmentMode = .right
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.text = "0.0s"
        elapsedValue.name = ElapsedValueName
        
        // The child nodes are positioned relative to the parent node's origin point.
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        
        // Powerup group stuff
        
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        addChild(powerupGroup)
        
        // Powerup Title setup
        
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        
        // The child nodes are positioned relative to the parent node's origin point.
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Set up action to make our Powerup timer pulse
        
        let pulse = SKAction.sequence([SKAction.scale(to: 1.3, duration: 0.3), SKAction.scale(to: 1.0, duration: 0.3)])
        
        powerupTitle.run(SKAction.repeatForever(pulse))
        
        powerupGroup.addChild(powerupTitle)
        
        
        // Powerup Value setup
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.red
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        powerupValue.verticalAlignmentMode = .top
        powerupValue.text = "0s left"
        powerupValue.name = PowerupValueName
        
        // The child nodes are positioned relative to the parent node's origin point.
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerupGroup.addChild(powerupValue)
        
        powerupGroup.alpha = 0.0 // make it invisible to start...
        
        
        // START HEALTH POWER UP
        
        let healthGroup = SKNode()
        healthGroup.name = HealthPowerUpGroupName
        
        addChild(healthGroup)
        
        // Score Title setup
        
        let healthTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        
        healthTitle.fontSize = 12.0
        healthTitle.fontColor = SKColor.white
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        healthTitle.horizontalAlignmentMode = .center
        healthTitle.verticalAlignmentMode = .bottom
        
        healthTitle.text = "HEALTH"
        
        // The child nodes are positioned relative to the parent node's origin point.
        healthTitle.position = CGPoint(x: -150.0, y: -320.0)
        
        healthGroup.addChild(healthTitle)
        
        
        // Score Value setup
        let myHealthValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        myHealthValue.fontSize = 20.0
        myHealthValue.fontColor = SKColor.white
        
        // Set the virtical and horizontal alignment modes in a way that
        // will help us to lay out the labels inside this group node.
        
        myHealthValue.horizontalAlignmentMode = .center
        myHealthValue.verticalAlignmentMode = .bottom
        
        myHealthValue.text = "2"
        myHealthValue.name = HealthPowerUpValueName
        
        // The child nodes are positioned relative to the parent node's origin point.
        myHealthValue.position = CGPoint(x: 0.0, y: -322.0)
        
        healthGroup.addChild(myHealthValue)
        
        
        
        // END HEALTH POWER UP
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //
    // Our labels are properly layed out within their parent group nodes, but
    // the group nodes are centered on the scene. We need to create some layout
    // method so that these group nodes are properly positioned to the top-left
    // and top-right corners when this HUDNode is added to the scene.
    //
    
    func layoutForScene() {
    
        // Note: when a node exists in the Scene Graph, it can get access
        // to the scene (GameScene) via its scene property. That property
        // is nil if the node doesn't belong to a scene yet, so this method
        // would be useless if the node is not yet added to a scene.
        if let scene = scene {
            
            
            let sceneSize = scene.size
            
            var groupSize = CGSize.zero // used to calculate position of each group
            
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                
                // Get calculated size of our scoreGroup node (rectangular size)
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 20.0, y: sceneSize.height/2.0 - groupSize.height)
                
                
            } else {
                
                assert(false, "No score group node was found in the Scene Graph tree")
                
            }
            
            if let elapsedGroup = childNode(withName: ElapsedGroupName) {
                
                // Get calculated size of our scoreGroup node (rectangular size)
                groupSize = elapsedGroup.calculateAccumulatedFrame().size
                
                elapsedGroup.position = CGPoint(x: sceneSize.width/2.0 - 20.0, y: sceneSize.height/2.0 - groupSize.height)
                
                
            } else {
                
                assert(false, "No score elapsed node was found in the Scene Graph tree")
                
            }
            
            if let powerupGroup = childNode(withName: PowerupGroupName) {
                
                // Get calculated size of our scoreGroup node (rectangular size)
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height)
                
                
            } else {
                
                assert(false, "No powerup group node was found in the Scene Graph tree")
                
            }
            
        }
        
    }
    
    
    //
    // Show our Powerup Timer
    //
    
    func showPowerupTimer(_ time: TimeInterval) {
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            
            // Remove any exisiting action with the following key because 
            // we want to restart the timer as we are calling this method
            // as a result of the player collecting another weapons powerup.
            
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            // Look up our powerValue label by name
            if let powerupValue = powerupGroup.childNode(withName: PowerupValueName) as! SKLabelNode? {
                
                // Run the countdown timer sequence 
                
                let start = Date.timeIntervalSinceReferenceDate
                
                let block = SKAction.run {
                    
                    [weak self] in
                    
                    if let weakSelf = self {
                        
                        let elapsed = Date.timeIntervalSinceReferenceDate - start
                        
                        let timeLeft = max(time - elapsed, 0)
                        
                      let timeLeftFormat = weakSelf.timeFormatter(timeLeft)
                        
                        powerupValue.text = "\(timeLeftFormat)s left"
                        
                    }
                    
                }
                
                // Actions
                
                let countDownSequence = SKAction.sequence([block, SKAction.wait(forDuration: 0.05)])
                
                
                let countDown = SKAction.repeatForever(countDownSequence)
                
                
                // Fade in/out
                
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                
                let wait = SKAction.wait(forDuration: time)
                
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                
                
                let stopAction = SKAction.run({ () -> Void in
                
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                    
                })
                
                
                let visuals = SKAction.sequence([fadeIn, wait, fadeOut, stopAction])
                
                powerupGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
                
                
            }
            
        }
        
    }
    
    
    //
    // Show health 
    //
    
    func showHealth(_ health: CGFloat) {
        
        healthPoints = health * 25
        
        if let shipHealthValue = childNode(withName: "\(HealthPowerUpGroupName)/\(HealthPowerUpValueName)") as! SKLabelNode? {
            
            shipHealthValue.text = "\(healthFormatter.number(from: String(describing: healthPoints))!)%"
            
        }
        
    }
    
    //
    // Add points to the score
    //
    
    func addPoints(_ points: Int) {
        
        score += points
        
        // Look up the score value label by name in the SceneGraph. Why?
        // Note: "scoreValue"'s node is not a direct child of the scene, so 
        // we need to reference via a path. It is a direct child of "scoreGroup"
        // which is a direct child of the scene so we can use a path to get it
        // ("scoreGroup/scoreValue")
        
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            
            // Format our score with the thousands separator so we will
            // use our cached self.scoreFormatter property.
            
            scoreValue.text = scoreFormatter(score)
            
            // Scale the node up for a brief period and then scale it back down
            // to create a pulse effect.
            
            let scale = SKAction.scale(to: 1.1, duration: 0.02)
            let shrink = SKAction.scale(to: 1.0, duration: 0.07)
            
            scoreValue.run(SKAction.sequence([scale, shrink]))
            
            
            
        }
        
        
    }
    
    
    func startGame() {
        
        // Calculate the timestamp when starting the game
        let startTime = Date.timeIntervalSinceReferenceDate
        
        if let elapsedValue = childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode? {
            
            // Use a code block to update the elapsedTime property to tbe the 
            // difference between the startTime timestamp and the current
            // timestamp.
            
            let update = SKAction.run({ [weak self] in
                
                if let weakSelf = self {
                    
                    let now = Date.timeIntervalSinceReferenceDate
                    
                    weakSelf.elapsedTime = now - startTime
                    
                    elapsedValue.text = weakSelf.timeFormatter(weakSelf.elapsedTime)
                    
                }
                
            })
            
            
            // Every 0.05 seconds, run a sequence of events that updates the timer label
            
            let updateAndDelay = SKAction.sequence([update, SKAction.wait(forDuration: 0.05)])
            
            
            // Repeat the action sequence until the game ends
            
            let timer = SKAction.repeatForever(updateAndDelay)
            
            // Assign the timer action a key
            
            run(timer, withKey: TimerActionName)
            
        }
        
        
    }
    
    //
    // Stop the game timer
    //
    
    func endGame() {
        
        // To stop the timer sequence set up in startGame(), we need to remove 
        // the action for the key we used (TimerActionName).
        
        removeAction(forKey: TimerActionName)
        
    }
    
    
}
