//
//  BoardView.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BoardView : SKSpriteNode {
    let board: Board
    let cellSize: CGFloat
    
    init(board: Board, cellSize: CGFloat) {
        self.cellSize = cellSize
        self.board = board
        
        let texture = BoardView.createBoardTexture(x: board.width, y: board.height, cellSize: cellSize)
        let boardWidth = CGFloat(board.width)*cellSize
        let boardHeight = CGFloat(board.width)*cellSize
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
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                        from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                        to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = UIColor.gray
            shape.addChild(line)
        }
        for column in 1..<(x) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
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

}
