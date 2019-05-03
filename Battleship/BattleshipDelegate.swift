//
//  BattleshipDelegate.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-29.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol BattleshipDelegate {
    func selectedOpponent(player: String)
    func placementComplete(board: Board)
    func gameOver(board: Board, won: Bool)
    func finishedGame()
    func shoot(playerName: String, x: Int, y: Int)
    func shootResult(playerName: String, x: Int, y: Int, hit: Bool)
}
