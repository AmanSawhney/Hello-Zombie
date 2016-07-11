//
//  StartScreen.swift
//  ZombieDash
//
//  Created by Gagandeep Sawhney on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import UIKit
import GameKit
import StoreKit
class StartScreen: CCScene {
    weak var sfxButton: CCButton!
    weak var backgroundButton: CCButton!
    func didLoadFromCCB() {
        GameCenterHelper.sharedInstance.authenticationCheck()
        //OALSimpleAudio.sharedInstance().playBg("8bitmelody.wav")
        userInteractionEnabled = true
        
    }
    override func update(delta: CCTime) {
        
        backgroundButton.selected = OALSimpleAudio.sharedInstance().bgMuted
        sfxButton.selected = OALSimpleAudio.sharedInstance().effectsMuted
        
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if animationManager.runningSequenceName != nil {
            if animationManager.runningSequenceName == "Settings Timeline"  {
                animationManager.runAnimationsForSequenceNamed("GOAWAY Timeline")
            }
        }
    }
    override func onEnter() {
        super.onEnter()
    }
    func sfx() {
        OALSimpleAudio.sharedInstance().effectsMuted = !OALSimpleAudio.sharedInstance().effectsMuted
    }
    func settings() {
        if animationManager.runningSequenceName != "Settings Timeline" || animationManager.runningSequenceName == nil {
            animationManager.runAnimationsForSequenceNamed("Settings Timeline")
        }else {
            animationManager.runAnimationsForSequenceNamed("GOAWAY Timeline")
        }
    }
    func backgroundMusic() {
        OALSimpleAudio.sharedInstance().bgMuted = !OALSimpleAudio.sharedInstance().bgMuted
    }
    func play() {
        animationManager.runAnimationsForSequenceNamed("Play Timeline")
        var delay = CCActionDelay(duration: 1)
        
        let scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
}

