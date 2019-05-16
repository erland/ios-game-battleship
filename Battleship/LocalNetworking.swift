//
//  LocalNetworking
//  Battleship
//
//  Created by Erland Isaksson on 2019-05-01.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import MultipeerConnectivity


struct Message : Codable {
    let message: String
    let data: Data
}

protocol MessageProcessor {
    func processMessage(peer: String, message: Message)
}

protocol ConnectionManager {
    func addConnection(peer: String)
    func removeConnection(peer: String)
}

class LocalNetworking : NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate  {
    
    let serviceType: String
    let messageProcessor: MessageProcessor
    let connectionManager: ConnectionManager

    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser : MCNearbyServiceAdvertiser?
    private var serviceBrowser : MCNearbyServiceBrowser?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.optional)
        session.delegate = self
        return session
    }()
    
    init(serviceType: String, messageProcessor: MessageProcessor, connectionManager: ConnectionManager) {
        self.serviceType = serviceType
        self.messageProcessor = messageProcessor
        self.connectionManager = connectionManager
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
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from: \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Sending invite to: \(peerID.displayName)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost connection to: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.connectionManager.removeConnection(peer: peerID.displayName)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == MCSessionState.connected {
            print("Connected to: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionManager.addConnection(peer: peerID.displayName)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = try! JSONDecoder().decode(Message.self, from: data)
        DispatchQueue.main.async {
            self.messageProcessor.processMessage(peer: peerID.displayName, message: message)
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

    func sendMessage(message: Message) {
        let jsonMessage = try! JSONEncoder().encode(message)
        for peer in session.connectedPeers {
            print("Sending \(message.message) to: \(peer.displayName)")
            do {
                try self.session.send(jsonMessage, toPeers: [peer], with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    func sendMessage(player: String, message: Message) {
        let jsonMessage = try! JSONEncoder().encode(message)

        for peer in session.connectedPeers {
            if peer.displayName==player {
                print("Sending \(message.message) to: \(player)")
                do {
                    try self.session.send(jsonMessage, toPeers: [peer], with: .reliable)
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
                break
            }
        }
    }

}
