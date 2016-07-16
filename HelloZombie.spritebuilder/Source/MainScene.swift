import Foundation
import UIKit
import GameKit
import StoreKit

var score: Int!

class MainScene: CCScene, CCPhysicsCollisionDelegate {
    var screenSize = UIScreen.mainScreen().bounds
    let view: UIViewController = CCDirector.sharedDirector().parentViewController! // Returns a UIView of the cocos2d view controller.
    weak var leftFinger: CCSprite!
    weak var rightFinger: CCSprite!
    weak var madScientist: CCSprite! //Main Character
    weak var gameOverNode: CCNode!
    weak var gamePhysicsNode: CCPhysicsNode! //Inits PhysicsNode
    weak var scoreNode: CCNode!
    var speed: Int! //Makes var for the speed that will change during level change
    var buildingLayerArray: [CCNode] = [] // creates array for objects
    var jump: Int!
    var shooting: Bool!
    var zombieArray: [CCSprite] = []
    var ad: Bool!
    var bulletshoot: Bool!
    func didLoadFromCCB() {
        bulletshoot = false
        ad = false
        GameCenterHelper.sharedInstance.authenticationCheck()
        jump = 2
        speed = 200 //Sets Inital Speed
        userInteractionEnabled = true // enables User Interaction
        gamePhysicsNode.collisionDelegate = self // sets colision delegate
        let layer1 = randomLayer()
        layer1.zOrder--
        madScientist.position.y = layer1.contentSizeInPoints.height
        gamePhysicsNode.addChild(layer1)
        buildingLayerArray.append(layer1)
        let layer2 = randomLayer()
        layer2.zOrder--
        layer2.position.x = layer2.contentSizeInPoints.width
        buildingLayerArray.append(layer2)
        gamePhysicsNode.addChild(layer2)
        schedule("spawnZombies", interval: 1)
        score = 0
        shooting = true
        multipleTouchEnabled = true
        
    }
    override func onEnter() {
        super.onEnter()
        let worldBound = CGRect(x: 0, y: 0, width: contentSizeInPoints.width, height: contentSizeInPoints.height) //creates world bounds for follow
        let actionFollow = CCActionFollow(target: madScientist, worldBoundary: worldBound) //creates follow action
        self.runAction(actionFollow) //runs action
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if animationManager.runningSequenceName != "GameOver Timeline" || animationManager.runningSequenceName == nil{
            if touch.locationInWorld().x < CCDirector.sharedDirector().viewSize().width/2 && jump > 0{
                madScientist.animationManager.runAnimationsForSequenceNamed("Jump Timeline") //runs jump
                madScientist.physicsBody.velocity.y = 0
                madScientist.physicsBody.applyImpulse(ccp(0,10000)) //applays upward implus
                jump!--
                if leftFinger != nil {
                    leftFinger.removeFromParentAndCleanup(true)
                }
            }
            if touch.locationInWorld().x > CCDirector.sharedDirector().viewSize().width/2{
                if shooting == true {
                    if bulletshoot == false {
                        let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp((madScientist.contentSize.width)/200, 2)))
                        let moveBack = CCActionEaseBounceOut(action: move.reverse())
                        let shakeSequence1 = CCActionSequence(array: [move, moveBack])
                        madScientist.runAction(shakeSequence1)
                        bulletshoot = true
                        let bullet = CCBReader.load("Bullet")
                        bullet.position = ccp(181.7, 130)
                        madScientist.addChild(bullet)
                        bullet.physicsBody.sensor = true
                        bullet.physicsBody.applyImpulse(ccp(1000,0))
                        scheduleOnce("bulletReset", delay: 0.4)
                        OALSimpleAudio.sharedInstance().playEffect("laser1.wav")
                        
                    }
                    if rightFinger != nil {
                        rightFinger.removeFromParentAndCleanup(true)                    }
                }
            }
        }
        
    }
    func bulletReset() {
        bulletshoot = false
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCSprite!, DEATH: CCNode!) -> Bool {
        hero.zOrder += 10
        if hero.animationManager.runningSequenceName != "Death Timeline"{
            hero.animationManager.runAnimationsForSequenceNamed("Death Timeline")
            NSThread.sleepForTimeInterval(0.022)
            
        }
        hero.physicsBody.sensor = true
        if animationManager.runningSequenceName != "GameOver Timeline" {
            self.animationManager.runAnimationsForSequenceNamed("GameOver Timeline")
            gameOverNode.position.y = 0
        }
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, zombie: CCSprite!, bullet: CCSprite!) -> Bool {
        if zombie.animationManager.runningSequenceName != "Death Timeline" {
            zombie.physicsBody.sensor = true
            zombie.physicsBody.applyImpulse(ccp(1000,0))
            zombie.animationManager.runAnimationsForSequenceNamed("Death Timeline")
            bullet.removeFromParentAndCleanup(true)
            speed! += 2
            score!++
            if self.numberOfRunningActions() == 1 {
                let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0, (zombie.contentSize.width)/20)))
                let moveBack = CCActionEaseBounceOut(action: move.reverse())
                let move1 = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0, -(zombie.contentSize.width)/20)))
                let moveBack1 = CCActionEaseBounceOut(action: move1.reverse())
                let shakeSequence1 = CCActionSequence(array: [move, moveBack, move1, moveBack1])
                self.runAction(shakeSequence1)
                
            }
            
        }
        return true
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, ground: CCNode!) -> Bool {
        jump = 2
        return true
        
        
    }
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, zombie: CCSprite!, hero: CCSprite!) -> Bool {
        if zombie.animationManager.runningSequenceName != "Death Timeline" && hero.animationManager.runningSequenceName != "Death Timeline" && hero.position.y - hero.contentSize.height/2 < zombie.position.y {
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp((zombie.contentSize.width)/2, 0)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let move1 = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0, -(zombie.contentSize.width)/2)))
            let moveBack1 = CCActionEaseBounceOut(action: move1.reverse())
            let shakeSequence1 = CCActionSequence(array: [move, moveBack, move1, moveBack1])
            self.runAction(shakeSequence1)
            zombie.animationManager.runAnimationsForSequenceNamed("Death Timeline")
            zombie.physicsBody.sensor = true
            hero.zOrder += 10
            hero.animationManager.runAnimationsForSequenceNamed("Death Timeline")
            NSThread.sleepForTimeInterval(0.022)
            hero.physicsBody.sensor = true
            self.animationManager.runAnimationsForSequenceNamed("GameOver Timeline")
            gameOverNode.position.y = 0
            speed! += 1
        } else {
            if zombie.animationManager.runningSequenceName != "Death Timeline" {
                let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0 , -(zombie.contentSize.width)/20)))
                let moveBack = CCActionEaseBounceOut(action: move.reverse())
                let shakeSequence1 = CCActionSequence(array: [move, moveBack])
                self.runAction(shakeSequence1)
                zombie.animationManager.runAnimationsForSequenceNamed("Death Timeline")
                NSThread.sleepForTimeInterval(0.062)
                zombie.physicsBody.sensor = true
                zombie.physicsBody.applyImpulse(ccp(0,-1000))
                score!++
                speed! += 2
                
                
            }
        }
        
        return true
    }
    func takePresentScreenshot() -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        
        let size: CGSize = CCDirector.sharedDirector().viewSize()
        let renderTxture: CCRenderTexture = CCRenderTexture(width: Int32(size.width), height: Int32(size.height))
        renderTxture.begin()
        CCDirector.sharedDirector().runningScene.visit()
        renderTxture.end()
        
        return renderTxture.getUIImage()
    }
    func spawnZombies() {
        if madScientist != nil {
            let zombie = CCBReader.load("Zombie") as! CCSprite
            zombie.scale = 0.5
            zombie.position = ccp(madScientist.position.x + CCDirector.sharedDirector().viewSize().width*2, madScientist.position.y + 40)
            zombie.physicsBody.velocity.x = -CGFloat(Double(speed)/2)
            gamePhysicsNode.addChild(zombie)
            zombieArray.append(zombie)
        }
    }
    func retry() {
        let gameScene : CCScene =  CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(gameScene)
    }
    func share() {
        let screenshot = self.takePresentScreenshot()
        
        let objectsToShare = [screenshot]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        if UIDevice.currentDevice().model != "iPad"{
            view.presentViewController(activityVC, animated: true, completion: nil)
        } else {
            
            let popup = UIPopoverController(contentViewController: activityVC)
            popup.presentPopoverFromRect(CGRectMake(screenSize.width/2, screenSize.height/4, 0, 0), inView: CCDirector.sharedDirector().view, permittedArrowDirections: UIPopoverArrowDirection.Unknown, animated: true)
            
        }
        
    }
    func menu() {
        let scene = CCBReader.loadAsScene("StartScreen")
        CCDirector.sharedDirector().presentScene(scene)
    }
    func randomLayer() -> CCNode! {
        var layer = Int(arc4random_uniform(6)) + 1
        if layer >= 7 {
            layer = 6
        }
        return CCBReader.load("BuildingLayer/BuildingLayer\(layer)")
    }
    override func update(delta: CCTime) {
        
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - CGFloat(speed) * CGFloat(delta), gamePhysicsNode.position.y) //moves physicsNode
        let scale = CCDirector.sharedDirector().contentScaleFactor //sets scale
        gamePhysicsNode.position = ccp(round(gamePhysicsNode.position.x * scale) / scale, round(gamePhysicsNode.position.y * scale) / scale) //removes artafacts
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.integerForKey("highscore")) < score {
            defaults.setInteger(score, forKey: "highscore")
        }
        for zombie in zombieArray {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(zombie.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            if groundScreenPosition.x <= (-zombie.contentSize.width) {
                zombie.removeFromParentAndCleanup(true)
                zombieArray.removeAtIndex(zombieArray.indexOf(zombie)!)
                print("REMOVED")
            }
            
        }
        if madScientist != nil {
            if madScientist.animationManager.runningSequenceName == "Death Timeline" {
                if rightFinger != nil {
                    rightFinger.removeFromParentAndCleanup(true)
                }
                if leftFinger != nil {
                    leftFinger.removeFromParentAndCleanup(true)
                }
            }
            let madScientistWorldPosition = gamePhysicsNode.convertToWorldSpace(madScientist.position)
            let madScientistScreenPosition = convertToNodeSpace(madScientistWorldPosition)
            if leftFinger != nil {
                leftFinger.position.y = -self.position.y
            }
            if rightFinger != nil {
                rightFinger.position.y = -self.position.y
            }
            if madScientist.position.y < -madScientist.contentSizeInPoints.height {
                madScientist.removeFromParentAndCleanup(true)
            }
            if madScientistScreenPosition.x < 0 {
                madScientist.zOrder += 10
                if madScientist.animationManager.runningSequenceName != "Death Timeline"{
                    madScientist.animationManager.runAnimationsForSequenceNamed("Death Timeline")
                    NSThread.sleepForTimeInterval(0.022)
                    
                }
                madScientist.physicsBody.sensor = true
                if animationManager.runningSequenceName != "GameOver Timeline" {
                    self.animationManager.runAnimationsForSequenceNamed("GameOver Timeline")
                    gameOverNode.position.y = 0
                }
                
            }
            print("score node position\(scoreNode.position)")
            print("madScients \(madScientistScreenPosition)")
            
            
            if Int(delta)%3 == 0 {
                shooting = true
            } else {
                shooting = false
            }
            madScientist.positionInPoints.x = madScientist.position.x + CGFloat(speed + 1) * CGFloat(delta) //updates madsciencest position
            
            scoreNode.positionInPoints.y = contentSizeInPoints.height * 1.325 - (contentSizeInPoints.height + self.position.y)
            //      scoreNode.position.y = CGFloat(1) - scoreNode.position.y
        }
        for oldLayer in buildingLayerArray {
            let oldLayerWorldPosition = gamePhysicsNode.convertToWorldSpace(oldLayer.position)
            let oldLayerScreenPosition = convertToNodeSpace(oldLayerWorldPosition)
            if oldLayerScreenPosition.x <= (-oldLayer.contentSize.width) {
                buildingLayerArray.removeAtIndex(buildingLayerArray.indexOf(oldLayer)!)
                let newLayer = randomLayer()
                newLayer.position = ccp(oldLayer.position.x + newLayer.contentSize.width * 2, newLayer.position.y)
                oldLayer.removeFromParentAndCleanup(true)
                
                buildingLayerArray.append(newLayer)
                gamePhysicsNode.addChild(newLayer)
            }
        }
    }
}



// MARK: Game Center Handling
extension MainScene: GKGameCenterControllerDelegate {
    
    func showLeaderboard() {
        //
        //        var viewController = CCDirector.sharedDirector().parentViewController!
        //        var gameCenterViewController = GKGameCenterViewController()
        //        gameCenterViewController.gameCenterDelegate = self
        //        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
        
    }
    
    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


