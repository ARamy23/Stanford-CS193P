//
//  Card.swift
//  Concentration
//
//  Created by Ahmed Ramy on 5/21/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

struct Card
{
    var isFacedUp: Bool = false
    
    //will set this after turn has ended
    var isFacedUpBefore: Bool = false
    
    
    var isMatched: Bool = false
    let identifier: Int //we want this to be hidden
    
    private static var identifierFactory = -1
    
    private static func getUniqueIdentifier() -> Int
    {
        identifierFactory += 1
        return identifierFactory
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool
    {
        return lhs.identifier == rhs.identifier
    }
    
    init()
    {
        self.identifier = Card.getUniqueIdentifier()
    }
}
