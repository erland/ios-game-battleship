//
//  GameScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-28.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlacementScene: SKScene {
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    var selectedShip: Ship?
    var selectedOffset: CGPoint?
    var rotateMode: Bool = false
    var gameBoard: Board
    var button: SKSpriteNode
    var battleshipDelegate: BattleshipDelegate
    
    let gridSize = 10
    
    init(delegate: BattleshipDelegate, size: CGSize) {
        let margin = size.width/20
        let cellSize = (size.width-margin*2)/CGFloat(gridSize)
        battleshipDelegate = delegate
        gameBoard = Board.init(x: gridSize, y: gridSize, cellSize: cellSize)
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1)
        gameBoard.position = CGPoint(x: margin,y: size.height-margin)

        button = SKSpriteNode(color: SKColor.green, size: CGSize(width: 100, height: 44))
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        addChild(gameBoard)
        let carrier = Ship.init(length: 5, cellSize: gameBoard.cellSize)
        gameBoard.addShip(ship: carrier, x: 0, y: 0)
        let battleship = Ship.init(length: 4, cellSize: gameBoard.cellSize)
        gameBoard.addShip(ship: battleship, x: 0, y: 2)
        let crusier = Ship.init(length: 3, cellSize: gameBoard.cellSize)
        gameBoard.addShip(ship: crusier, x: 0, y: 4)
        let submarine = Ship.init(length: 3, cellSize: gameBoard.cellSize)
        gameBoard.addShip(ship: submarine, x: 0, y: 6)
        let destroyer = Ship.init(length: 2, cellSize: gameBoard.cellSize)
        gameBoard.addShip(ship: destroyer, x: 0, y: 8)
        
        button.position = CGPoint(x:self.frame.midX, y:size.height-gameBoard.size.height-100);
        
        self.addChild(button)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if button.contains(touchLocation) {
            battleshipDelegate.placementComplete(board: gameBoard)
        }else {
            selectShip(position: touchLocation)
            rotateMode = true
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        moveSelectedShip(position: touchLocation)
        rotateMode = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if rotateMode {
            rotateSelectedShip()
        }else {
            moveSelectedShip(position: touchLocation)
        }
        if let selectedShip = selectedShip {
            selectedShip.selected = false
        }
        selectedShip = nil
        rotateMode = false
    }
    
    func selectShip(position: CGPoint) {
        let cellX = Int((position.x-gameBoard.position.x)/gameBoard.cellSize)
        let cellY = Int((gameBoard.position.y-position.y)/gameBoard.cellSize)
        selectedShip = gameBoard.shipAtPosition(x: cellX,
                                                y: cellY)
        if let selectedShip = selectedShip {
            selectedShip.selected = true
            selectedOffset = CGPoint(x: position.x-gameBoard.position.x-selectedShip.position.x,
                                     y: gameBoard.position.y-position.y+selectedShip.position.y)
        }else {
            selectedOffset = nil
        }
    }
    func rotateSelectedShip() {
        if let selectedShip = selectedShip {
            gameBoard.rotateShip(ship: selectedShip)
        }
    }

    func moveSelectedShip(position: CGPoint) {
        if let selectedShip = selectedShip {
            if let selectedOffset = selectedOffset {
                let cellX = Int((position.x-gameBoard.position.x-selectedOffset.x)/gameBoard.cellSize)
                let cellY = Int((gameBoard.position.y-position.y-selectedOffset.y)/gameBoard.cellSize)
                gameBoard.moveShip(ship: selectedShip, x: cellX, y: cellY)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
