//
//  CommandDelegate.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

protocol CommandDelegate {
    func sendStartGame(player: String)
    func sendShoot(player: String, x: Int, y: Int)
}
