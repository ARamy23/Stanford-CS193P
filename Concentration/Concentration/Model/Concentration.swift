//
//  Concentration.swift
//  Concentration
//
//  Created by Ahmed Ramy on 5/21/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//


/*
 Roles of this model class
 1- New Game function (X)
    1- should face down all cards (X)
    2- should reset score (X)
    3- should reset flips Count (X)
    4- should reset timer (X)
    5- should be automatically triggered with an option in an alert popup at the end (_)
        * try setting an observer on flipsCount after it's more than or equal to cards.count (which is the least number of turns to win the game
    6- should make a new set of identifiers (X)
 2- Should have a way of being observed without violating the MVC princibles (X)
    *Which is*
    * the model and the view are not to be releated unless through a me7rm (a.k.a. Controller)
 
 3- Should keep track of Scores (X)
    _____Score gaining rules_____
    1- a match = score + 2
    2- if a match occured between 2 secs, score += 1
    ---Optional---
    3- add a mulitplier like candy crush's implementation
    _____Score penalty rules______
    1- if a card alreadyFlipped = true and a mismatch occured, then score -1
 
 MARK:- BUGS Found
 1- user can choose the same card which is not handled in our logic (SQUISHED!)
 2- Score is bugged (SQUISHED!)
 
 
 P.S.: try to execute the SOLID Princibles and what you've read from Clean Code book
 */

import Foundation

class Observables: NSObject
{
    @objc dynamic var counter: Double
    
    init(counter: Double)
    {
        self.counter = counter
    }
}

class Concentration
{
    private(set) var cards = [Card]()
    var flipsCount = 0
    var score = 0
    
    var counterObject = Observables(counter: 0.0)
    var firstTimerSnapshot : Double!
    var secondTimerSnapshot: Double!
    
    var timer = Timer()
    var indexOfOnlyMatchUpCardToSelectedCard: Int?
    {
        get
        {
            var foundIndex: Int?
            for index in cards.indices
            {
                if cards[index].isFacedUp
                {
                    if foundIndex == nil
                    {
                        foundIndex = index
                    }else
                    {
                        return nil
                    }
                }
            }
            return foundIndex
        }
        
        set
        {
            for index in cards.indices
            {
                cards[index].isFacedUp = (index == newValue) //if loobed index = setValue of indexOfOneAndOnly, make isFacedup true
            }
        }
    }
    
    
    //MARK: New Game
    fileprivate func resetScore()
    {
        score = 0
    }
    
    fileprivate func resetFlipsCount()
    {
        flipsCount = 0
    }
    
    fileprivate func resetTimer()
    {
        timer.invalidate()
        counterObject.counter = 0.0
    }
    
    fileprivate func resetCards()
    {
        for index in cards.indices
        {
            cards[index].isFacedUp = false
            cards[index].isFacedUpBefore = false
            cards[index].isMatched = false
        }
    }
    
    func reinitGame(numberOfPairs: Int)
    {
        resetScore()
        resetFlipsCount()
        resetTimer()
        initializeGame(numberOfPairs)
        resetCards()
    }
    
    fileprivate func faceDownAfterChoosing(cardAt index: Int) {
        //if no cards are facedup or two cards are facedup
        //face down all the cards
        for flipdownIndex in cards.indices
        {
            if flipdownIndex != index
            {cards[flipdownIndex].isFacedUp = false}
        }
        //then face up the choosen card @index
        cards[index].isFacedUp = !cards[index].isFacedUp
    }
    
    func isAllCardsMatched() -> Bool
    {
        for card in cards
        {
            //if just one card not matched return false
            if !card.isMatched
            {
                return false
            }
        }
        //else all cards are matched is true and therefor an alertView will showup and ask the user if he wants to replay
        return true
    }
    
