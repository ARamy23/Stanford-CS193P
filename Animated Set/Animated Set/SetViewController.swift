//
//  SetViewController.swift
//  Set (By Code)
//
//  Created by Ahmed Ramy on 6/7/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    
    private var cardViews = [SetCardView]()
    private var cardsToAnimate = [SetCardView]()
    private let gameEngine = SetBrain()
    private var selectedCards = [SetCardView]()
    private var hintedCards = [[Int]]()
    
    private var accumlatedCards = [SetCardView]()
    {
        didSet
        {
            if !gameEngine.canDealMoreCards
            {
                dealButton.isHidden = true
            }
            
            if gameEngine.isGameOver
            {
                alert(message: "You Won!")
            }
        }
    }
    
    private var isSet: Bool 
    {
        return gameEngine.isSetValid(cards: selectedCards.map{$0.card!})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let dimensions = getRowsAndColumns(numberOfCards: gameEngine.boardCardsCount)
        let grid = Grid(layout: .dimensions(rowCount: dimensions.rows, columnCount: dimensions.columns), frame: boardView.bounds)
        for i in cardViews.indices
        {
            cardViews[i].frame = grid[i]!
            cardViews[i].setNeedsDisplay()
        }
    }
    
    fileprivate func resizeCardsOnScreenToFitOtherCards() {
        let dimensions = getRowsAndColumns(numberOfCards: gameEngine.boardCardsCount)
        let grid = Grid(layout: .dimensions(rowCount: dimensions.rows, columnCount: dimensions.columns), frame: boardView.bounds)
        for i in cardViews.indices
        {
            UIView.transition(with: cardViews[i],
                              duration: 0.7,
                              options: .allowAnimatedContent,
                              animations: {
                                self.dealButton.isUserInteractionEnabled = false
                                let scaleY = grid[i]!.height / self.cardViews[i].frame.height
                                let scaleX = grid[i]!.width / self.cardViews[i].frame.width
                                self.cardViews[i].transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                                
            }) { (finished) in
                
                UIView.animate(withDuration: 0.5,
                               animations: {
                                self.cardViews[i].frame = grid[i]!
                                self.cardViews[i].setNeedsDisplay(grid[i]!)
                                if i == self.cardViews.endIndex - 1
                                {
                                    self.dealButton.isUserInteractionEnabled = false
                                }
                })
            }
        }
    }
    
    @IBAction func didTapDeal(_ sender: Any)
    {
        gameEngine.drawThreeMoreCardsToBoard()
        resizeCardsOnScreenToFitOtherCards()
        cardsToAnimate.removeAll()
        
        let indexOfFirstOfTheLastThreeCardsToAdd = gameEngine.boardCards.count - 3
        let dealToBoardView = boardView.convert(dealButton.bounds, from: dealButton)
        for i in indexOfFirstOfTheLastThreeCardsToAdd ..< gameEngine.boardCardsCount
        {
            let card = SetCardView(frame: dealToBoardView, card: gameEngine.boardCards[i]!.card)
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizer:))))
            boardView.addSubview(card)
            cardsToAnimate.append(card)
            cardViews.append(card)
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(flyIn), userInfo: nil, repeats: false)

    }
    
    @IBAction func didTapNewGame(_ sender: Any)
    {
        startNewGame()
    }
    
    fileprivate func unhighlightCards()
    {
        cardViews.forEach { $0.state = .isRegular}
    }
    
    fileprivate func checkIsViewSyncedWithModel()
    {
        for viewCard in cardViews.map({$0.card!})
        {
            var cardIsThere = false
            for modelCard in gameEngine.boardCards.map({$0!.card})
            {
                if modelCard == viewCard
                {
                    cardIsThere = true
                }
            }
            if !cardIsThere
            {
                print("This is not in the model anymore")
                print(viewCard)
            }
        }
        
        for modelCard in gameEngine.boardCards.map({$0!.card})
        {
            var cardIsThere = false
            for viewCard in cardViews.map({$0.card!})
            {
                if viewCard == modelCard
                {
                    cardIsThere = true
                }
            }
            if !cardIsThere
            {
                print("This card is not in the view")
                print(modelCard)
            }
        }
    }
    
    @IBAction func didTapHint(_ sender: Any)
    {
        checkIsViewSyncedWithModel()
        gameEngine.findValidSet()
        let validSet = gameEngine.hintCards
        unhighlightCards()
        if validSet.count < 3 { return }
        let groupedSets = validSet.chunked(by: 3)
        print(groupedSets)
        for i in groupedSets.indices
        {
            if !hintedCards.contains(groupedSets[i])
            {
                hintedCards.append(groupedSets[i])
                for j in groupedSets[i].indices
                {
                    cardViews[groupedSets[i][j]].state = .isHinted
                }
                return
            }
        }
        updateScoreLabel()
    }

    private func startNewGame()
    {
        gameEngine.reinitGame()
        boardView.subviews.forEach({$0.removeFromSuperview()})
        updateUI()
    }
    
    private func updateUI()
    {
        updateScoreLabel()
        
        updateViewFromModel()
    }
    
    private func updateViewFromModel()
    {
        cardViews.removeAll()
        cardsToAnimate.removeAll()
        for i in gameEngine.boardCards.indices
        {
            let dealToBoardView = boardView.convert(dealButton.bounds, to: dealButton)
            cardViews.append(SetCardView(frame: dealToBoardView, card: gameEngine.boardCards[i]!.card))
            boardView.addSubview(cardViews[i])
            cardViews[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizer:))))
            cardsToAnimate.append(cardViews[i])
        }
        
        flyIn()
    }
    
    @objc private func flyIn()
    {
        let dimensions = getRowsAndColumns(numberOfCards: gameEngine.boardCardsCount)
        let grid = Grid(layout: .dimensions(rowCount: dimensions.rows, columnCount: dimensions.columns), frame: boardView.bounds)
        
        var delayTime = 0.0
        for timeOfAnimate in 0 ..< cardsToAnimate.count
        {
            let gridIndex = cardViews.index(of: cardsToAnimate[timeOfAnimate])
            delayTime = 0.1 * Double(timeOfAnimate)
            
            UIView.animate(withDuration: 0.7,
                           delay: delayTime,
                           options: .curveEaseInOut,
                           animations: {
                            self.dealButton.isUserInteractionEnabled = false
                            self.cardsToAnimate[timeOfAnimate].frame = grid[gridIndex!]!
            },
                           completion: { (finished) in
                            UIView.transition(with: self.cardsToAnimate[timeOfAnimate],
                                              duration: 0.2,
                                              options: .transitionFlipFromTop,
                                              animations: {
                                                self.cardsToAnimate[timeOfAnimate].isFaceUp = true
                                                self.cardsToAnimate[timeOfAnimate].setNeedsDisplay()
                                                
                            },
                                              completion: { (finished) in
                                                // is last card animated?
                                                if timeOfAnimate == self.cardsToAnimate.endIndex - 1
                                                {
                                                    self.dealButton.isUserInteractionEnabled = true
                                                }
                                                })
                            })
        }
    }
    
    private func updateScoreLabel()
    {
        scoreLbl.text = "Score: \(gameEngine.score)"
    }
    
    
    private func gridForCurrentBoard() -> Grid?
    {
        let (rows, columns) = getRowsAndColumns(numberOfCards: gameEngine.boardCardsCount)
        
        guard rows > 0, columns > 0 else
        {
            return nil
        }
        
        return Grid(layout: .dimensions(rowCount: rows, columnCount: columns), frame: boardView.bounds)
    }
    
    ///
    /// Get the number of rows and columns that will correctly fit the given numberOfCards.
    ///
    private func getRowsAndColumns(numberOfCards: Int) -> (rows: Int, columns: Int) {
        
        // For 0 cards, we don't need any rows/columns
        if numberOfCards <= 0 {
            return (0, 0)
        }
        
        // TODO: The following logic is a "get it to work in 5 min." approach, so you may
        // want to review/change it.
        
        var rows = Int(sqrt(Double(numberOfCards)))
        
        if (rows*rows) < numberOfCards {
            rows += 1
        }
        
        var columns = rows
        
        if ( rows * (columns-1) ) >= numberOfCards {
            columns -= 1
        }
        
        return (rows, columns)
    }
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    private func sendThemFlyingAway()
    {
        let flyawayBehaviour = Flyaway(in: animator)
        var flightCards = [SetCardView]()
        var flipCards = [SetCardView]()
        let dealToBoardView = boardView.convert(scoreLbl.bounds, from: scoreLbl)
        
        selectedCards.forEach()
        {
            let index = cardViews.index(of: $0)
            let card = SetCardView(frame: $0.frame, card: gameEngine.boardCards[index!]!.card)
            card.isFaceUp = true
            let flipCard = SetCardView(frame: dealToBoardView, card: gameEngine.boardCards[index!]!.card)
            flipCard.isFaceUp = true
            flightCards.append(card)
            flipCards.append(flipCard)
            boardView.addSubview(card)
            boardView.addSubview(flipCard)
        }
        
        selectedCards.forEach()
        {
            $0.alpha = 0
        }
        
        flightCards.forEach()
        {
            flyawayBehaviour.addItem($0)
        }
        
        flightCards.forEach()
        { card in
            UIView.animate(withDuration: 1.2,
                           animations: {
                            card.alpha = 0
                            flipCards.forEach{ self.boardView.addSubview($0) }
                            
            },
                           completion: { (finished) in
                            UIView.transition(with: card,
                                              duration: 1,
                                              options: .transitionFlipFromRight,
                                              animations: { flipCards.forEach{ $0.isFaceUp = false; $0.alpha = 1 } },
                                              completion: { (finished) in
                                                card.removeFromSuperview()
                                                flipCards.forEach{ $0.removeFromSuperview() }
                            })
            })
        }
        
        putCardsOntoScreen()
    }
    
    private func putCardsOntoScreen()
    {
        selectedCards.forEach{ $0.alpha = 1}
        
        var cardsOnScreenNeedsResizing = false
        let dealToBoardView = boardView.convert(dealButton.bounds, from: dealButton)
        cardsToAnimate.removeAll()
        
        selectedCards.forEach
        {
            let index = cardViews.index(of: $0)
            let card = cardViews[index!]
            
            if gameEngine.deckCardsCount > 0 || gameEngine.boardCardsCount == cardViews.count
            {
                cardViews[index!] = SetCardView(frame: dealToBoardView, card: gameEngine.boardCards[index!]!.card)
                card.removeFromSuperview()
                boardView.addSubview(cardViews[index!])
                cardViews[index!].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizer:))))
                cardsToAnimate.append(cardViews[index!])
            }
            else
            {
                $0.removeFromSuperview()
                cardViews.remove(at: cardViews.index(of: $0)!)
                cardsOnScreenNeedsResizing = true
            }
        }
        
        if cardsOnScreenNeedsResizing
        {
            resizeCardsOnScreenToFitOtherCards()
        }else
        {
            flyIn()
        }
    }
    
    @objc private func tapCard(recognizer: UITapGestureRecognizer) {
        let tappedCard = recognizer.view as! SetCardView
        gameEngine.selectCard(at: cardViews.index(of: tappedCard)!)
        
        switch tappedCard.state
        {
        case .isSelected:
            tappedCard.state = .isRegular
            selectedCards.remove(at: selectedCards.index(of: tappedCard)!)
        default:
            tappedCard.state = .isSelected
            selectedCards.append(tappedCard)
        }
        
        tappedCard.setNeedsDisplay()
        
        if selectedCards.count == 3
        {
            if isSet
            {
                sendThemFlyingAway()
                hintedCards.removeAll()
            }
            else
            {
                cardViews.forEach
                {
                    $0.state = .isRegular
                }
            }
            
            selectedCards.removeAll()
            updateScoreLabel()
        }
    }

}




extension UIViewController {
    
    func alert(message: String, title: String = "")
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Great", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}


