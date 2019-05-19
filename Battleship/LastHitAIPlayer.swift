//
//  AIPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

class LastHitAIPlayer : RandomAIPlayer {
    var lastHit: Position?

    override init(name: String) {
        super.init(name: name)
    }
    
    func getNearbyCandidate(nearbyX: Int, nearbyY: Int) -> Position? {
        var position: Position?

        if nearbyX>0 {
            if shoots![nearbyX-1, nearbyY] == nil {
                position = Position(nearbyX-1, nearbyY)
            }
        }
        if position == nil && nearbyX<shoots!.columns-1 {
            if shoots![nearbyX+1, nearbyY] == nil {
                position = Position(nearbyX+1, nearbyY)
            }
        }

        if position == nil {
            if nearbyY>0 {
                if shoots![nearbyX, nearbyY-1] == nil {
                    position = Position(nearbyX, nearbyY-1)
                }
            }
            if position == nil && nearbyY<shoots!.rows-1 {
                if shoots![nearbyX, nearbyY+1] == nil {
                    position = Position(nearbyX, nearbyY+1)
                }
            }
            
        }
        if let position = position {
            print("Finding nearby existing hit at \(position.x),\(position.y)")
        }
        return position
    }
    
    override func getNextShootPosition() -> Position? {
        var position: Position?
        if let board = opponentBoard {
            
            if lastHit != nil {
                position = getNearbyCandidate(nearbyX: lastHit!.x, nearbyY: lastHit!.y)
            }
            if position == nil {
                for cellX in 0..<board.width {
                    for cellY in 0..<board.height {
                        if shoots![cellX, cellY] == true {
                            position = getNearbyCandidate(nearbyX: cellX, nearbyY: cellY)
                        }
                        if position == nil {
                            break
                        }
                    }
                    if position == nil {
                        break
                    }
                }
            }
        }
        if position == nil {
            position = super.getNextShootPosition()
        }
        return position
    }
    
    override func shootResult(delegate: BattleshipDelegate, x: Int, y: Int, hit: Bool, destroyedShip: Ship?) {
        if hit {
            lastHit = Position(x, y)
        }
        super.shootResult(delegate: delegate, x: x, y: y, hit: hit, destroyedShip: destroyedShip)
    }
}
