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
    var destroyedShips : [Ship] = []

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
        delegate.placementComplete(board: Board(name: board.name, x: board.width, y: board.height))
    }
    
    func placementCompleted(opponentBoard: Board) {
        self.opponentBoard = opponentBoard
        self.shoots = Array2D<Bool>(columns: opponentBoard.width, rows: opponentBoard.height)
    }
    
    struct Position {
        let x: Int
        let y: Int
        init(_ x: Int, _ y: Int) {
            self.x = x
            self.y = y;
        }
    }
    
    private func getNearbyCandidate(nearbyX: Int, nearbyY: Int) -> Position? {
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
    
    func getNextShootPosition() -> Position? {
        var position: Position?
        if let board = opponentBoard {
            repeat {
                position = Position(Int.random(in: 0..<board.width),
                                    Int.random(in: 0..<board.height))
            }while(shoots?[position!.x, position!.y] != nil)
        }
        return position
    }
    func readyForShoot(delegate: BattleshipDelegate) {
        print("AI preparing to shoot")
        let position = getNextShootPosition()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            print("AI shooting at \(position!.x),\(position!.y)")
            delegate.shoot(playerName: self.playerName, x: position!.x, y: position!.y)
        })
    }
    
    func shootResult(delegate: BattleshipDelegate, x: Int, y: Int, hit: Bool, destroyedShip: Ship?) {
        shoots?[x,y] = hit
        if destroyedShip != nil {
            destroyedShips.append(destroyedShip!)
            if destroyedShips.count == myBoard?.ships.count {
                var myShips: [Ship] = []
                for ship in myBoard!.ships {
                    myShips.append(ship)
                }
                delegate.gameResult(ships: myShips, won: true)
            }
        }
    }
    
    func shoot(delegate: BattleshipDelegate, x: Int, y: Int) {
        if let board = myBoard {
            let ship = board.shipAtPosition(x, y)
            let result = ship?.shoot(x, y)
            if result != nil {
                if ship!.isDestroyed() {
                    delegate.shootResult(playerName: playerName, x: x, y: y, hit: result!, destroyedShip: ship)
                }else {
                    delegate.shootResult(playerName: playerName, x: x, y: y, hit: result!, destroyedShip: nil)
                }
            }else {
                delegate.shootResult(playerName: playerName, x: x, y: y, hit: false, destroyedShip: nil)
            }
        }
    }
    func gameResult(delegate: BattleshipDelegate, ships: [Ship], won: Bool) {
        if won {
            var myShips: [Ship] = []
            if let ships = myBoard?.ships {
                for ship in ships {
                    myShips.append(ship)
                }
            }
            delegate.gameResult(ships: myShips, won: !won)
        }
    }
    
}
