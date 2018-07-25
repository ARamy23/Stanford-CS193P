//
//  SetGame.swift
//  Set
//
//  Created by Ahmed Ramy on 5/29/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

class Set
{
    //MARK:- Properties
    
    ///Total Cards there in the game
    ///
    /// - Note: count = 81
    private var deck = [Card]()
    
    ///Total Cards on the board which are visible to the User
    private(set) var boardCards = [ (card: Card, selected: Bool)? ]()
    
    private(set) var score = 0
    
    var boardCardsCount: Int
    {
        return boardCards.compactMap{$0}.count
    }
    
    var isOver: Bool
    {
        return boardCards.isEmpty && deck.isEmpty
    }
    
    //MARK:- Choosing Mechanism

    func getCard(at index: Int) -> Card?
    {
        return index < boardCards.count ? boardCards[index]?.card : nil
    }
    
    fileprivate func unselectAllCards() {
        for i in boardCards.indices
        {
            boardCards[i]?.selected = false
        }
    }
    
    fileprivate func removeTheMatchFromBoard() {
        for _ in 1 ... 3
        {
            for i in boardCards.indices
            {
                if boardCards[i]?.selected == true
                {
                    boardCards.remove(at: i)
                    break
                }
            }
        }
    }
    
    ///check if passed 3 cards are a match
    fileprivate func isSetValid(cards: [Card]) -> Bool
    {
        let isMatch = cards.isValidSet{($0.color == $1.color)} &&
        cards.isValidSet{($0.number == $1.number)} &&
        cards.isValidSet{($0.shape == $1.shape)} &&
        cards.isValidSet{($0.shading == $1.shading)}
        
        return isMatch
    }
    
    func selectCard(at index: Int)
    {
        if let emptiness = boardCards[index]
        {
            boardCards[index]?.selected = !emptiness.selected
            
            let cards = boardCards.filter{($0?.selected ?? false)}.map({$0!.card})
            
            if cards.count == 3
            {
                
                //If match was valid, remove the cards from the boardCards and replace them with other 3 from the deck
                if isSetValid(cards: cards)
                {
                    score += 5
                    removeTheMatchFromBoard()
                    drawThreeCardsToBoard()
                }
                else
                {
                    score -= 3
                }
                
                unselectAllCards()
            }
        }
    }
    
    //MARK:- Initialization
    
    fileprivate func initDeckCards() {
        let allShapes = Shape.allValues
        let allNumbers = Number.allValues
        let allColors = Color.allValues
        let allShadings = Shading.allValues
        
        //FIXME:- Find a better way of writing this...
        for shape in allShapes
        {
            for color in allColors
            {
                for number in allNumbers
                {
                    for shading in allShadings
                    {
                        let card = Card(shape: shape, color: color, number: number, shading: shading)
                        deck.append(card)
                    }
                }
            }
        }
    }
    
    
    
    func drawThreeCardsToBoard()
    {
        for _ in 1 ... 3
        {
            drawCardToBoard()
        }
    }
    
    fileprivate func drawCardToBoard()
    {
        if let card = deck.popLast()
        {
            boardCards.append((card: card, selected: false))
        }
    }
    
    fileprivate func emptyDeckAndBoard()
    {
        deck.removeAll()
        boardCards.removeAll()
    }
    
    func reinitGame(deal numberOfCards: Int = 12)
    {
        emptyDeckAndBoard()
        initDeckCards()
        deck.shuffle()
        
        for _ in 0 ..< numberOfCards
        {
            drawCardToBoard()
        }
        score = 0
    }
    
    init(deal numberOfCards: Int = 12)
    {
        initDeckCards()
        deck.shuffle()
        
        for _ in 0 ..< numberOfCards
        {
            drawCardToBoard()
        }
    }
    
    
}

//MARK:- Extra Credits

extension Set
{
    /// returns a valid set in the current board cards
    func findValidSet() -> [Card]?
    {
        let validBoardCards = boardCards.compactMap{($0)}
        for firstCard in 0 ..< validBoardCards.count
        {
            for secondCard in firstCard + 1 ..< validBoardCards.count
            {
                for thirdCard in secondCard + 1 ..< validBoardCards.count
                {
                    let set = [validBoardCards[firstCard].card, validBoardCards[secondCard].card, validBoardCards[thirdCard].card]
                    if isSetValid(cards: set)
                    {
                        score -= 5
                        return set
                    }
                }
                
            }
        }
        
        
        return nil
    }
    

}

extension Array  {
    
    func isValidSet (_ sets: (Element, Element) -> Bool ) -> Bool
    {
        
        var same = true
        var diff = true
        
        for i in self.indices {
            for j in self.indices {
                if j != i {
                    same = same && sets( self[i], self[j] )
                    diff = diff && !sets( self[i], self[j] )
                }
            }
        }
        return same || diff
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

