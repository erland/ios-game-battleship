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
    var battleshipDelegate: BattleshipDelegate?
    var myBoardView: BoardView?
    var opponentBoardView: BoardView?
    var won: Bool = false
    
    
    override func sceneDidLoad() {
        localize()
    }

    func setup(delegate: BattleshipDelegate, myBoard: Board, opponentBoard: Board, won: Bool) {
        self.battleshipDelegate = delegate
        self.won = won

        self.opponentBoardView = childNode(withName:"opponentBoard") as? BoardView
        self.opponentBoardView?.setup(board: opponentBoard)
    
        self.myBoardView = childNode(withName:"myBoard") as? BoardView
        self.myBoardView?.setup(board: myBoard)
    }
    
    override func didMove(to view: SKView) {
        let gameOverText = childNode(withName: "gameOverText") as? SKLabelNode

        let winnerText = childNode(withName: "winnerText") as? SKLabelNode
        if won {
            gameOverText?.text = NSLocalizedString("success", comment: "success")
            winnerText?.text = NSLocalizedString("youWon", comment: "youWon")
        }else {
            gameOverText?.text = NSLocalizedString("gameOver", comment: "gameOver")
            winnerText?.text = NSLocalizedString("youLost", comment: "youLost")
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        battleshipDelegate?.finishedGame()
    }
}
