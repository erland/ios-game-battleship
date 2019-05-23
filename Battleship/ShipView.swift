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
        self.mainTexture = SKTexture(imageNamed: "ship\(ship.length)")
        self.selectedTexture = ShipView.createShipTexture(length: ship.length, cellSize: cellSize, borderColor: UIColor.red, fillColor: UIColor.white)
        self.destroyedTexture = ShipView.createShipTexture(length: ship.length, cellSize: cellSize, borderColor: UIColor.red, fillColor: UIColor.red)
        super.init(texture: mainTexture, color: UIColor.black, size: CGSize(width: CGFloat(ship.length)*cellSize, height: cellSize))
        ship.attachObserver(observer: self)
        anchorPoint = CGPoint(x: 0, y: 1)
        shipUpdated(ship: ship)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func createShipTexture(length: Int, cellSize: CGFloat, borderColor: UIColor, fillColor: UIColor) -> SKTexture? {
        let texture = SKTexture.init(imageNamed: "ship\(length)")
        let sprite = SKSpriteNode.init(texture: texture, size: CGSize(width: CGFloat(length)*cellSize, height: cellSize))
        sprite.alpha = 0.5
        let shape = SKShapeNode.init(rectOf: CGSize(width: CGFloat(length)*cellSize,
                                                    height: cellSize), cornerRadius: cellSize/4)
        shape.fillColor = fillColor
        shape.strokeColor = borderColor
        shape.addChild(sprite)
        let view = SKView(frame: CGRect(x: 0, y: 0, width: CGFloat(length)*cellSize, height: cellSize))
        return view.texture(from: shape)
    }
    
    func shipUpdated(ship: Ship) {
        let positionX = CGFloat(ship.x)*cellSize+cellSize/2.0
        let positionY = -CGFloat(ship.y)*cellSize-cellSize/2.0
        self.position = CGPoint(x: positionX, y: positionY)
        if ship.orientation == Ship.Orientation.Horizontal {
            self.zRotation = 0
        }else {
            self.zRotation = CGFloat.pi/2
        }
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

