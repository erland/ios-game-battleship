//
//  MatchMakingScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class MatchMakingScene: SKScene {
    
    let battleshipDelegate: BattleshipDelegate
    var waitingText : SKLabelNode?
    var opponentFound : SKLabelNode?
    
    init(delegate: BattleshipDelegate, size: CGSize) {
        self.battleshipDelegate = delegate
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        waitingText = SKLabelNode(fontNamed:"Chalkduster")
        waitingText?.text = "Waiting for opponent"
        waitingText?.fontSize = 20
        waitingText?.position = CGPoint(x: size.width * 0.5, y: size.height * 0.65)
        addChild(waitingText!)
        opponentFound = SKLabelNode(fontNamed:"Chalkduster")
        opponentFound?.text = ""
        opponentFound?.fontSize = 20
        opponentFound?.position = CGPoint(x: size.width * 0.5, y: size.height * 0.50)
        addChild(opponentFound!)

    }
    
    func addOpponent(name: String) {
        waitingText?.text = "Select opponent"
        opponentFound?.text = name
    }
    
    func removeOpponent(name: String) {
        if opponentFound?.text == name {
            waitingText?.text = "Waiting for opponent"
            opponentFound?.text = ""
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if opponentFound?.text != "" {
            battleshipDelegate.selectedOpponent(player: opponentFound!.text!)
        }
    }
    
}