    //MARK:- choose logic
    fileprivate func areChosenCardsAMatch(at matchIndex: Int, andAt index: Int) -> Bool
    {
        var isMatch = false
        
        if cards[matchIndex] == cards[index]
        {
            cards[matchIndex].isMatched = true
            cards[index].isMatched = true
            isMatch = true
        }
        
        cards[index].isFacedUp = true
        
        return isMatch
    }
    
    
    fileprivate func handleCardPickingLogic(_ firstChosenCardIndex: Int)
    {
        if !cards[firstChosenCardIndex].isMatched //if chosen card is not already matched
        {
            let firstSnapshot = counterObject.counter
            if let secondChosenCardIndex = indexOfOnlyMatchUpCardToSelectedCard, secondChosenCardIndex != firstChosenCardIndex
            {
                if areChosenCardsAMatch(at: secondChosenCardIndex, andAt: firstChosenCardIndex)
                {
                    score += 2
                }
                else if cards[secondChosenCardIndex].isFacedUpBefore && cards[firstChosenCardIndex].isFacedUpBefore //if user did the same mismatch twice
                {
                    //if both cards have been seen before, -2
                    score -= 2
                }
                else if cards[firstChosenCardIndex].isFacedUpBefore // if user inspected the same card twice
                {
                    //if one card only has been faced up before, -1
                    score -= 1
                }
                cards[secondChosenCardIndex].isFacedUpBefore = true
                let secondSnapshot = counterObject.counter
                handleTimerLogic(firstSnapshot: firstSnapshot, secondSnapshot: secondSnapshot)
            }
            else if let secondChosenCardIndex = indexOfOnlyMatchUpCardToSelectedCard, secondChosenCardIndex == firstChosenCardIndex
            {
                self.faceDownAfterChoosing(cardAt: firstChosenCardIndex)
                score -= (cards[firstChosenCardIndex].isFacedUpBefore) ? 1 : 0
                cards[firstChosenCardIndex].isFacedUpBefore = true
                let secondSnapshot = counterObject.counter
                handleTimerLogic(firstSnapshot: firstSnapshot, secondSnapshot: secondSnapshot)
            }
            else
            {
                self.faceDownAfterChoosing(cardAt: firstChosenCardIndex)
                let secondSnapshot = counterObject.counter
                handleTimerLogic(firstSnapshot: firstSnapshot, secondSnapshot: secondSnapshot)
            }
            flipsCount += 1
        }
        else
        {
            print("user picked a hidden element!")
            //FIXME:- You can't pick a hidden element
            // maybe trying to hide the card should work
        }
    }
    
    func chooseCard(at index: Int)
    {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): passed index is not in the cards.indicies")
        handleCardPickingLogic(index)
        cards[index].isFacedUpBefore = true
        //Cheating here
        print(indexOfOnlyMatchUpCardToSelectedCard ?? "None")
    }
    
    fileprivate func setTimer()
    {
        counterObject.counter = 0.0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func updateTimer()
    {
        counterObject.counter += 0.1
    }
    
    fileprivate func handleTimerLogic(firstSnapshot: Double, secondSnapshot: Double)
    {
        /*
         we need to store counter value at each flip
         then when the user flip again
         the new counter is subtracted from the old counter
         if subtraction is less than 1 sec, we add +2
         else if subtraction is less than 3 sec and more than 1 sec, we add +1
         else if subtraction is less than 5 and more than 3, score is unaffected
         else if subtraction is more than 5, score -= 1
        */
        
        let subtraction = secondSnapshot - firstSnapshot
        if(subtraction <= 1)
        {
            score += 2
        }
        else if(1 < subtraction && subtraction <= 3)
        {
            score += 1
        }
        else if(5 <= subtraction)
        {
            score -= 1
        }
        
    }
    
    fileprivate func initializeGame(_ numberOfPairs: Int)
    {
        assert(numberOfPairs > 0, "Concentration.init(numberOfPairs: \(numberOfPairs): you must have at least 1 pair of cards")
        for _ in 1 ... numberOfPairs
        {
            let card = Card()
            
            cards += [card,card]
        }
        
        cards.shuffle()
        setTimer()
    }
    
    init(numberOfPairs: Int)
    {
        initializeGame(numberOfPairs)
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
