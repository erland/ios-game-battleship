//
//  LocalNetworking
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import MultipeerConnectivity

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
    
    init(x: Int, y: Int, hit: Bool) {
        self.x = x
        self.y = y
        self.hit = hit
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
                let shipObj = Ship(length: ship.length)
                if ship.horizontal {
                    shipObj.orientation = Ship.Orientation.Horizontal
                    shipObj.x = ship.x
                    shipObj.y = ship.y
                }else {
                    shipObj.orientation = Ship.Orientation.Vertical
                    shipObj.x = ship.x
                    shipObj.y = ship.y
                }
                result.append(shipObj)
            }
        }
        return result
    }
}

struct Message : Codable {
    let message: String
    let data: Data
}

class LocalNetworking : NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate  {
    
    let serviceType = "Battleship"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser : MCNearbyServiceAdvertiser?
    private var serviceBrowser : MCNearbyServiceBrowser?
    let battleshipDelegate: BattleshipDelegate
    var peers: Set<String> = Set()
    var readyToPlay: Bool = false
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self
        return session
    }()
    
    init(battleshipDelegate: BattleshipDelegate) {
        self.battleshipDelegate = battleshipDelegate
        super.init()
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        self.serviceAdvertiser?.delegate = self
        self.serviceAdvertiser?.startAdvertisingPeer()
        self.serviceBrowser?.delegate = self
        self.serviceBrowser?.startBrowsingForPeers()
    }

    deinit {
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceBrowser?.stopBrowsingForPeers()
    }
    
    func start() {
        self.serviceAdvertiser?.startAdvertisingPeer()
        self.serviceBrowser?.startBrowsingForPeers()
    }
    
    func stop() {
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceBrowser?.stopBrowsingForPeers()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received connection to player: \(peerID.displayName)")
        //NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Connecting to player: \(peerID.displayName)")
        //NSLog("%@", "foundPeer: \(peerID)")
        //NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        //NSLog("%@", "lostPeer: \(peerID)")
        print("Lost player: \(peerID.displayName)")
        peers.remove(peerID.displayName)
        DispatchQueue.main.async {
            self.battleshipDelegate.removeOpponent(player: peerID.displayName)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == MCSessionState.connected {
            print("Connected to \(peerID.displayName)")
            sendReadyToPlay(player: peerID.displayName)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //NSLog("%@", "didReceiveData: \(data)")

        let message = try! JSONDecoder().decode(Message.self, from: data)
        if message.message == "readyForPlacement" {
            let board = try! JSONDecoder().decode(NetworkBoard.self, from: message.data)
            print("Received readyForPlacement on \(board.boardWidth),\(board.boardHeight) board")
            DispatchQueue.main.async {
                self.battleshipDelegate.readyForPlacement(player: peerID.displayName, x: board.boardWidth, y: board.boardHeight)
            }
        }else if message.message == "placementCompleted" {
            let networkBoard = try! JSONDecoder().decode(NetworkBoard.self, from: message.data)
            let board = Board(name: peerID.displayName, x: networkBoard.boardWidth, y: networkBoard.boardHeight)
            for (_,ship) in networkBoard.getShipObjects().enumerated() {
                board.addShip(ship: ship, x: ship.x, y: ship.y)
            }
            print("Received placementCompleted on \(board.width),\(board.height) board")
            DispatchQueue.main.async {
                self.battleshipDelegate.placementComplete(board: board)
            }
        }else if message.message == "readyForShoot" {
            print("Received readyForShoot, doing nothing")
        }else if message.message == "readyToPlay" {
            print("Received readyToPlay")
            peers.insert(peerID.displayName)
            DispatchQueue.main.async {
                self.battleshipDelegate.addOpponent(player: peerID.displayName)
            }
        }else if message.message == "finishedPlaying" {
            print("Received finishedPlaying")
            peers.remove(peerID.displayName)
            DispatchQueue.main.async {
                self.battleshipDelegate.removeOpponent(player: peerID.displayName)
            }
        }else if message.message == "shoot" {
            let networkShoot = try! JSONDecoder().decode(NetworkShoot.self, from: message.data)
            print("Received shoot at \(networkShoot.x),\(networkShoot.y)")
            DispatchQueue.main.async {
                self.battleshipDelegate.shoot(playerName: peerID.displayName, x: networkShoot.x, y: networkShoot.y)
            }
        }else if message.message == "shootResult" {
            let networkShootResult = try! JSONDecoder().decode(NetworkShootResult.self, from: message.data)
            print("Received shootResult at \(networkShootResult.x),\(networkShootResult.y) = \(networkShootResult.hit)")
            DispatchQueue.main.async {
                self.battleshipDelegate.shootResult(playerName: peerID.displayName, x: networkShootResult.x, y: networkShootResult.y, hit: networkShootResult.hit)
            }
        }else {
            print("Unknown message: \(message.message)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //NSLog("%@", "didFinishReceivingResourceWithName")
    }

    func sendReadyForPlacement(player: String, board: NetworkBoard) {
        let jsonData = try! JSONEncoder().encode(board)
        sendMessage(player: player, message: Message(message: "readyForPlacement", data: jsonData))

    }
    func sendPlacementCompleted(player: String, board: NetworkBoard) {
        let jsonData = try! JSONEncoder().encode(board)
        sendMessage(player: player, message: Message(message: "placementCompleted", data: jsonData))
        
    }
    func sendShoot(player: String, shoot: NetworkShoot) {
        let jsonData = try! JSONEncoder().encode(shoot)
        sendMessage(player: player, message: Message(message: "shoot", data: jsonData))
        
    }
    func sendShootResult(player: String, shootResult: NetworkShootResult) {
        let jsonData = try! JSONEncoder().encode(shootResult)
        sendMessage(player: player, message: Message(message: "shootResult", data: jsonData))
        
    }
    func sendReadyForShoot(player: String) {
        sendMessage(player: player, message: Message(message: "readyForShoot", data: "{}".data(using: .utf8)!))
    }

    func sendReadyToPlay(player: String?) {
        readyToPlay = true
        let message = Message(message: "readyToPlay", data: "{}".data(using: .utf8)!)
        let jsonMessage = try! JSONEncoder().encode(message)
        for peer in session.connectedPeers {
            if player == nil || player == peer.displayName {
                print("Sending \(message.message) to \(peer.displayName)")
                do {
                    try self.session.send(jsonMessage, toPeers: [peer], with: .reliable)
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
            }
        }
    }

    func sendFinishedPlaying() {
        readyToPlay = false
        let message = Message(message: "finishedPlaying", data: "{}".data(using: .utf8)!)
        let jsonMessage = try! JSONEncoder().encode(message)
        for peer in session.connectedPeers {
            print("Sending \(message.message) to \(peer.displayName)")
            do {
                try self.session.send(jsonMessage, toPeers: [peer], with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }

    func sendMessage(player: String, message: Message) {
        print("Preparing to send \(message.message) to \(player)")
        print("Using data: \(message.data)")
        let jsonMessage = try! JSONEncoder().encode(message)

        for peer in session.connectedPeers {
            if peer.displayName==player {
                print("Sending \(message.message) to \(player)")
                do {
                    try self.session.send(jsonMessage, toPeers: [peer], with: .reliable)
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
                break
            }
        }
        print("Finished sending \(message.message)")

    }

}
