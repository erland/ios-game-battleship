//
//  NetworkPlayer.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-04.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//
import Foundation

class NetworkPlayer : Player {
    var opponentBoard : Board?
    var myBoard : Board?
    let playerName: String
    let network : BattleshipNetwork
    init(network: BattleshipNetwork, name: String) {
        playerName = name
        self.network = network
        print("Creating NetworkPlayer for \(name)")
    }
    
    func readyForPlacement(delegate: BattleshipDelegate, board: Board, ships: [Ship]) {
        let networkBoard = NetworkBoard(boardWidth: board.width,
                                        boardHeight: board.height,
                                        ships: ships)
        network.sendReadyForPlacement(
            player: playerName,
            board: networkBoard)
    }
    
    func placementCompleted(opponentBoard: Board) {
        let networkBoard = NetworkBoard(boardWidth: opponentBoard.width,
                                        boardHeight: opponentBoard.height,
                                        ships: Array<Ship>(opponentBoard.ships))
        network.sendPlacementCompleted(
            player: playerName,
            board: networkBoard)

        // TODO: Let other player know that we are ready to play
        // TODO: Possibly pass our board to other player
    }
    
    func readyForShoot(delegate: BattleshipDelegate) {
        network.sendReadyForShoot(player: playerName)
        // TODO: ???
    }
    
    func shoot(delegate: BattleshipDelegate, x: Int, y: Int) {
        let shoot = NetworkShoot(x: x, y: y)

        network.sendShoot(player: playerName, shoot: shoot)
        // TODO: Send our shoot to other player
    }
    
    func shootResult(x: Int, y: Int, hit: Bool, destroyedShip: Ship?) {
        var destroyedNetworkShip: NetworkShip?
        if let destroyedShip = destroyedShip {
            destroyedNetworkShip = NetworkShip(x: destroyedShip.x, y: destroyedShip.y, length: destroyedShip.length, horizontal: (destroyedShip.orientation == Ship.Orientation.Horizontal))
        }
        let shootResult = NetworkShootResult(x: x, y: y, hit: hit, destroyedShip: destroyedNetworkShip)
        network.sendShootResult(player: playerName, shootResult: shootResult)
        // TODO: Pass result on opponent shot to other player
    }
    
    func gameResult(delegate: BattleshipDelegate, ships: [Ship], won: Bool) {
        
        let networkGameResult = NetworkGameResult(ships: ships, won: won)

        network.sendGameResult(player: playerName, gameResult: networkGameResult)
    }

}
