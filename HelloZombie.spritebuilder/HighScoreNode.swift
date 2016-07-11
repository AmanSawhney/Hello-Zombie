//
//  HighScoreNode.swift
//  ZombieDash
//
//  Created by Gagandeep Sawhney on 8/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import StoreKit

class HighScoreNode: CCNode {
    weak var ones: CCSprite!
    weak var tens: CCSprite!
    weak var hundreds: CCSprite!
    override func update(delta: CCTime) {
        var highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        GameCenterHelper.sharedInstance.saveHighScore(Double(highScore))
        hundreds.spriteFrame = CCSpriteFrame(imageNamed: "HUD/Numbers_\((Int(Double(highScore)/100)%10)).png")
        tens.spriteFrame = CCSpriteFrame(imageNamed: "HUD/Numbers_\((Int(Double(highScore)/10)%10)).png")
        ones.spriteFrame = CCSpriteFrame(imageNamed: "HUD/Numbers_\((Int(Double(highScore)/1)%10)).png")
    }
}
extension HighScoreNode: GKGameCenterControllerDelegate {
    
    func showLeaderboard() {
        
        var viewController = CCDirector.sharedDirector().parentViewController!
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
        
    }
    
    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

