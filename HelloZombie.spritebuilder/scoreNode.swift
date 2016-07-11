//
//  scoreNode.swift
//  ZombieDash
//
//  Created by Gagandeep Sawhney on 7/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class scoreNode: CCNode {
    weak var ones: CCSprite!
    weak var tens: CCSprite!
    weak var hundreds: CCSprite!
    override func update(delta: CCTime) {
        hundreds.spriteFrame = CCSpriteFrame(imageNamed: "HUD/Numbers_\((Int(Double(score)/100)%10)).png")
        tens.spriteFrame = CCSpriteFrame(imageNamed: "HUD/Numbers_\((Int(Double(score)/10)%10)).png")
        ones.spriteFrame = CCSpriteFrame(imageNamed: "HUD/Numbers_\((Int(Double(score)/1)%10)).png")
    }
}
