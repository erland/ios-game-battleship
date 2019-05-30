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
    
    var battleshipDelegate: BattleshipDelegate?
    var instructionText : SKLabelNode?
    var opponents : [SKLabelNode] = []
    
    func setup(delegate: BattleshipDelegate) {
        self.battleshipDelegate = delegate
    }
    
    override func didMove(to view: SKView) {
        instructionText = childNode(withName: "instructionText") as? SKLabelNode
        updateInstructionText()

        enumerateChildNodes(withName: "opponent") {
            (node, _) in
            
            if let node = node as? SKLabelNode {
                node.text = ""
                self.opponents.append(node)
            }
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
        instructionText?.text = "Waiting for opponent"
        for opponent in opponents {
            if opponent.text != "" {
                instructionText?.text = "Select opponent"
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
                battleshipDelegate?.selectedOpponent(player: opponent.text!)
                break
            }
        }
    }
    
}
