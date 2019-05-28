//
//  GameScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let battleshipDelegate: BattleshipDelegate
    let opponentBoardView: BoardView
    let myBoardView: BoardView
    var hitTexture: SKTexture?
    var missTexture: SKTexture?
    var smallHitTexture: SKTexture?
    var smallMissTexture: SKTexture?
    let instructionText: SKLabelNode
    var waitingForShoot: Bool = true
    
    init(delegate: BattleshipDelegate, myBoard: Board, opponentBoard: Board, size: CGSize) {
        self.battleshipDelegate = delegate
        let margin = size.width/10
        let cellSize = (size.width-margin*2)/CGFloat(opponentBoard.width)
        
        self.opponentBoardView = BoardView(board: opponentBoard, cellSize: cellSize, scale: 1.0)
        opponentBoardView.anchorPoint = CGPoint(x: 0, y: 1)
        opponentBoardView.position = CGPoint(x: margin,y: size.height-margin/2-30)
        
        self.myBoardView = BoardView(board: myBoard, cellSize: cellSize/2, scale: 0.5, showShootMarking: true)
        myBoardView.anchorPoint = CGPoint(x: 0, y: 1)
        myBoardView.position = CGPoint(x: myBoardView.size.width-margin,y: size.height-margin/2-opponentBoardView.size.height-margin/2-15)
        
        instructionText = SKLabelNode(fontNamed:"Chalkduster")
        instructionText.color = UIColor.white
        instructionText.fontSize = 18
        instructionText.position = CGPoint(x:size.width/2.0, y:size.height-30);

        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        opponentBoardView.hideShips(hide: true)
        addChild(opponentBoardView)
        addChild(myBoardView)
        
        instructionText.text = "\(myBoardView.board.name) fire your canon"
        addChild(instructionText)

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        shoot(position: touchLocation)
    }
    
    func readyForShoot() {
        instructionText.text = "Fire your canon"
        waitingForShoot = true
    }
    
    func opponentShoot(x: Int, y: Int) {
        let hitShip = myBoardView.board.shipAtPosition(x, y)
        let hit = (hitShip != nil)
        hitShip?.shoot(x, y)
        myBoardView.board.registerShoot(x: x, y: y, hit: hit)
        
        if let hitShip = hitShip {
            if hitShip.isDestroyed() {
                battleshipDelegate.shootResult(playerName: myBoardView.board.name, x: x, y: y, hit: true, destroyedShip: hitShip)
            }else {
                battleshipDelegate.shootResult(playerName: myBoardView.board.name, x: x, y: y, hit: true, destroyedShip: nil)
            }
        }else {
            battleshipDelegate.shootResult(playerName: myBoardView.board.name, x: x, y: y, hit: false, destroyedShip: nil)
        }
    }
        
    func shoot(position: CGPoint) {
        if !waitingForShoot {
            return
        }
        let cellX = Int((position.x-opponentBoardView.position.x)/opponentBoardView.cellSize)
        let cellY = Int((opponentBoardView.position.y-position.y)/opponentBoardView.cellSize)
        if cellX>=0 && cellX<opponentBoardView.board.width && cellY>=0 && cellY<opponentBoardView.board.height {
            if opponentBoardView.board.shoots[cellX,cellY] == nil {
                waitingForShoot = false
                instructionText.text = "Waiting for opponent"
                battleshipDelegate.shoot(playerName: myBoardView.board.name, x: cellX, y: cellY)
            }
        }
    }
    
    func shootResult(x: Int, y: Int, hit: Bool) {
        print("Checking if gameOver count=\(opponentBoardView.board.ships.count) and allShipsDestroyed=\(opponentBoardView.board.isAllShipsDestroyed())")
        if opponentBoardView.board.ships.count == myBoardView.board.ships.count && opponentBoardView.board.isAllShipsDestroyed() {
            battleshipDelegate.gameOver(board: myBoardView.board, won: true)
        }

    }

}
