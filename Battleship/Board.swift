//
//  Board.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-29.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol BoardObserver {
    func shipAdded(ship: Ship)
    func shipRemoved(ship: Ship)
}
class Board {
    let name: String
    let width: Int
    let height: Int
    let board: Array2D<Ship>
    var ships: Set<Ship> = Set()
    var observers: [BoardObserver] = []
    
    init(name: String, x: Int, y: Int) {
        self.name = name
        self.width = x
        self.height = y
        self.board = Array2D<Ship>(columns: width, rows: height)
    }
    func attachObserver(observer: BoardObserver) {
        for ship in ships {
            observer.shipAdded(ship: ship)
        }
        observers.append(observer)
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
        ships.insert(ship)
        for observer in observers {
            observer.shipAdded(ship: ship)
        }
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
        if validateNewPosition(ship: ship, x: x, y: y, orientation: ship.orientation) {
            ship.x = x;
            ship.y = y;
        }
        addShipToBoard(ship: ship)
        debugBoard()
    }
        
    func validateNewPosition(ship: Ship, x: Int, y: Int, orientation: Ship.Orientation) -> Bool {
        if orientation == Ship.Orientation.Horizontal {
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
        ships.remove(ship)
        removeShipFromBoard(ship: ship)
        for observer in observers {
            observer.shipAdded(ship: ship)
        }
    }
    
    private func removeShipFromBoard(ship: Ship) {
        if ship.orientation == Ship.Orientation.Horizontal {
            for offset in 0..<ship.length {
                if ship.x+offset<width && board[ship.x+offset, ship.y] === ship {
                    board[ship.x+offset, ship.y] = nil
                }
            }
        }else {
            for offset in 0..<ship.length {
                if ship.y-offset>=0 && board[ship.x, ship.y-offset] === ship {
                    board[ship.x, ship.y-offset] = nil
                }
            }
        }
    }
    
    private func addShipToBoard(ship: Ship) {
        if ship.orientation == Ship.Orientation.Horizontal {
            for offset in 0..<ship.length {
                board[ship.x+offset,ship.y] = ship
            }
        }else {
            for offset in 0..<ship.length {
                board[ship.x,ship.y-offset] = ship
            }
        }
    }
    
    func isAllShipsDestroyed() -> Bool {
        for ship in ships {
            if !ship.isDestroyed() {
                return false
            }
        }
        return true
    }
    
    func rotateShip(ship: Ship) {
        removeShipFromBoard(ship: ship)
        var newOrientation = Ship.Orientation.Horizontal
        if ship.orientation == Ship.Orientation.Horizontal {
            newOrientation = Ship.Orientation.Vertical
        }
        if validateNewPosition(ship: ship, x: ship.x, y: ship.y, orientation: newOrientation) {
            ship.orientation = newOrientation
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
