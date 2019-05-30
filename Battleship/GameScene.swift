//
//  GameScene.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit
import GameplayKit

extension SKAction {
    class func shake(duration:CGFloat, amplitudeX:CGFloat, amplitudeY:CGFloat) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y:dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
}

class GameScene: SKScene, BoardObserver {
    var battleshipDelegate: BattleshipDelegate?
    var opponentBoardView: BoardView?
    var myBoardView: BoardView?
    var hitTexture: SKTexture?
    var missTexture: SKTexture?
    var smallHitTexture: SKTexture?
    var smallMissTexture: SKTexture?
    var instructionText: SKLabelNode?
    var waitingForShoot: Bool = true
    var opponentDestroyedShips : Int = 0
    var opponentStandingsText: SKLabelNode?
    var myStandingsText: SKLabelNode?
    var opponentStandingsLabel: SKLabelNode?
    var myStandingsLabel: SKLabelNode?

    func setup(delegate: BattleshipDelegate, myBoard: Board, opponentBoard: Board) {
        self.battleshipDelegate = delegate
        
        self.opponentBoardView = childNode(withName: "opponentBoard") as? BoardView
        self.opponentBoardView?.setup(board: opponentBoard)
        self.myBoardView = childNode(withName: "myBoard") as? BoardView
        self.myBoardView?.setup(board: myBoard, showShootMarking: true)
        
        instructionText = childNode(withName: "instructionText") as? SKLabelNode

        myStandingsText = childNode(withName: "myStandingsText") as? SKLabelNode
        opponentStandingsText = childNode(withName: "opponentStandingsText") as? SKLabelNode

        myBoardView?.board?.attachObserver(self)
    }
    deinit {
        myBoardView?.board?.detachObserver(self)
    }
    
    override func didMove(to view: SKView) {
        print("Moved to game scene")
        opponentBoardView?.hideShips(hide: true)
        
        instructionText?.text = "Fire your canon"
        myStandingsText?.text = "\(opponentBoardView!.board!.ships.count)/\(myBoardView!.board!.ships.count)"
        opponentStandingsText?.text = "\(opponentDestroyedShips)/\(myBoardView!.board!.ships.count)"

    }
    func shipAdded(ship: Ship) {
        // Do nothing
    }
    
    func shipRemoved(ship: Ship) {
        // Do nothing
    }
    
    func shootAt(x: Int, y: Int, hit: Bool) {
        if hit {
            self.opponentBoardView?.run(SKAction.shake(duration: 0.5, amplitudeX: opponentBoardView!.cellSize!/2, amplitudeY: opponentBoardView!.cellSize!/2))
            self.myBoardView?.run(SKAction.shake(duration: 0.5, amplitudeX: myBoardView!.cellSize!/2, amplitudeY: myBoardView!.cellSize!/2))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        shoot(position: touchLocation)
    }
    
    func readyForShoot() {
        instructionText?.text = "Fire your canon"
        waitingForShoot = true
    }
    
    func opponentShoot(x: Int, y: Int) {
        let hitShip = myBoardView?.board?.shipAtPosition(x, y)
        let hit = (hitShip != nil)
        hitShip?.shoot(x, y)
        myBoardView?.board?.registerShoot(x: x, y: y, hit: hit)
        
        if let hitShip = hitShip {
            if hitShip.isDestroyed() {
                opponentDestroyedShips = opponentDestroyedShips + 1
                opponentStandingsText?.text = "\(opponentDestroyedShips)/\(myBoardView!.board!.ships.count)"
                battleshipDelegate?.shootResult(playerName: myBoardView!.board!.name, x: x, y: y, hit: true, destroyedShip: hitShip)
            }else {
                battleshipDelegate?.shootResult(playerName: myBoardView!.board!.name, x: x, y: y, hit: true, destroyedShip: nil)
            }
        }else {
            battleshipDelegate?.shootResult(playerName: myBoardView!.board!.name, x: x, y: y, hit: false, destroyedShip: nil)
        }
    }
        
    func shoot(position: CGPoint) {
        if !waitingForShoot {
            return
        }
        let cellX = Int((position.x-opponentBoardView!.position.x)/opponentBoardView!.cellSize!)
        let cellY = Int((opponentBoardView!.position.y-position.y)/opponentBoardView!.cellSize!)
        if cellX>=0 && cellX<opponentBoardView!.board!.width && cellY>=0 && cellY<opponentBoardView!.board!.height {
            if opponentBoardView!.board!.shoots[cellX,cellY] == nil {
                waitingForShoot = false
                instructionText?.text = "Waiting for opponent"
                battleshipDelegate?.shoot(playerName: myBoardView!.board!.name, x: cellX, y: cellY)
            }
        }
    }
    
    func shootResult(x: Int, y: Int, hit: Bool) {
        print("Checking if gameOver count=\(opponentBoardView!.board!.ships.count) and allShipsDestroyed=\(opponentBoardView!.board!.isAllShipsDestroyed())")
        if hit {
            myStandingsText?.text = "\(opponentBoardView!.board!.ships.count)/\(myBoardView!.board!.ships.count)"
        }
        if opponentBoardView!.board!.ships.count == myBoardView!.board!.ships.count && opponentBoardView!.board!.isAllShipsDestroyed() {
            battleshipDelegate?.gameOver(board: myBoardView!.board!, won: true)
        }

    }

}
