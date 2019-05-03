//
//  NetworkOpponent.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import MultipeerConnectivity
/*
class NetworkOpponent : MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, CommandDelegate {
    
    let serviceType = "Battleship"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser : MCNearbyServiceAdvertiser?
    private var serviceBrowser : MCNearbyServiceBrowser?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    init() {
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
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
        let skView = view as! SKView
        if skView.scene is MatchMakingScene {
            let scene = skView.scene as! MatchMakingScene
            scene.addOpponent(name: peerID.displayName)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        let skView = view as! SKView
        if skView.scene is MatchMakingScene {
            let scene = skView.scene as! MatchMakingScene
            scene.removeOpponent(name: peerID.displayName)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        if let command = String(data: data, encoding: .utf8) {
            if command == "startGame" {
                startGame(player: myPeerId.displayName)
            }else if command.starts(with: "shoot:") {
                let coordinatePart = command[String.Index(encodedOffset: 5)...]
                let coordinates = coordinatePart.split(separator: ",")
                let posX = Int(coordinates[0])
                let posY = Int(coordinates[1])
                print("Shoot at \(posX),\(posY)")
                
            }
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func sendShoot(player: String, x: Int, y: Int) {
        for peer in session.connectedPeers {
            if peer.displayName==player {
                do {
                    try self.session.send("shoot:\(x),\(y)".data(using: .utf8)!, toPeers: [peer], with: .reliable)
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
                break
            }
        }
    }

    func sendStartGame(player: String) {
        for peer in session.connectedPeers {
            if peer.displayName==player {
                do {
                    try self.session.send("startGame".data(using: .utf8)!, toPeers: [peer], with: .reliable)
                    startGame(player: peer.displayName)
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
                break
            }
        }
    }

}
*/
