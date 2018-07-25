//
//  Card.swift
//  Set
//
//  Created by Ahmed Ramy on 5/29/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

enum Shape: String
{
    case diamond = "diamond"
    case oval = "oval"
    case squiggle = "squiggle"
    
    static let allValues = [diamond, oval, squiggle]
}

enum Color: String
{
    case green = "green"
    case purple = "purple"
    case red = "red"
    
    
    static let allValues = [green, purple, red]
}

enum Number: String
{
    case one = "1"
    case two = "2"
    case three = "3"
    
    
    static let allValues = [one, two, three]
}

enum Shading: String
{
    case outlined = "outlined"
    case stripped = "stripped"
    case solid = "solid"
    
    
    static let allValues = [outlined, stripped, solid]
}

struct Card
{
    let shape: Shape
    let color: Color
    let number: Number
    let shading: Shading
    
    ///Generates Image string like this
    /// `(diamond-green-1-outlined)`
    ///
    ///-Note: refer to the Assets file to understand more
    func generateCardImageString() -> String
    {
        return "\(shape)-\(color)-\(number.rawValue)-\(shading)"
    }
}

