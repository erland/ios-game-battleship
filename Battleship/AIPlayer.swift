//
//  AIPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

class AIPlayer : Player {
    var opponentBoard : Board?
    var myBoard : Board?
    let playerName: String
    var shoots: Array2D<Bool>?
    var lastHitX: Int?
    var lastHitY: Int?
    init(name: String) {
        playerName = name
    }
    func readyForPlacement(delegate: BattleshipDelegate, board: Board, ships: [Ship]) {
        for ship in ships {
            var placed = false
            repeat {
                let x = Int.random(in: 0..<board.width)
                let y = Int.random(in: 0..<board.height)
                let orientation = Ship.Orientation(rawValue: Int.random(in: 0...1))
                placed = board.validateNewPosition(ship: ship, x: x, y: y, orientation: orientation!)
                if placed {
                    board.addShip(ship: ship, x: x, y: y)
                    if orientation == Ship.Orientation.Vertical {
                        board.rotateShip(ship: ship)
                    }
                }
            }while !placed
        }
        self.myBoard = board
        delegate.placementComplete(board: board)
    }
    
    func placementCompleted(opponentBoard: Board) {
        self.opponentBoard = opponentBoard
        self.shoots = Array2D<Bool>(columns: opponentBoard.width, rows: opponentBoard.height)
    }
    
    struct Position {
        let x: Int
        let y: Int
        init(x: Int, y: Int) {
            self.x = x
            self.y = y;
        }
    }
    private func getNearbyCandidate(nearbyX: Int, nearbyY: Int) -> Position? {
        var position: Position?

        if nearbyX>0 {
            if shoots![nearbyX-1, nearbyY] == nil {
                position = Position(x: nearbyX-1, y: nearbyY)
            }
        }
        if position == nil && nearbyX<shoots!.columns-1 {
            if shoots![nearbyX+1, nearbyY] == nil {
                position = Position(x: nearbyX+1, y: nearbyY)
            }
        }

        if position == nil {
            if lastHitY!>0 {
                if shoots![nearbyX, nearbyY-1] == nil {
                    position = Position(x: nearbyX, y: nearbyY-1)
                }
            }
            if position == nil && nearbyY<shoots!.rows-1 {
                if shoots![nearbyX, nearbyY+1] == nil {
                    position = Position(x: nearbyX, y: nearbyY+1)
                }
            }
            
        }
        if let position = position {
            print("Finding nearby existing hit at \(position.x),\(position.y)")
        }
        return position
    }
    
    func readyForShoot(delegate: BattleshipDelegate) {
        print("AI preparing to shoot")
        if let board = opponentBoard {
            var position: Position?
            
            if lastHitX != nil {
                position = getNearbyCandidate(nearbyX: lastHitX!, nearbyY: lastHitY!)
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
            if position == nil {
                repeat {
                    position = Position(x: Int.random(in: 0..<board.width),
                                        y: Int.random(in: 0..<board.height))
                }while(shoots?[position!.x, position!.y] != nil)
            }
            print("AI shooting at \(position!.x),\(position!.y)")
            delegate.shoot(playerName: playerName, x: position!.x, y: position!.y)
        }
    }
    
    func shootResult(x: Int, y: Int, hit: Bool) {
        shoots?[x,y] = hit
        if hit {
            lastHitX = x
            lastHitY = y
        }
    }

    func shoot(delegate: BattleshipDelegate, x: Int, y: Int) {
        if let board = myBoard {
            let ship = board.shipAtPosition(x: x, y: y)
            let result = ship?.shoot(x: x, y: y)
            if result != nil {
                delegate.shootResult(playerName: playerName, x: x, y: y, hit: result!)
            }else {
                delegate.shootResult(playerName: playerName, x: x, y: y, hit: false)
            }
        }
    }
    
    
}
