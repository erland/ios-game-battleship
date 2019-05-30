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
    var selectedOffsetX: Int?
    var selectedOffsetY: Int?
    var rotateMode: Bool = false
    var gameBoard: BoardView?
    var button: SKSpriteNode?
    var buttonText: SKLabelNode?
    var battleshipDelegate: BattleshipDelegate?
    var lastTouchX : Int?
    var lastTouchY : Int?
    
    let gridSize = 10
    
    func setup(delegate: BattleshipDelegate, board: Board, ships: [Ship]) {
        battleshipDelegate = delegate
        gameBoard = childNode(withName: "board") as? BoardView
        gameBoard?.setup(board: board)
        for (i, ship) in ships.enumerated() {
            board.addShip(ship: ship, x: 0, y: i*2)
        }
    }
    
    override func didMove(to view: SKView) {
        button = childNode(withName: "button") as? SKSpriteNode
        buttonText = childNode(withName: "buttonText") as? SKLabelNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if button!.contains(touchLocation) {
            buttonText?.text = "Waiting"
            battleshipDelegate?.placementComplete(board: gameBoard!.board!)
        }else {
            selectShip(position: touchLocation)
            rotateMode = true
            lastTouchX = Int((touchLocation.x-gameBoard!.position.x)/gameBoard!.cellSize!)
            lastTouchY = Int((gameBoard!.position.y-touchLocation.y)/gameBoard!.cellSize!)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        moveSelectedShip(position: touchLocation)
        let x = Int((touchLocation.x-gameBoard!.position.x)/gameBoard!.cellSize!)
        let y = Int((gameBoard!.position.y-touchLocation.y)/gameBoard!.cellSize!)
        if lastTouchX != x || lastTouchY != y {
            rotateMode = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if rotateMode {
            rotateSelectedShip(position: touchLocation)
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
        let cellX = Int((position.x-gameBoard!.position.x)/gameBoard!.cellSize!)
        let cellY = Int((gameBoard!.position.y-position.y)/gameBoard!.cellSize!)
        selectedShip = gameBoard?.board?.shipAtPosition(cellX, cellY)
        if let selectedShip = selectedShip {
            selectedShip.selected = true
            selectedOffsetX = cellX-selectedShip.x
            selectedOffsetY = cellY-selectedShip.y
        }else {
            selectedOffsetX = nil
            selectedOffsetY = nil
        }
    }
    func rotateSelectedShip(position: CGPoint) {
        if let selectedShip = selectedShip {
            if let selectedOffsetX = selectedOffsetX {
                if let selectedOffsetY = selectedOffsetY {
                    gameBoard?.board?.rotateShip(ship: selectedShip, offsetX: selectedOffsetX, offsetY: selectedOffsetY)
                }
            }
        }
    }

    func moveSelectedShip(position: CGPoint) {
        if let selectedShip = selectedShip {
            if let selectedOffsetX = selectedOffsetX {
                if let selectedOffsetY = selectedOffsetY {
                    let cellX = Int((position.x-gameBoard!.position.x)/gameBoard!.cellSize!)
                    let cellY = Int((gameBoard!.position.y-position.y)/gameBoard!.cellSize!)
                    gameBoard?.board?.moveShip(ship: selectedShip, x: cellX-selectedOffsetX, y: cellY-selectedOffsetY)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
