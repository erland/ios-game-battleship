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
    let gameBoard: Board
    var hitTexture: SKTexture?
    var missTexture: SKTexture?
    
    init(board: Board, size: CGSize) {
        self.gameBoard = board
        self.hitTexture = GameScene.createHitTexture(cellSize: gameBoard.cellSize, strokeColor: UIColor.green, fillColor: UIColor.green)
        self.missTexture = GameScene.createHitTexture(cellSize: gameBoard.cellSize, strokeColor: UIColor.darkGray, fillColor: UIColor.darkGray)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        gameBoard.hideShips(hide: true)
        addChild(gameBoard)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        shoot(position: touchLocation)
    }
    
    func shoot(position: CGPoint) {
        let cellX = Int((position.x-gameBoard.position.x)/gameBoard.cellSize)
        let cellY = Int((gameBoard.position.y-position.y)/gameBoard.cellSize)
        if cellX>=0 && cellX<gameBoard.width && cellY>=0 && cellY<gameBoard.height {
            let selectedShip = gameBoard.shipAtPosition(x: cellX,
                                                    y: cellY)
            if selectedShip != nil {
                let hit = SKSpriteNode(texture: hitTexture)
                hit.anchorPoint = CGPoint(x: 0, y: 1)
                hit.position = CGPoint(x: CGFloat(cellX)*gameBoard.cellSize,
                                       y: -CGFloat(cellY)*gameBoard.cellSize)
                gameBoard.addChild(hit)
            }else {
                let hit = SKSpriteNode(texture: missTexture)
                hit.anchorPoint = CGPoint(x: 0, y: 1)
                hit.position = CGPoint(x: CGFloat(cellX)*gameBoard.cellSize,
                                       y: -CGFloat(cellY)*gameBoard.cellSize)
                gameBoard.addChild(hit)
            }
        }
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
