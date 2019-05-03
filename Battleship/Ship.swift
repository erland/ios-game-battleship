//
//  Ship.swift
//  Battleship
//
//  Created by Erland Isaksson on 2019-04-30.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

protocol ShipObserver {
    func shipUpdated(ship: Ship)
}
class Ship : Hashable {
    let length: Int
    var observers: [ShipObserver] = []
    var hits:Array<Bool>

    enum Orientation: Int {
        case Horizontal=0, Vertical
    }
    
    init(length: Int) {
        self.length = length
        self.x = 0
        self.y = 0
        self.orientation = Orientation.Horizontal
        self.hits = Array(repeating: false, count: length)
    }
    
    func attachObserver(observer: ShipObserver) {
        observers.append(observer)
    }
    
    func shoot(x: Int, y: Int) -> Bool {
        var result: Bool = false
        if orientation==Orientation.Horizontal {
            if y==self.y && x>=self.x && x < self.x+length {
                hits[x-self.x] = true
                result = true
            }
        }else {
            if x==self.x && y>self.y-length && y <= self.y {
                hits[self.y-y] = true
                result = true
            }
        }
        notifyObservers()
        return result
    }
    
    func isDestroyed() -> Bool {
        for hit in hits {
            if !hit {
                return false
            }
        }
        return true
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.shipUpdated(ship: self)
        }
    }
    var x: Int {
        didSet {
            notifyObservers()
        }
    }
    var y: Int {
        didSet {
            notifyObservers()
        }
    }
    var orientation: Orientation {
        didSet {
            notifyObservers()
        }
    }
    var selected: Bool = false {
        didSet {
            notifyObservers()
        }
    }
    static func == (lhs: Ship, rhs: Ship) -> Bool {
        return lhs === rhs
    }
    var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}

