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
    let myBoardView: BoardView
    let opponentBoardView: BoardView
    let won: Bool
    
    init(delegate: BattleshipDelegate, size: CGSize, myBoard: Board, opponentBoard: Board, won: Bool) {
        self.battleshipDelegate = delegate
        self.won = won

        let margin = size.width/20
        let cellSize = (size.width-margin*3)/CGFloat(opponentBoard.width+myBoard.width)
        self.opponentBoardView = BoardView(board: opponentBoard, cellSize: cellSize)
        opponentBoardView.anchorPoint = CGPoint(x: 0, y: 1)
        opponentBoardView.position = CGPoint(x: margin,y: size.height*0.5-45)
        
        self.myBoardView = BoardView(board: myBoard, cellSize: cellSize)
        myBoardView.anchorPoint = CGPoint(x: 0, y: 1)
        myBoardView.position = CGPoint(x: margin+myBoardView.size.width+margin,y: size.height*0.5-45)

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
        winnerText.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        addChild(winnerText)
        addChild(myBoardView)
        addChild(opponentBoardView)
        let opponentBoardText = SKLabelNode(fontNamed:"Chalkduster")
        opponentBoardText.text = "Your hits"
        opponentBoardText.fontSize = 15
        opponentBoardText.position = CGPoint(x: size.width/20+myBoardView.size.width/2,
                                       y: size.height*0.5-30)
        addChild(opponentBoardText)
        
        let myBoardText = SKLabelNode(fontNamed:"Chalkduster")
        myBoardText.text = "Opponent hits"
        myBoardText.fontSize = 15
        myBoardText.position = CGPoint(x: size.width/20+myBoardView.size.width+size.width/20+opponentBoardView.size.width/2,
                                             y: size.height*0.5-30)
        addChild(myBoardText)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        battleshipDelegate.finishedGame()
    }
}
