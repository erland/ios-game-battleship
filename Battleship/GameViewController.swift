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
    var aiPlayer : AIPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()

        startMatchMaking()
    }

    func finishedGame() {
        startMatchMaking()
    }
    
    func startMatchMaking() {
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        // Create and configure the scene.
        let scene = MatchMakingScene(delegate: self, size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        aiPlayer = AIPlayer(name: "AI")
        scene.addOpponent(name: "AI")
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
        
        
        if opponentBoard == nil {
            aiPlayer?.placementCompleted(opponentBoard: board)
            opponentBoard = Board(name:"AI", x: 10, y: 10)
            let carrier = Ship.init(length: 5)
            let battleship = Ship.init(length: 4)
            let crusier = Ship.init(length: 3)
            let submarine = Ship.init(length: 3)
            let destroyer = Ship.init(length: 2)

            aiPlayer?.readyForPlacement(delegate: self, board: opponentBoard!, ships: [carrier, battleship, crusier, submarine, destroyer])
        }else {
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
    }

    func startGame(player: String) {
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        opponentBoard = nil
        myBoard = Board(name: "Player", x: 10, y: 10)
        showPlacementScene(board: myBoard!, view: skView)
    }
    
    private func showPlacementScene(board: Board, view: SKView) {
        // Create and configure the scene.
        let scene = PlacementScene(delegate: self, board: board, size: view.bounds.size)
        scene.scaleMode = .aspectFill
        
        // Present the scene.
        view.presentScene(scene)

    }
    
    func selectedOpponent(player: String) {
        startGame(player: player)
    }
    
    func shoot(playerName: String, x: Int, y: Int) {
        print("Shot from \(playerName)")
        if playerName == myBoard?.name {
            print("Forwarding shot to AI at \(x),\(y)")
            aiPlayer?.shoot(delegate: self, x: x, y: y)
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
            aiPlayer?.readyForShoot(delegate: self)
        }else if playerName == myBoard?.name{
            aiPlayer?.shootResult(x: x, y: y, hit: hit)
            
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
