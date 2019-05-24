//
//  BoardView.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class BoardView : SKSpriteNode, BoardObserver {
    
    let board: Board
    let cellSize: CGFloat
    let scale: CGFloat
    let hitTexture : SKTexture?
    let missTexture : SKTexture?

    init(board: Board, cellSize: CGFloat, scale: CGFloat) {
        self.cellSize = cellSize
        self.board = board
        self.scale = scale
        
        let texture = BoardView.createBoardTexture(x: board.width, y: board.height, cellSize: cellSize)
        let boardWidth = CGFloat(board.width)*cellSize
        let boardHeight = CGFloat(board.width)*cellSize

        self.hitTexture = BoardView.createHitTexture(cellSize: cellSize, strokeColor: UIColor.green, fillColor: UIColor.green)
        let missColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.5)
        self.missTexture = BoardView.createHitTexture(cellSize: cellSize, strokeColor: missColor, fillColor: missColor)

        super.init(texture: texture, color: UIColor.black, size: CGSize(width: boardWidth, height: boardHeight))

        for y in 0..<board.height {
            for x in 0..<board.width {
                if board.shoots[x,y] != nil {
                    shootAt(x: x, y: y, hit: board.shoots[x,y]!)
                }
            }
        }
        board.attachObserver(observer: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private class func createBoardTexture(x: Int, y: Int, cellSize: CGFloat) -> SKTexture? {
        let boardWidth = CGFloat(x)*cellSize
        let boardHeight = CGFloat(y)*cellSize
        let texture = SKTexture(imageNamed: "water")
        let shape = SKSpriteNode.init(texture: texture, size: CGSize(width: boardWidth, height: boardHeight))
        let border = SKShapeNode.init(rectOf: CGSize(width: boardWidth,
                                                     height: boardHeight))
        border.strokeColor = UIColor.white
        shape.addChild(border)
        for row in 1..<(y) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                        from: CGPoint(x: 0.0, y: CGFloat(row)*cellSize),
                                        to: CGPoint(x: boardWidth, y: CGFloat(row)*cellSize))
            line.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
            shape.addChild(line)
        }
        for column in 1..<(x) {
            let line = BoardView.createLine(anchor: CGPoint(x: -boardWidth/2, y: -boardHeight/2),
                                        from: CGPoint(x: CGFloat(column)*cellSize, y: 0),
                                        to: CGPoint(x: CGFloat(column)*cellSize, y: boardHeight))
            line.strokeColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
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
    
    func hideShips(hide: Bool) {
        enumerateChildNodes(withName: "ship") {
            (node, stop) in
            if hide {
                node.alpha = 0
            }else {
                node.alpha = 1
            }
        }
    }

    func shipAdded(ship: Ship) {
        let shipView = ShipView(ship: ship, cellSize: cellSize)
        shipView.anchorPoint = CGPoint(x: 1.0/(CGFloat(ship.length)*2.0), y: 0.5)
        shipView.name = "ship"
        shipView.zPosition = 10
        addChild(shipView)
    }
    
    func shipRemoved(ship: Ship) {
        if let shipView = viewForShip(ship: ship) {
            shipView.removeFromParent()
        }
    }
    
    func shootAt(x: Int, y: Int, hit: Bool) {
        if hit {
            if let explosionPath = Bundle.main.path(forResource: "Explosion", ofType: "sks"),
                let smokePath = Bundle.main.path(forResource: "Smoke", ofType: "sks"),
                let firePath = Bundle.main.path(forResource: "Fire", ofType: "sks"),
                let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionPath) as? SKEmitterNode,
                let fire = NSKeyedUnarchiver.unarchiveObject(withFile: firePath) as? SKEmitterNode,
                let smoke = NSKeyedUnarchiver.unarchiveObject(withFile: smokePath) as? SKEmitterNode {
                
                explosion.position = CGPoint(x: CGFloat(x)*cellSize+cellSize/2,
                                             y: -CGFloat(y)*cellSize-cellSize/2)
                smoke.position = CGPoint(x: CGFloat(x)*cellSize+cellSize/2,
                                         y: -CGFloat(y)*cellSize-cellSize/2)
                fire.position = CGPoint(x: CGFloat(x)*cellSize+cellSize/2,
                                         y: -CGFloat(y)*cellSize-cellSize/2)
                fire.setScale(0.75*scale)
                fire.zPosition = 20
                explosion.setScale(0.75*scale)
                explosion.zPosition = 20
                smoke.setScale(0.75*scale)
                smoke.zPosition = 20

                addChild(smoke)
                addChild(fire)
                addChild(explosion)
            }
        }else {
            var hitSprite: SKSpriteNode?
            if hit {
                hitSprite = SKSpriteNode(texture: hitTexture)
            }else {
                hitSprite = SKSpriteNode(texture: missTexture)
            }
            hitSprite!.anchorPoint = CGPoint(x: 0, y: 1)
            hitSprite!.position = CGPoint(x: CGFloat(x)*cellSize,
                                         y: -CGFloat(y)*cellSize)
            hitSprite!.zPosition = 20
            addChild(hitSprite!)
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
    

    func viewForShip(ship: Ship) -> ShipView? {
        var result: ShipView?
        enumerateChildNodes(withName: "ship") {
            (node, stop) in
            if node is ShipView {
                let shipView  = node as! ShipView
                if shipView.ship === ship {
                    result = shipView
                }
            }
        }
        return result
    }
}

