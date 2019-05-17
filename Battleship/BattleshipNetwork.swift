//
//  NetworkProtocol.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-15.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import Foundation

struct NetworkShoot : Codable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
struct NetworkShootResult : Codable {
    let x: Int
    let y: Int
    let hit: Bool
    var destroyedShip: NetworkShip?
    
    init(x: Int, y: Int, hit: Bool, destroyedShip: NetworkShip?) {
        self.x = x
        self.y = y
        self.hit = hit
        self.destroyedShip = destroyedShip
    }
}

struct NetworkShip : Codable {
    let length: Int
    let horizontal: Bool
    let x: Int
    let y: Int
    
    init(x: Int, y: Int, length: Int, horizontal: Bool) {
        self.x = x
        self.y = y
        self.length = length
        self.horizontal = horizontal
    }
    func asShipObj() -> Ship {
        let shipObj = Ship(length: length)
        if horizontal {
            shipObj.orientation = Ship.Orientation.Horizontal
            shipObj.x = x
            shipObj.y = y
        }else {
            shipObj.orientation = Ship.Orientation.Vertical
            shipObj.x = x
            shipObj.y = y
        }
        return shipObj
    }
    
}
struct NetworkBoard : Codable {
    var ships: Array<NetworkShip?>
    let boardWidth: Int
    let boardHeight: Int
    
    init(noOfShips: Int, boardWidth: Int, boardHeight: Int) {
        ships = Array<NetworkShip?>(repeating: nil, count: noOfShips)
        self.boardWidth = boardWidth
        self.boardHeight = boardHeight
    }
    init(boardWidth: Int, boardHeight: Int, ships: Array<Ship>) {
        self.init(noOfShips: ships.count,
                  boardWidth: boardWidth,
                  boardHeight: boardHeight)
        
        for (i,ship) in ships.enumerated() {
            if ship.orientation == Ship.Orientation.Horizontal {
                self.ships[i] = NetworkShip(x: ship.x, y: ship.y, length: ship.length, horizontal: true)
            }else {
                self.ships[i] = NetworkShip(x: ship.x, y: ship.y, length: ship.length, horizontal: false)
            }
        }
    }
    func getShipObjects() -> Array<Ship> {
        var result = Array<Ship>()
        for (_,ship) in self.ships.enumerated() {
            if let ship = ship {
                result.append(ship.asShipObj())
            }
        }
        return result
    }
}

class BattleshipNetwork : MessageProcessor, ConnectionManager {
    let battleshipDelegate : BattleshipDelegate
    var localNetworking : LocalNetworking?
    var players: Set<String> = Set()
    var readyToPlay: Bool = false

    init(battleshipDelegate: BattleshipDelegate) {
        self.battleshipDelegate = battleshipDelegate
        self.localNetworking = LocalNetworking(serviceType: "Battleship", messageProcessor: self, connectionManager: self)
    }
    func addConnection(peer: String) {
        sendReadyToPlay(player: peer)
    }
    
    func removeConnection(peer: String) {
        players.remove(peer)
        battleshipDelegate.removeOpponent(player: peer)
    }
    
    func processMessage(peer: String, message: Message) {
        if message.message == "readyForPlacement" {
            let board = try! JSONDecoder().decode(NetworkBoard.self, from: message.data)
            print("Received readyForPlacement on \(board.boardWidth),\(board.boardHeight) board")
            self.battleshipDelegate.readyForPlacement(player: peer, x: board.boardWidth, y: board.boardHeight, ships: board.getShipObjects())
        }else if message.message == "placementCompleted" {
            let networkBoard = try! JSONDecoder().decode(NetworkBoard.self, from: message.data)
            let board = Board(name: peer, x: networkBoard.boardWidth, y: networkBoard.boardHeight)
            for (_,ship) in networkBoard.getShipObjects().enumerated() {
                board.addShip(ship: ship, x: ship.x, y: ship.y)
            }
            print("Received placementCompleted on \(board.width),\(board.height) board")
            self.battleshipDelegate.placementComplete(board: board)
        }else if message.message == "readyForShoot" {
            print("Received readyForShoot, doing nothing")
        }else if message.message == "readyToPlay" {
            print("Received readyToPlay")
            players.insert(peer)
            self.battleshipDelegate.addOpponent(player: peer)
        }else if message.message == "finishedPlaying" {
            print("Received finishedPlaying")
            removeConnection(peer: peer)
        }else if message.message == "shoot" {
            let networkShoot = try! JSONDecoder().decode(NetworkShoot.self, from: message.data)
            print("Received shoot at \(networkShoot.x),\(networkShoot.y)")
            self.battleshipDelegate.shoot(playerName: peer, x: networkShoot.x, y: networkShoot.y)
        }else if message.message == "shootResult" {
            let networkShootResult = try! JSONDecoder().decode(NetworkShootResult.self, from: message.data)
            print("Received shootResult at \(networkShootResult.x),\(networkShootResult.y) = \(networkShootResult.hit)")
            if networkShootResult.destroyedShip != nil {
                self.battleshipDelegate.shootResult(playerName: peer, x: networkShootResult.x, y: networkShootResult.y, hit: networkShootResult.hit, destroyedShip: networkShootResult.destroyedShip?.asShipObj())
            }else {
                self.battleshipDelegate.shootResult(playerName: peer, x: networkShootResult.x, y: networkShootResult.y, hit: networkShootResult.hit, destroyedShip: nil)
            }
        }else {
            print("Unknown message: \(message.message)")
        }
    }
    func sendReadyForPlacement(player: String, board: NetworkBoard) {
        let jsonData = try! JSONEncoder().encode(board)
        localNetworking?.sendMessage(player: player, message: Message(message: "readyForPlacement", data: jsonData))
        
    }
    func sendPlacementCompleted(player: String, board: NetworkBoard) {
        let jsonData = try! JSONEncoder().encode(board)
        localNetworking?.sendMessage(player: player, message: Message(message: "placementCompleted", data: jsonData))
        
    }
    func sendShoot(player: String, shoot: NetworkShoot) {
        let jsonData = try! JSONEncoder().encode(shoot)
        localNetworking?.sendMessage(player: player, message: Message(message: "shoot", data: jsonData))
        
    }
    func sendShootResult(player: String, shootResult: NetworkShootResult) {
        let jsonData = try! JSONEncoder().encode(shootResult)
        localNetworking?.sendMessage(player: player, message: Message(message: "shootResult", data: jsonData))
        
    }
    func sendReadyForShoot(player: String) {
        localNetworking?.sendMessage(player: player, message: Message(message: "readyForShoot", data: "{}".data(using: .utf8)!))
    }
    
    func sendReadyToPlay(player: String?) {
        readyToPlay = true
        let message = Message(message: "readyToPlay", data: "{}".data(using: .utf8)!)
        localNetworking?.sendMessage(message: message)
    }
    
    func sendFinishedPlaying() {
        readyToPlay = false
        let message = Message(message: "finishedPlaying", data: "{}".data(using: .utf8)!)
        localNetworking?.sendMessage(message: message)
    }
    

}
