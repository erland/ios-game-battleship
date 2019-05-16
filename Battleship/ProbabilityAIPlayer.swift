//
//  ProbabilityAIPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-16.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

class ProbabilityAIPlayer : RandomAIPlayer {
    var probabilityMap: Array2D<Int>?
    var ships: [Ship] = []
    
    override init(name: String) {
        super.init(name: name)
    }
    
    override func placementCompleted(opponentBoard: Board) {
        super.placementCompleted(opponentBoard: opponentBoard)
        for ship in opponentBoard.ships {
            ships.append(ship)
        }
    }
    
    func addProbabilityForVerticalShip(map: Array2D<Int>, x: Int, y: Int, length: Int) {
        var probabilityIncrease = 1
        for y in y..<(y+length) {
            if shoots![x,y] != nil {
                if shoots![x,y]! {
                    if let board = opponentBoard {
                        if let ship = board.shipAtPosition(x: x, y: y) {
                            if !ship.isDestroyed() {
                                probabilityIncrease = probabilityIncrease * 4
                            }
                        }
                    }
                }
            }
        }
        for y in y..<(y+length) {
            if shoots![x,y] == nil {
                if map[x,y] == nil {
                    map[x,y] = 0
                }
                map[x,y] = map[x,y]! + probabilityIncrease
            }
        }
    }
    func addProbabilityForHorizontalShip(map: Array2D<Int>, x: Int, y: Int, length: Int) {
        var probabilityIncrease = 1
        for x in x..<(x+length) {
            if shoots![x,y] != nil {
                if shoots![x,y]! {
                    if let board = opponentBoard {
                        if let ship = board.shipAtPosition(x: x, y: y) {
                            if !ship.isDestroyed() {
                                probabilityIncrease = probabilityIncrease * 4
                            }
                        }
                    }
                }
            }
        }
        for x in x..<(x+length) {
            if shoots![x,y] == nil {
                if map[x,y] == nil {
                    map[x,y] = 0
                }
                map[x,y] = map[x,y]! + probabilityIncrease
            }
        }
    }

    func getMaxProbabilityPosition(map: Array2D<Int>) -> Position? {
        var highestProbability = 0
        for x in 0..<map.columns {
            for y in 0..<map.rows {
                if map[x,y] != nil {
                    if map[x,y]!>highestProbability {
                        highestProbability = map[x,y]!
                    }
                }
            }
        }
        var possiblePositions: [Position] = []
        for x in 0..<map.columns {
            for y in 0..<map.rows {
                if map[x,y] != nil {
                    if map[x,y]!==highestProbability {
                        possiblePositions.append(Position(x: x,y: y))
                    }
                }
            }
        }
        if possiblePositions.count>0 {
            let randomPos = Int.random(in: 0..<possiblePositions.count)
            return possiblePositions[randomPos]
        }
        return nil
    }
    func buildProbabilityMap(map: Array2D<Int>, shipLength: Int) {
        if let board = opponentBoard {
            
            for y in 0..<board.height {
                for x in 0..<board.width {
                    let shipRight = x+shipLength-1
                    let shipLeft = x
                    if shipRight>board.width-1 {
                        // Not enough space on right side for ship
                        break
                    }
                    
                    var shipFits = true
                    for shipX in shipLeft...shipRight {
                        if shoots![shipX,y] == false {
                            shipFits = false
                            break
                        }
                    }
                    if shipFits {
                        addProbabilityForHorizontalShip(map: map, x: shipLeft, y: y, length: shipLength)
                    }
                }
            }

            for x in 0..<board.width {
                for y in 0..<board.height {
                    let shipBottom = y+shipLength-1
                    let shipTop = y
                    if shipBottom>board.height-1 {
                        // Not enough space on right side for ship
                        break
                    }
                    
                    var shipFits = true
                    for shipY in shipTop...shipBottom {
                        if shoots![x,shipY] == false {
                            shipFits = false
                            break
                        }
                    }
                    if shipFits {
                        addProbabilityForVerticalShip(map: map, x: x, y:shipTop, length: shipLength)
                    }
                }
            }
        }
    }
    
    override func getNextShootPosition() -> Position? {
        var position: Position?
        if let board = opponentBoard {
            let map = Array2D<Int>(columns: board.width, rows: board.height)
            for ship in ships {
                buildProbabilityMap(map: map, shipLength: ship.length)
            }
            debugMap(map: map)
            position = getMaxProbabilityPosition(map: map)
            if position != nil {
                print("Best shot at \(position!.x),\(position!.y)")
            }
        }
        if position == nil {
            position = super.getNextShootPosition()
        }
        return position
    }
    func debugMap(map: Array2D<Int>) {
        print("Board contents")
        for y in 0..<map.rows {
            for x in 0..<map.columns {
                if map[x,y] != nil {
                    if map[x,y]!<10 {
                        print("0\(map[x,y]!),", terminator: "")
                    }else {
                        print("\(map[x,y]!),", terminator: "")
                    }
                }else {
                    print("00,", terminator: "")
                }
            }
            print()
        }
    }
    
    override func shootResult(x: Int, y: Int, hit: Bool) {
        super.shootResult(x: x, y: y, hit: hit)
        if hit {
            if let board = opponentBoard {
                let ship = board.shipAtPosition(x: x, y: y)
                if let ship = ship {
                    if ship.shoot(x: x, y: y)  {
                        if ship.isDestroyed() {
                            var foundIndex = 0
                            for (i,s) in ships.enumerated() {
                                if s.length == ship.length {
                                    foundIndex = i
                                    break
                                }
                            }
                            ships.remove(at: foundIndex)
                        }
                    }
                }

            }
        }
    }

}
