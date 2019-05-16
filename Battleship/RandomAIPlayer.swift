//
//  BaseAIPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

class RandomAIPlayer : Player {
    var opponentBoard : Board?
    var myBoard : Board?
    let playerName: String
    var shoots: Array2D<Bool>?

    init(name: String) {
        playerName = name
    }
    func readyForPlacement(delegate: BattleshipDelegate, board: Board, ships: [Ship]) {
        let copyOfShips = ships.map{$0.copy() as! Ship}
        delegate.readyForPlacement(player: playerName, x: board.width, y: board.height, ships: copyOfShips)
        for ship in ships {
            var placed = false
            repeat {
                let x = Int.random(in: 0..<board.width)
                let y = Int.random(in: 0..<board.height)
                let orientation = Ship.Orientation(rawValue: Int.random(in: 0...1))
                placed = board.validateNewPosition(ship: ship, x: x, y: y, orientation: orientation!)
                if placed {
                    ship.orientation = orientation!
                    board.addShip(ship: ship, x: x, y: y)
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
            if nearbyY>0 {
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
    
    func getNextShootPosition() -> Position? {
        var position: Position?
        if let board = opponentBoard {
            repeat {
                position = Position(x: Int.random(in: 0..<board.width),
                                    y: Int.random(in: 0..<board.height))
            }while(shoots?[position!.x, position!.y] != nil)
        }
        return position
    }
    func readyForShoot(delegate: BattleshipDelegate) {
        print("AI preparing to shoot")
        let position = getNextShootPosition()
        print("AI shooting at \(position!.x),\(position!.y)")
        delegate.shoot(playerName: playerName, x: position!.x, y: position!.y)
    }
    
    func shootResult(x: Int, y: Int, hit: Bool) {
        shoots?[x,y] = hit
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
