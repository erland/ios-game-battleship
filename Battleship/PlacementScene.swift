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
    var gameBoard: BoardView
    var button: SKSpriteNode
    var buttonText: SKLabelNode
    var battleshipDelegate: BattleshipDelegate
    
    let gridSize = 10
    
    init(delegate: BattleshipDelegate, board: Board, ships: [Ship], size: CGSize) {
        let margin = size.width/20
        let cellSize = (size.width-margin*2)/CGFloat(gridSize)
        battleshipDelegate = delegate
        gameBoard = BoardView.init(board: board, cellSize: cellSize)
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1)
        gameBoard.position = CGPoint(x: margin,y: size.height-margin)
        for (i, ship) in ships.enumerated() {
            board.addShip(ship: ship, x: 0, y: i*2)
        }

        button = SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 150, height: 44))
        buttonText = SKLabelNode(fontNamed:"Chalkduster")
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        addChild(gameBoard)
        
        button.position = CGPoint(x:self.frame.midX, y:size.height-gameBoard.size.height-120);
        buttonText.text = "Finished"
        buttonText.color = UIColor.black
        buttonText.fontSize = 18
        button.addChild(buttonText)

        self.addChild(button)
        let instructionText = SKLabelNode(fontNamed:"Chalkduster")
        instructionText.text = "\(gameBoard.board.name) place your ships"
        instructionText.color = UIColor.white
        instructionText.fontSize = 18
        instructionText.position = CGPoint(x:self.frame.midX, y:size.height-gameBoard.size.height-70);
        addChild(instructionText)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        if button.contains(touchLocation) {
            buttonText.text = "Waiting"
            battleshipDelegate.placementComplete(board: gameBoard.board)
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
        selectedShip = gameBoard.board.shipAtPosition(x: cellX,
                                                y: cellY)
        if let selectedShip = selectedShip {
            selectedShip.selected = true
            selectedOffsetX = cellX-selectedShip.x
            selectedOffsetY = cellY-selectedShip.y
        }else {
            selectedOffsetX = nil
            selectedOffsetY = nil
        }
    }
    func rotateSelectedShip() {
        if let selectedShip = selectedShip {
            gameBoard.board.rotateShip(ship: selectedShip)
        }
    }

    func moveSelectedShip(position: CGPoint) {
        if let selectedShip = selectedShip {
            if let selectedOffsetX = selectedOffsetX {
                if let selectedOffsetY = selectedOffsetY {
                    let cellX = Int((position.x-gameBoard.position.x)/gameBoard.cellSize)
                    let cellY = Int((gameBoard.position.y-position.y)/gameBoard.cellSize)
                    gameBoard.board.moveShip(ship: selectedShip, x: cellX-selectedOffsetX, y: cellY-selectedOffsetY)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
