//
//  ShipView.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class ShipView : SKSpriteNode, ShipObserver {
    let cellSize: CGFloat
    let destroyedTexture: SKTexture?
    let selectedTexture: SKTexture?
    let mainTexture: SKTexture?
    let ship : Ship
    
    init(ship: Ship, cellSize: CGFloat) {
        self.cellSize = cellSize
        self.ship = ship
        self.mainTexture = SKTexture(imageNamed: "ship3D\(ship.length)")
        self.selectedTexture = ShipView.createShipTexture(length: ship.length, cellSize: cellSize, borderColor: UIColor.red, fillColor: UIColor.white, alpha: 0.5)
        self.destroyedTexture = ShipView.createShipTexture(length: ship.length, cellSize: cellSize, borderColor: UIColor.red, fillColor: UIColor.red, alpha: 0.3)
        super.init(texture: mainTexture, color: UIColor.black, size: CGSize(width: CGFloat(ship.length)*cellSize, height: cellSize*2))
        ship.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 0.5)
        shipUpdated(ship: ship)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func createShipTexture(length: Int, cellSize: CGFloat, borderColor: UIColor, fillColor: UIColor, alpha: CGFloat) -> SKTexture? {
        let texture = SKTexture.init(imageNamed: "ship3D\(length)")
        let sprite = SKSpriteNode.init(texture: texture, size: CGSize(width: CGFloat(length)*cellSize, height: cellSize*2))
        sprite.alpha = 0.5
        sprite.position = CGPoint(x: 0, y: cellSize/2)
        let shape = SKShapeNode.init(rect: CGRect(origin: CGPoint(x: -CGFloat(length)*cellSize/2.0, y: -cellSize/2),
                                                  size: CGSize(width: CGFloat(length)*cellSize,
                                                               height: cellSize)), cornerRadius: cellSize/4)
        shape.fillColor = fillColor
        shape.strokeColor = borderColor
        shape.alpha = alpha
        shape.addChild(sprite)
        let view = SKView(frame: CGRect(x: 0, y: 0, width: CGFloat(length)*cellSize, height: cellSize*2))
        return view.texture(from: shape)
    }
    
    func shipUpdated(ship: Ship) {
        var positionX = CGFloat(ship.x)*cellSize+cellSize/2.0
        var positionY = -CGFloat(ship.y)*cellSize-cellSize/2.0
        self.position = CGPoint(x: positionX, y: positionY)
        if ship.orientation == Ship.Orientation.Horizontal {
            self.zRotation = 0
            positionY=positionY+cellSize/2
        }else {
            self.zRotation = CGFloat.pi/2
            positionX=positionX-cellSize/2
        }
        self.position = CGPoint(x: positionX, y: positionY)
        if ship.selected {
            texture = selectedTexture
        }else {
            if ship.isDestroyed() {
                texture = destroyedTexture
            }else {
                texture = mainTexture
            }
        }
    }
    

}

