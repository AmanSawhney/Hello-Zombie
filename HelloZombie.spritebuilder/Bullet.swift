//
//  Bullet.swift
//  ZombieDash
//
//  Created by Gagandeep Sawhney on 7/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Bullet: CCNode{
    
    func didLoadFromCCB(){
        var delay = CCActionDelay(duration: 1)
        var remove = CCActionCallBlock(block: {self.removeFromParent()})
        
        runAction(CCActionSequence(array: [delay, remove]))
    }
}