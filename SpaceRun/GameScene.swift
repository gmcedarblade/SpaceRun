//
//  GameScene.swift
//  SpaceRun
//
//  Created by Greg Cedarblade on 4/18/16.
//  Copyright (c) 2016 Greg Cedarblade. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Class properties
    fileprivate let SpaceshipNodeName = "ship"
    fileprivate let PhotonTorpedoNodeName = "photon"
    fileprivate let ObstacleNodeName = "obstacle"
    fileprivate let PowerUpNodeName = "powerup"
    fileprivate let ShipHealthNodeName = "shiphealth"
    fileprivate let HUDNodeName = "hud"
    fileprivate let ShieldNodeName = "shield"
    
    
    // Properties to hold sound actions.  We will be preloading
    // our sounds into these properties.
    fileprivate let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: false)
    fileprivate let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: false)
    fileprivate let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    
    fileprivate weak var shipTouch: UITouch?
    fileprivate weak var shieldTouch: UITouch?
    fileprivate var lastUpdateTime: TimeInterval = 0
    fileprivate var lastShotFireTime: TimeInterval = 0
    
    fileprivate let defaultFireRate: Double = 0.5
    fileprivate var shipFireRate: Double = 0.5
    fileprivate let powerUpDuration: TimeInterval = 5.0
    
    fileprivate var shipHealthRate: CGFloat = 2.0
    
    
    // We will be using the particle emitters for our explosions repeatedly.
    // We don't want to load them from their files every time, so instead
    // we will create class properties and cache them for quick reuse
    // very much like we did for our sound-related properties.
    fileprivate let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("shipExplode.sks")!
    
    fileprivate let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.pdc_nodeWithFile("obstacleExplode.sks")!
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        setupGame(size)
        
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        
        super.init(coder: aDecoder)
        setupGame(self.size)
        
    }
    
    
    func setupGame(_ size: CGSize) {
        
        let ship = SKSpriteNode(imageNamed: "Spaceship.png")
        
        ship.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        // Sprite Kit's resize formula (transform) is very efficient
        ship.size = CGSize(width: 40.0, height: 40.0)
        
        ship.name = SpaceshipNodeName
        
        addChild(ship)
        
        // Add our star field parallax effect to the scene by creating
        // an instance of our StarField class and adding it as a child 
        // to the scene.
        addChild(StarField())
        
        // Add ship thruster particle to our ship as a child
        if let shipThruster = SKEmitterNode.pdc_nodeWithFile("thrust.sks") {
            
            shipThruster.position = CGPoint(x: 0.0, y: -22.0)
            
            ship.addChild(shipThruster)
            
        }
        
        let shipShield = SKSpriteNode(imageNamed: "spr_shield")
        
        shipShield.alpha = 0.5
        shipShield.position = ship.position
        shipShield.size = CGSize(width: 60.0, height: 60.0)
        
        shipShield.name = ShieldNodeName
        
        addChild(shipShield)
        
        // Set up our HUD
        let hudNode = HUDNode() // instantiating our HUDNode class
        
        hudNode.name = HUDNodeName
        
        // By default, nodes will overlap (stack) according to the order 
        // in which they were added to the scene. If we want to change this
        // order, we can use a node's zPosition property to do so.
        //
        
        hudNode.zPosition = 100.0
        
        // Set the position of our HUD to the center of screen. Noting that
        // all child nodes are positioned relative to the parent node's origin point
        
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2)
        
        addChild(hudNode)
        
        // Lay out of score and elapsed time nodes
        
        hudNode.layoutForScene()
        
        
        // Start the game timer
        
        hudNode.startGame()
        
        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
            
            hud.showHealth(self.shipHealthRate)
            
        }
        
        
        
    }
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        /*for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }*/
        
        // Grab any touches noting that touches is a "set" collection of any 
        // touch event that has occurred.
        if let touch = touches.first {
            
            /*
            // Locate the touch point
            let touchPoint = touch.locationInNode(self)
            
            // We need to reacquire a reference to our ship node
            // in the SceneGraph tree.
            //
            // You can look up a Scene Graph node by passing the node's
            // name string to the scene's childNodeWithName method
            if let ship = self.childNodeWithName(SpaceshipNodeName) {
                ship.position = touchPoint
            }
            */
            
            self.shipTouch = touch
            self.shieldTouch = touch
            
            
        }
        
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        // If the lastUpdateTime property is zero, this is the first frame
        // rendered for this scene.  Set it to the passed-in current time.
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change (delta) since the last frame
        let timeDelta = currentTime - lastUpdateTime
        
        // If the touch is still there (since shipTouch is a weak reference, 
        // it will automatically be set to nil by the touch-handling system 
        // when it releases the touches after they are done), find the ship
        // node in the Scene Graph by its name and update its position property
        // to the point on the screen that was touched.
        //
        // This happens every frame (because we are inside update()) so the 
        // ship will keep up with whereever the user's finger moves to...
        
        if let shipTouch = self.shipTouch {
            
            /*if let ship = self.childNodeWithName(SpaceshipNodeName) {
                ship.position = shipTouch.locationInNode(self)
            }*/
            
            moveShipTowardPoint(shipTouch.location(in: self), timeChange: timeDelta)
            
            // We only want photon torpedos to launch from our ship when
            // the user's finger is in contact with the screen AND if
            // the difference between current time and last time a
            // torpedo was fired is greater than half a second.
            if currentTime - lastShotFireTime > shipFireRate {
                
                shoot()   // fire a photon torpedo
                
                lastShotFireTime = currentTime
                
            }

        }
        
        if let shieldTouch = self.shieldTouch {
            
            moveShieldWithShip(shieldTouch.location(in: self), timeChange: timeDelta)
        }
        
        
        // Release asteroid obstacles 1.5% of the time a frame is drawn.
        // This number could be altered to increase/decrease game difficulty.
        
        if arc4random_uniform(1000) <= 15 {
            
            //dropAsteroid()
            
            dropThing()
            
        }
        
        checkCollisions()
        
        // Update lastUpdateTime to current time
        lastUpdateTime = currentTime
        
    }
    
    
    
    //
    // Nudge the ship toward the touch point by an appropriate distance
    // amount based on elapsed time (timeDelta) since the last frame.
    //
    func moveShipTowardPoint(_ point: CGPoint, timeChange: TimeInterval) {
        
        // Points per second the ship should travel
        let shipSpeed = CGFloat(300)
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Using the Pythagorean Theorem, determine the distance
            // between the ship's current position and the point
            // the was passed in (touch point).
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            // If the distance left to travel is greater than 4 points,
            // keep moving the ship.
            // Otherwise, stop moving the ship because we may experience
            // "jitter" around the touch point (due to imprecision in 
            // floating point numbers) if we get too close.
            //
            if distanceLeftToTravel > 4 {
                
                // Calculate how far we should move the ship during this frame
                let howFarToMove = CGFloat(timeChange) * shipSpeed
                
                // Convert the distance remaining back into (x,y) coordinates
                // using the atan2() function to determine the proper angle
                // based on ship's position and destination.
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                
                // Then, using the angle with sine and cosine trig functions
                // determine the x and y offset values
                let xOffset = howFarToMove * cos(angle)
                let yOffset = howFarToMove * sin(angle)
                
                // Use the offsets to reposition the ship
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
                
            }
            
        }
        
    }
    
    func moveShieldWithShip(_ point: CGPoint, timeChange: TimeInterval) {
        
        let shieldSpeed = CGFloat(300)
        
        if let shield = self.childNode(withName: ShieldNodeName) {
            
            // Using the Pythagorean Theorem, determine the distance
            // between the ship's current position and the point
            // the was passed in (touch point).
            let distanceLeftToTravel = sqrt(pow(shield.position.x - point.x, 2) + pow(shield.position.y - point.y, 2))
            
            // If the distance left to travel is greater than 4 points,
            // keep moving the ship.
            // Otherwise, stop moving the ship because we may experience
            // "jitter" around the touch point (due to imprecision in
            // floating point numbers) if we get too close.
            //
            if distanceLeftToTravel > 4 {
                
                // Calculate how far we should move the ship during this frame
                let howFarToMove = CGFloat(timeChange) * shieldSpeed
                
                // Convert the distance remaining back into (x,y) coordinates
                // using the atan2() function to determine the proper angle
                // based on ship's position and destination.
                let angle = atan2(point.y - shield.position.y, point.x - shield.position.x)
                
                // Then, using the angle with sine and cosine trig functions
                // determine the x and y offset values
                let xOffset = howFarToMove * cos(angle)
                let yOffset = howFarToMove * sin(angle)
                
                // Use the offsets to reposition the ship
                shield.position = CGPoint(x: shield.position.x + xOffset, y: shield.position.y + yOffset)
                
            }
            
        }
        
        
    }
    
    
    //
    // Shoot a photon torpedo from our ship
    //
    func shoot() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            let photon = SKSpriteNode(imageNamed: "photon")
            
            photon.name = PhotonTorpedoNodeName
            photon.position = ship.position
            self.addChild(photon)
            
            // Create a sequence of actions (SKAction class) that will
            // move the torpedos up and off the top of the screen and 
            // then remove them so they don't continue to take up memory.
            // Otherwise, we'd have a memory leak.
            
            //
            // Move the torpedo from its original position (ship) past
            // the top edge of the scene (by the size of the photon) over
            // half a second.  The y-axis in SpriteKit is flipped back to 
            // normal.  (0,0) is the bottom-left corner and scene height
            // (self.size.height) is the top edge of the scene.
            //
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
            
            // Run the previous action
            //photon.runAction(fly)
            
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            self.run(self.shootSound)
            
        }
        
    }
    
    
    func dropThing() {
        
        let dieRoll = arc4random_uniform(100)  // value between 0 and 99
        
        if dieRoll < 10 {
            dropWeaponsPowerUp()
        } else if dieRoll < 25 {
            dropEnemyShip()
        } else if dieRoll < 28 {
            dropHealth()
        } else {
            dropAsteroid()
        }
        
    }
    
    
    func dropAsteroid() {
        
        // Define asteroid size - will be a random number between 15 and 44
        let sideSize = Double(arc4random_uniform(30) + 15)
        
        // Maximum x-value for the scene
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        let randRange = UInt32(maxX + (quarterX * 2))
        
        // arc4random_uniform() wants a UInt32 value passed to it....
        //
        // Determine random starting value for asteroid's x-position
        let startX = Double(arc4random_uniform(randRange)) - quarterX
        
        let startY = Double(self.size.height) + sideSize
        
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        
        let endY = 0.0 - sideSize   // below bottom edge
        
        // Create the asteroid sprite
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        
        asteroid.position = CGPoint(x: startX, y: startY)
        
        asteroid.name = ObstacleNodeName
        
        self.addChild(asteroid)
        
        // Run some actions to get our asteroid moving...
        //
        // Move the asteroid to a randomly generated point over
        // a duration of between 3 and 6 seconds
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(arc4random_uniform(4) + 3))
        
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Rotate the asteroid by 3 radians (just less than 180 degrees)
        // over 1-3 seconds duration
        let spin = SKAction.rotate(byAngle: 3, duration: Double(arc4random_uniform(3) + 1))
        
        let spinForever = SKAction.repeatForever(spin)
        
        let all = SKAction.group([travelAndRemove, spinForever])
        
        asteroid.run(all)
        
        
    }
    
    func dropHealth() {
        
        let sideSize = 20.0
        
        // Determine random starting value for enemy ship's x and y-positions
        let startX = Double(arc4random_uniform(uint(self.size.width - 40)))
        
        let startY = Double(self.size.height) + sideSize
        
        let endY = 0 - sideSize
        
        // Create enemy ship and set its properties
        let shipHealth = SKSpriteNode(imageNamed: "healthPowerUp")
        
        shipHealth.size = CGSize(width: sideSize, height: sideSize)
        shipHealth.position = CGPoint(x: startX, y: startY)
        
        shipHealth.name = ShipHealthNodeName
        
        self.addChild(shipHealth)
        
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 5)
        
        let scaleDown = SKAction.scale(to: 0.5, duration: 5)
        
        let fadeOut = SKAction.fadeOut(withDuration: 5)
        
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        let spinForever = SKAction.repeatForever(SKAction.rotate(byAngle: 1, duration: 1))
        
        shipHealth.run(SKAction.group([spinForever, travelAndRemove, scaleDown, fadeOut]))

        
    }
    
    
    func dropEnemyShip() {
        
        let sideSize = 30.0
        
        // Determine random starting value for enemy ship's x and y-positions
        let startX = Double(arc4random_uniform(uint(self.size.width - 40)) + 20)
        
        let startY = Double(self.size.height) + sideSize
        
        // Create enemy ship and set its properties
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        // Set up enemy movement
        //
        // We want the enemy ship to follow a curved (Bezier) path
        // which uses control points to define how the curved path
        // is formed.  The following method will return that path.
        let shipPath = buildEnemyShipMovementPath()
        
        
        // Use the provided path to move our enemy ship
        //
        // asOffset parameter: if set to true, lets us treat
        // the actual point values of the path as offsets from
        // the enemy ship's starting point.  A false value would
        // treat the path's points as absolute positions on the screen.
        //
        // orientToPath: if true, causes the enemy ship to turn
        // and face the direction of the path automatically.
        //
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        let remove = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([followPath, remove]))
        
    }
    
    
    
    func buildEnemyShipMovementPath() -> CGPath {
    
        let yMax = -1.0 * self.size.height
        
        // Bezier path produced using PaintCode app (www.paintcodeapp.com)
        //
        // Use the UIBezierPath class to build an object that adds points
        // with two control points per point to construct a curved path.
        //
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5, y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32, y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: -63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        //bezierPath.addCurveToPoint(CGPointMake(-2.5, -644.5), controlPoint1: CGPointMake(-5.2, -578.93), controlPoint2: CGPointMake(-2.5, -644.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
    
    }
    
    
    //
    // Create a powerUp sprite which spins and moves from top to bottom of screen
    //
    func dropWeaponsPowerUp() {
        
        let sideSize = 30.0
        
        // Determine random starting value for powerup's x and y-positions
        let startX = Double(arc4random_uniform(uint(self.size.width - 60)) + 30)
        
        let startY = Double(self.size.height) + sideSize
        
        let endY = 0 - sideSize
        
        // Create enemy ship and set its properties
        let powerUp = SKSpriteNode(imageNamed: "powerup")
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        
        powerUp.name = PowerUpNodeName
        
        self.addChild(powerUp)
        
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 6)
        
        let remove = SKAction.removeFromParent()
        
        let travelAndRemove = SKAction.sequence([move, remove])
        
        let spinForever = SKAction.repeatForever(SKAction.rotate(byAngle: 1, duration: 1))
        
        powerUp.run(SKAction.group([spinForever, travelAndRemove]))

        
    }
    
    
    //
    // Implement collision detection by looping (iterating) over all the 
    // nodes involved potentially in the collision in the Scene Graph node treee
    // and checking if their frames intersects.
    //
    func checkCollisions() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            enumerateChildNodes(withName: PowerUpNodeName) {
                powerUp, _ in
                
                if ship.intersects(powerUp) {
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        
                        hud.showPowerupTimer(self.powerUpDuration)
                        
                    }
                    
                    powerUp.removeFromParent()
                    
                    // Increase the ship's fire rate
                    self.shipFireRate = 0.1
                    
                    // But, we need to power back down after a delay
                    // so we are not unbeatable.
                    
                    let powerDown = SKAction.run {
                        
                        self.shipFireRate = self.defaultFireRate
                        
                    }
                    
                    // Now, let's set up a delay of 5 seconds before
                    // this powerup powers down.
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    //ship.runAction(waitAndPowerDown)
                    
                    // Ok, we have an issue.  If our ship collides with 
                    // another powerup while a powerup is already in progress
                    // we don't get the benefit of a full powerup reset.
                    // Why?
                    // 
                    // The first powerDown runBlock will run and restore the 
                    // normal rate of fire too soon.
                    
                    //
                    // Sprite Kit lets us run actions with a descriptive key
                    // that we can use to identify and remove the action before
                    // they've had a chance to run or finish.
                    // 
                    // If no key is found, nothing changes...
                    //
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    
                    ship.run(waitAndPowerDown, withKey: powerDownActionKey)
                    
                }
                
            }
            
            enumerateChildNodes(withName: ShipHealthNodeName) {
                
                shipHealth, _ in
                
                if ship.intersects(shipHealth) {
                    
                    let shield = self.childNode(withName: self.ShieldNodeName)
                    
                    shipHealth.removeFromParent()
                    
                    
                    self.shipHealthRate = 4.0
                    shield!.alpha = 1.0
                    
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        
                        hud.showHealth(self.shipHealthRate)
                        
                    }
                    
                    
                    
                }
                
            }
            
            
            
            // This method will execute its code block for every
            // node in the Scene Graph tree that is an "obstacle" node.
            //
            // This method will automatically populate the local
            // identifier obstacle with a reference to each (next)
            // "obstacle" node it found...
            enumerateChildNodes(withName: ObstacleNodeName) {
                obstacle, _ in
                
                let shield = self.childNode(withName: self.ShieldNodeName)
                
                // check for collision between our obstacle and the ship
                if ship.intersects(obstacle) {
                    
                    
                    
                    // Remove obstacle
                
                    obstacle.removeFromParent()
                
                    if (self.shipHealthRate == 0.0) {
                        
                        
                        // Set shipTouch property to nil so it will not be used
                        // by our shooting logic in the update() method to continue
                        // to track the touch and shoot photon torpedos.  If this
                        // doesn't work, the torpedos will be shot up from (0, 0)
                        // since ship is gone.
                        //
                        
                        
                        self.shipTouch = nil
                        self.shieldTouch = nil
                            
                        ship.removeFromParent()
                        shield!.removeFromParent()
                        
                        // run ship explosion sound
                        self.run(self.shipExplodeSound)
                        
                        // Call copy() on the shipExplodeTemplate node because
                        // nodes can only be added to a scene once.
                        //
                        // If we try to add a node that already exists in a scene,
                        // the game will crash with an error message. We must add
                        // copies of particle emitter nodes and we will use 
                        // the emitter node in our cached class property as a template
                        // from which to make these copies.
                        //
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = ship.position
                        explosion.pdc_dieOutInDuration(0.3)
                        
                        self.addChild(explosion)
                        
                        // Stop game timer
                        
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            
                            hud.endGame()
                            
                        }
                        
                    } else {
                        
                        self.shipHealthRate -= 1
                        
                        shield!.alpha -= 0.25
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            
                            hud.showHealth(self.shipHealthRate)
                            
                        }
                        
                    }
                }
                
                
                // Add an inner loop inside our check for ship v. obstacle
                // collisions to check if any of our photon torpedos collide
                // with our obstacle.
                self.enumerateChildNodes(withName: self.PhotonTorpedoNodeName) {
                    myPhoton, stop in
                    
                    if myPhoton.intersects(obstacle) {
                        
                        myPhoton.removeFromParent()
                        obstacle.removeFromParent()
                        
                        // Run obstacle explosion sound
                        self.run(self.obstacleExplodeSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        explosion.pdc_dieOutInDuration(0.1)
                        
                        self.addChild(explosion)
                        
                        // Update our score in the HUD
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            
                            let score = 10
                            
                            hud.addPoints(score)
                            
                        }
                        
                        // Set stop.memory to true to end this inner loop
                        //
                        // This is a lot like a break statement in other languages.
                        stop.pointee = true
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    

}
