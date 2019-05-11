//
//  GameViewController.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-28.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class GameViewController: UIViewController, BattleshipDelegate {
    
    var opponentBoard : Board?
    var myBoard : Board?
    var opponentPlayer : Player?
    var network : LocalNetworking?
    var matchMakingScene : MatchMakingScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        network = LocalNetworking(battleshipDelegate: self)
        startMatchMaking()
    }

    func finishedGame() {
        startMatchMaking()
    }
    
    func startMatchMaking() {
        opponentPlayer = nil
        opponentBoard = nil
        myBoard = nil
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        // Create and configure the scene.
        let scene = MatchMakingScene(delegate: self, size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        matchMakingScene = scene
        // Present the scene.
        skView.presentScene(scene)
        //opponentPlayer = AIPlayer(name: "AI")
        if let network = network {
            for player in network.peers {
                matchMakingScene?.addOpponent(name: player)
            }
        }
        network?.sendReadyToPlay(player: nil)
    }
    
    func addOpponent(player: String) {
        matchMakingScene?.addOpponent(name: player)
    }
    func removeOpponent(player: String) {
        matchMakingScene?.removeOpponent(name: player)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func placementComplete(board: Board) {
        let skView = view as! SKView
        print("Placement completed for \(board.name)")
        if opponentPlayer == nil {
            print("opponentPlayer not set yet")
        }else {
            print("opponentPlayer is set")
        }
        if board.name != "Player" {
            print("Storing opponent board")
            opponentBoard = board
        }else {
            print("Storing player board")
            myBoard = board
            opponentPlayer?.placementCompleted(opponentBoard: myBoard!)
        }
        
        if opponentBoard != nil && myBoard != nil {
            // Create and configure the scene.
            let scene = GameScene(delegate: self, myBoard: myBoard!, opponentBoard: opponentBoard!,size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Present the scene.
            skView.presentScene(scene)
        }
    }
    func gameOver(board: Board, won: Bool) {
        let skView = view as! SKView
        // Create and configure the scene.
        let scene = GameOverScene(delegate: self, size: skView.bounds.size, won: won)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        network?.sendFinishedPlaying()
    }

    private func showPlacementScene(board: Board, view: SKView) {
        // Create and configure the scene.
        let scene = PlacementScene(delegate: self, board: board, size: view.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        view.presentScene(scene)

    }
    
    private func createShips() -> [Ship] {
        let carrier = Ship.init(length: 5)
        let battleship = Ship.init(length: 4)
        let crusier = Ship.init(length: 3)
        let submarine = Ship.init(length: 3)
        let destroyer = Ship.init(length: 2)
        return [carrier, battleship, crusier, submarine, destroyer]
    }
    
    func selectedOpponent(player: String) {
        matchMakingScene = nil
        opponentPlayer = NetworkPlayer(network: network!, name: player)
        print("Telling opponent it can start place ships")
        let opponentShips = createShips()
        let opponentBoard = Board(name: player, x: 10, y: 10)
        opponentPlayer?.readyForPlacement(delegate: self, board: opponentBoard, ships: opponentShips)

    }
    
    func readyForPlacement(player: String, x: Int, y: Int) {
        matchMakingScene = nil
        if opponentPlayer == nil {
            opponentPlayer = NetworkPlayer(network: network!, name: player)
            let opponentShips = createShips()
            let opponentBoard = Board(name: player, x: x, y: y)
            opponentPlayer?.readyForPlacement(delegate: self, board: opponentBoard, ships: opponentShips)
        }

        print("Launch view to start place ships")
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        let board = Board(name: "Player", x: x, y: y)
        showPlacementScene(board: board, view: skView)
    }
    
    func shoot(playerName: String, x: Int, y: Int) {
        print("Shot from \(playerName)")
        if playerName == myBoard?.name {
            print("Forwarding shot to AI at \(x),\(y)")
            opponentPlayer?.shoot(delegate: self, x: x, y: y)
        }else if playerName == opponentBoard?.name{
            let skView = view as! SKView
            if skView.scene is GameScene {
                let gameScene = skView.scene as! GameScene
                print("Forwarding AI shoot at \(x),\(y)")
                gameScene.shoot(x: x, y: y)
            }
        }else {
           print("Hoppsan, nu blev det fel")
        }
    }

    func shootResult(playerName: String, x: Int, y: Int, hit: Bool) {
        print("Shoot result from \(playerName)")
        if playerName == opponentBoard?.name {
            let skView = view as! SKView
            if skView.scene is GameScene {
                let gameScene = skView.scene as! GameScene
                print("Forwarding AI result at \(x),\(y)")
                gameScene.shootResult(x: x, y: y, hit: hit)
            }
            print("AI ready for shoot")
            opponentPlayer?.readyForShoot(delegate: self)
        }else if playerName == myBoard?.name{
            opponentPlayer?.shootResult(x: x, y: y, hit: hit)
            
            let skView = view as! SKView
            if skView.scene is GameScene {
                let gameScene = skView.scene as! GameScene
                print("Player ready for shoot")
                gameScene.readyForShoot()
            }
        }else {
            print("Hoppsan, nu blev det fel")
        }
    }

}
