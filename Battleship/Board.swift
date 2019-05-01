//
//  Board.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-29.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class Board : SKSpriteNode {
    let width: Int
    let height: Int
    let cellSize: CGFloat
    let board: Array2D<Ship>
    
    init(x: Int, y: Int, cellSize: CGFloat) {
        self.width = x
        self.height = y
        self.cellSize = cellSize
        self.board = Array2D<Ship>(columns: width, rows: height)
        
        let texture = Board.createBoardTexture(x: x, y: y, cellSize: cellSize)
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        super.init(texture: texture, color: UIColor.black, size: CGSize(width: boardWidth, height: boardHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func createBoardTexture(x: Int, y: Int, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        let shape = SKShapeNode.init(rectOf: CGSize(width: boardWidth,
                                                    height: boardHeight))
        shape.fillColor = UIColor.blue
        shape.strokeColor = UIColor.white
        for row in 1..<(y) {
            let line = Board.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                        from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                        to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = UIColor.gray
            shape.addChild(line)
        }
        for column in 1..<(x) {
            let line = Board.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                        from: CGPoint(x: CGFloat(column)*cellSize, y: 0),
                                        to: CGPoint(x: CGFloat(column)*cellSize, y: boardHeight))
            line.strokeColor = UIColor.gray
            shape.addChild(line)
        }
        let view = SKView(frame: CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight))
        return view.texture(from: shape)
    }
    
    private class func createLine(anchor: CGPoint, from:CGPoint, to: CGPoint) -> SKShapeNode {
        let lineShape = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: anchor.x+from.x, y: anchor.y+from.y))
        path.addLine(to: CGPoint(x: anchor.x+to.x, y: anchor.y+to.y))
        lineShape.path = path
        return lineShape
    }

    func shipAtPosition(x: Int, y: Int) -> Ship? {
        if x>=0 && x<width && y>=0 && y<height {
            return board[x, y]
        }else {
            return nil
        }
    }
    
    func addShip(ship: Ship, x: Int, y: Int) {
        if x<0 || x >= width {
            return
        }
        if y<0 || y>=height {
            return
        }
        ship.anchorPoint = CGPoint(x: 1.0/(CGFloat(ship.length)*2.0), y: 0.5)
        ship.name = "ship"
        addChild(ship)
        moveShip(ship: ship, x: x, y: y)
    }
    
    func moveShip(ship: Ship, x: Int, y: Int) {
        if x<0 || x >= width {
            return
        }
        if y<0 || y>=height {
            return
        }
        removeShipFromBoard(ship: ship)
        let newX = CGFloat(x)*cellSize+cellSize/2.0
        let newY = -CGFloat(y)*cellSize-cellSize/2.0
        if validateNewPosition(ship: ship, x: Int(newX/cellSize), y: Int(-newY/cellSize), rotation: ship.zRotation) {
            ship.position = CGPoint(x: newX, y: newY)
        }
        addShipToBoard(ship: ship)
        //debugBoard()
    }
    
    func hideShips(hide: Bool) {
        enumerateChildNodes(withName: "ship") {
            (node, stop) in
            if hide {
                node.alpha = 0.2
            }else {
                node.alpha = 1
            }
        }
    }
    
    func validateNewPosition(ship: Ship, x: Int, y: Int, rotation: CGFloat) -> Bool {
        if rotation.truncatingRemainder(dividingBy: CGFloat.pi) < (CGFloat.pi/8) {
            for offset in 0..<ship.length {
                if x+offset>=width || board[x+offset, y] != nil {
                    return false
                }
            }
        }else {
            for offset in 0..<ship.length {
                if y-offset<0 || board[x, y-offset] != nil {
                    return false
                }
            }
        }
        return true
    }
    
    func removeShip(ship: Ship) {
        removeShipFromBoard(ship: ship)
        ship.removeFromParent()
    }
    
    private func removeShipFromBoard(ship: Ship) {
        if ship.zRotation.truncatingRemainder(dividingBy: CGFloat.pi) < (CGFloat.pi/8) {
            for offset in 0..<ship.length {
                if ship.x+offset<width && board[ship.x+offset, ship.y] == ship {
                    board[ship.x+offset, ship.y] = nil
                }
            }
        }else {
            for offset in 0..<ship.length {
                if ship.y-offset>=0 && board[ship.x, ship.y-offset] == ship {
                    board[ship.x, ship.y-offset] = nil
                }
            }
        }
    }
    
    private func addShipToBoard(ship: Ship) {
        if ship.zRotation.truncatingRemainder(dividingBy: CGFloat.pi) < (CGFloat.pi/8) {
            for offset in 0..<ship.length {
                board[ship.x+offset,ship.y] = ship
            }
        }else {
            for offset in 0..<ship.length {
                board[ship.x,ship.y-offset] = ship
            }
        }
    }
    
    func rotateShip(ship: Ship) {
        removeShipFromBoard(ship: ship)
        if validateNewPosition(ship: ship, x: ship.x, y: ship.y, rotation: ship.zRotation+CGFloat.pi/2) {
            ship.zRotation += (CGFloat.pi/2)
            if ship.zRotation > (CGFloat.pi*2/3) {
                ship.zRotation = 0
            }
        }
        addShipToBoard(ship: ship)
            
        //debugBoard()
    }
    
    func debugBoard() {
        print("Board contents")
        for y in 0..<height {
            for x in 0..<width {
                if board[x,y] != nil {
                    print("X", terminator: "")
                }else {
                    print("O", terminator: "")
                }
            }
            print()
        }
    }
}
