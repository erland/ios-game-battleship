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
    var opponents : [SKLabelNode] = []
    
    init(delegate: BattleshipDelegate, size: CGSize) {
        self.battleshipDelegate = delegate
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        waitingText = SKLabelNode(fontNamed:"Chalkduster")
        waitingText?.fontSize = 30
        waitingText?.position = CGPoint(x: size.width * 0.5, y: size.height * 0.65)
        updateInstructionText()
        addChild(waitingText!)
        for i in 0..<5 {
            let opponent = SKLabelNode(fontNamed:"Chalkduster")
            opponent.text = ""
            opponent.fontSize = 20
            opponent.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55-CGFloat(i)*size.height/20.0)
            opponents.append(opponent)
            addChild(opponent)
        }
    }
    
    func addOpponent(name: String) {
        for opponent in opponents {
            if opponent.text == "" {
                opponent.text = name
                break
            }
        }
        updateInstructionText()
    }
    
    func removeOpponent(name: String) {
        for opponent in opponents {
            if opponent.text == name {
                opponent.text = ""
                break
            }
        }
        updateInstructionText()
    }
    
    private func updateInstructionText() {
        waitingText?.text = "Waiting for opponent"
        for opponent in opponents {
            if opponent.text != "" {
                waitingText?.text = "Select opponent"
                break
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        for opponent in opponents {
            if opponent.frame.contains(touch.location(in: self)) {
                battleshipDelegate.selectedOpponent(player: opponent.text!)
                break
            }
        }
    }
    
}
