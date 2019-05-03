//
//  GameOverScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    let battleshipDelegate: BattleshipDelegate
    let won: Bool
    
    init(delegate: BattleshipDelegate, size: CGSize, won: Bool) {
        self.battleshipDelegate = delegate
        self.won = won
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        let gameOverText = SKLabelNode(fontNamed:"Chalkduster")
        gameOverText.text = "GameOver!"
        gameOverText.fontSize = 55
        gameOverText.position = CGPoint(x: size.width * 0.5, y: size.height * 0.65)
        addChild(gameOverText)

        let winnerText = SKLabelNode(fontNamed:"Chalkduster")
        if won {
            gameOverText.text = "You won!"
            winnerText.text = ""
        }else {
            winnerText.text = "You lost"
        }
        winnerText.fontSize = 35
        winnerText.position = CGPoint(x: size.width * 0.5, y: size.height * 0.50)
        addChild(winnerText)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        battleshipDelegate.finishedGame()
    }
}
