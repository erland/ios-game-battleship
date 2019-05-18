//
//  Player.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol Player {
    func readyForPlacement(delegate: BattleshipDelegate, board: Board, ships: [Ship])
    func placementCompleted(opponentBoard: Board)
    func readyForShoot(delegate: BattleshipDelegate)
    func shoot(delegate: BattleshipDelegate, x: Int, y: Int)
    func shootResult(x: Int, y: Int, hit: Bool, destroyedShip: Ship?)
    func gameResult(delegate: BattleshipDelegate, ships: [Ship], won: Bool)
}
