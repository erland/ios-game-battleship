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
        
        self.opponentBoardView = BoardView(board: opponentBoard, cellSize: cellSize)
        opponentBoardView.anchorPoint = CGPoint(x: 0, y: 1)
        opponentBoardView.position = CGPoint(x: margin,y: size.height-margin/2-30)
        
        self.myBoardView = BoardView(board: myBoard, cellSize: cellSize/2)
        myBoardView.anchorPoint = CGPoint(x: 0, y: 1)
        myBoardView.position = CGPoint(x: myBoardView.size.width-margin,y: size.height-margin/2-opponentBoardView.size.height-margin/2-15)
        
        self.hitTexture = GameScene.createHitTexture(cellSize: cellSize, strokeColor: UIColor.green, fillColor: UIColor.green)
        self.missTexture = GameScene.createHitTexture(cellSize: cellSize, strokeColor: UIColor.darkGray, fillColor: UIColor.darkGray)
        self.smallHitTexture = GameScene.createHitTexture(cellSize: cellSize/2, strokeColor: UIColor.green, fillColor: UIColor.green)
        self.smallMissTexture = GameScene.createHitTexture(cellSize: cellSize/2, strokeColor: UIColor.darkGray, fillColor: UIColor.darkGray)

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
    
    func shoot(x: Int, y: Int) {
        var result: Bool = false
        if x>=0 && x<myBoardView.board.width && y>=0 && y<myBoardView.board.height {
            result = processShoot(boardView: myBoardView, x: x, y: y, small: true, won: false)
        }
        battleshipDelegate.shootResult(playerName: myBoardView.board.name, x: x, y: y, hit: result)
    }
        
    func shoot(position: CGPoint) {
        if !waitingForShoot {
            return
        }
        let cellX = Int((position.x-opponentBoardView.position.x)/opponentBoardView.cellSize)
        let cellY = Int((opponentBoardView.position.y-position.y)/opponentBoardView.cellSize)
        if cellX>=0 && cellX<opponentBoardView.board.width && cellY>=0 && cellY<opponentBoardView.board.height {
            waitingForShoot = false
            instructionText.text = "Waiting for opponent"
            battleshipDelegate.shoot(playerName: myBoardView.board.name, x: cellX, y: cellY)
        }
    }
    
    func shootResult(x: Int, y: Int, hit: Bool) {
        processShoot(boardView: opponentBoardView, x: x, y: y, small: false, won: true)
    }

    private func processShoot(boardView: BoardView, x: Int, y: Int, small: Bool, won: Bool) -> Bool {
        let selectedShip = boardView.board.shipAtPosition(x: x,
                                                                  y: y)
        if let selectedShip = selectedShip {
            if selectedShip.shoot(x: x, y: y) {
                var texture: SKTexture? = self.hitTexture
                if small {
                    texture = smallHitTexture
                }
                let hit = SKSpriteNode(texture: texture!)
                hit.anchorPoint = CGPoint(x: 0, y: 1)
                hit.position = CGPoint(x: CGFloat(x)*boardView.cellSize,
                                       y: -CGFloat(y)*boardView.cellSize)
                boardView.addChild(hit)
                if selectedShip.isDestroyed() {
                    if let shipView = boardView.viewForShip(ship: selectedShip)  {
                        shipView.alpha=1
                    }
                }
                if boardView.board.isAllShipsDestroyed() {
                    battleshipDelegate.gameOver(board: opponentBoardView.board, won: won)
                }
                return true
            }
        }else {
            var texture: SKTexture? = self.missTexture
            if !won {
                texture = smallMissTexture
            }
            let hit = SKSpriteNode(texture: texture!)
            hit.anchorPoint = CGPoint(x: 0, y: 1)
            hit.position = CGPoint(x: CGFloat(x)*boardView.cellSize,
                                   y: -CGFloat(y)*boardView.cellSize)
            boardView.addChild(hit)
        }
        return false

    }
    private class func createHitTexture(cellSize: CGFloat, strokeColor: UIColor, fillColor: UIColor) -> SKTexture? {
        let size = (cellSize-cellSize/10.0)
        let shape = SKShapeNode.init(circleOfRadius: size/2.0)
        shape.fillColor = fillColor
        shape.strokeColor = strokeColor
        let view = SKView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        return view.texture(from: shape)
    }

}
