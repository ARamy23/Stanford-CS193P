//
//  SetBrain.swift
//  Set (By Code)
//
//  Created by Ahmed Ramy on 6/4/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import Foundation

/*
 Roles of this model
 1- New Game Function (X)
 2- Should have a way of observing internal and Read-Only (private(set)) properties and methods without violating MVC princibles (X)
 3- Should Keep track of the score (X)
 4- Handle Selecetion and Deselection (X)
 5- keep track of Valid Sets (X)
 6- have a timer functionality ()
 7- utilize the timer in implementing a "vs iPhone" mode ()
 */


class SetBrain
{
    /// Total Cards in the whole game (at start = 81)
    private var deck = [Card]()
    
    /// Total Cards in the View
    private(set) var boardCards = [ (card: Card,selected: Bool)? ]()
    private(set) var score = 0
    private(set) var hintCards = [Int]()
    
    private var observations = [ObjectIdentifier: Observation]()
    
    var deckCardsCount: Int
    {
        return deck.count 
    }
    
    /// Count of non-nil cards
    var boardCardsCount: Int
    {
        return boardCards.compactMap{($0)}.count
    }
    
    var canDealMoreCards: Bool
    {
        return deck.count >= 3
    }
    
    var isGameOver: Bool
    {
        return boardCards.isEmpty && deck.isEmpty
    }
    
    
    //MARK:- Choosing Mechanism
    
    func getCard(at index: Int) -> Card?
    {
        return index < boardCards.count ? boardCards[index]?.card : nil
    }
    
    func unselectAllCards() {
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
    func isSetValid(cards: [Card]) -> Bool
    {
        if cards.count == 0 { return false }
        
        let color = Set(cards.map{ $0.color }).count
        let shape = Set(cards.map{ $0.shape }).count
        let number = Set(cards.map{ $0.number }).count
        let shading = Set(cards.map{ $0.shading }).count
        
        return color != 2 && shape != 2 && number != 2 && shading != 2
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
                    hintCards.removeAll()
                    drawThreeMoreCardsToBoard()
                }
                else
                {
                    score -= 3
                }
            }
        }
    }
    
    func drawThreeMoreCardsToBoard()
    {
        for _ in 1 ... 3
        {
            drawCardToBoard()
        }
            
    }
    
    //MARK:- Initialization
    
    fileprivate func initDeckCards() {
        let allShapes = Shape.allValues
        let allNumbers = Number.allValues
        let allColors = Color.allValues
        let allShadings = Shading.allValues
        
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
    
    func reinitGame(deal numberOfCards: Int = 9)
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
    
    fileprivate func drawCardsToDeckFirstTime(_ numberOfCards: Int = 9)
    {
        for _ in 0 ..< numberOfCards
        {
            drawCardToBoard()
        }
        
        findValidSet()
        
        if hintCards.count < 3
        {
            hintCards.removeAll()
            boardCards.removeAll()
            drawCardsToDeckFirstTime()
        }
    }
    
    fileprivate func initGame(_ numberOfCards: Int = 9) {
        initDeckCards()
        deck.shuffle()
        
        drawCardsToDeckFirstTime(9)
        
    }
    
    init(deal numberOfCards: Int = 9)
    {
        initGame(numberOfCards)
        
    }
    
    
}

//MARK:- Extra Credits

// MARK:- Providing Hints
extension SetBrain
{
    func findValidSet()
    {
        hintCards.removeAll()
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
                        if !(hintCards.contains(firstCard) && hintCards.contains(secondCard) && hintCards.contains(thirdCard))
                        {
                            hintCards += [firstCard, secondCard, thirdCard]
                            
                        }
                    }
                }
                
            }
        }
    }
    
    
}

// MARK:- Providing a timer
// Using Observer pattern
protocol TimerObserver: class
{
    func timer(_ timer: Timer, didStartUpdatingTimer: Bool)
    func timer(_ timer: Timer, observeTimerCounter counter: Double)
    func timer(_ timer: Timer, didEndUpdatingTimer: Bool)
}

extension SetBrain
{
    struct Observation
    {
        weak var observer: TimerObserver?
    }
}

private extension SetBrain
{
    //TODO:- Continue doing it from here: https://www.swiftbysundell.com/posts/observers-in-swift-part-1
}

//MARK:- Helpers

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

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
