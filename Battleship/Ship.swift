//
//  Ship.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-30.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

class Ship : SKSpriteNode {
    let length: Int
    let cellSize: CGFloat
    let selectedTexture: SKTexture?
    let mainTexture: SKTexture?
    
    init(length: Int, cellSize: CGFloat) {
        self.length = length
        self.cellSize = cellSize
        self.mainTexture = Ship.createShipTexture(length: length, cellSize: cellSize, borderColor: UIColor.yellow, fillColor: UIColor.lightGray)
        self.selectedTexture = Ship.createShipTexture(length: length, cellSize: cellSize, borderColor: UIColor.red, fillColor: UIColor.white)
        super.init(texture: mainTexture, color: UIColor.black, size: CGSize(width: CGFloat(length)*cellSize, height: cellSize))
        
        anchorPoint = CGPoint(x: 0, y: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class func createShipTexture(length: Int, cellSize: CGFloat, borderColor: UIColor, fillColor: UIColor) -> SKTexture? {
        let shape = SKShapeNode.init(rectOf: CGSize(width: CGFloat(length)*cellSize,
                                                    height: cellSize), cornerRadius: cellSize/4)
        shape.fillColor = fillColor
        shape.strokeColor = borderColor
        
        let view = SKView(frame: CGRect(x: 0, y: 0, width: CGFloat(length)*cellSize, height: cellSize))
        return view.texture(from: shape)
    }
    
    var selected: Bool {
        set(newState) {
            if newState {
                texture = selectedTexture
            }else {
                texture = mainTexture
            }
        }
        get {
            return texture == mainTexture
        }
    }
    var x: Int {
        get {
            return Int(position.x/cellSize)
        }
    }
    var y: Int {
        get {
            return Int(-position.y/cellSize)
        }
    }
}
