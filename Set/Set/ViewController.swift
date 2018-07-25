//
//  ViewController.swift
//  Set
//
//  Created by Ahmed Ramy on 5/29/18.
//  Copyright © 2018 Ahmed Ramy. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet var cardsButtons: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private let game = Set()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupUI()
    }
    
    @IBAction func didTapOnCard(_ sender: UIButton)
    {
        if let cardNumber = cardsButtons.index(of: sender)
        {
            selectCard(at: cardNumber)
        }
        else
        {
            fatalError("User Tapped on an unassigned button, check your outlets!")
        }
    }
    
    fileprivate func resetGame()
    {
        while rootStackView.arrangedSubviews.count > 4
        {
            let lastView = rootStackView.arrangedSubviews.last!
            rootStackView.removeArrangedSubview(lastView)
            lastView.removeFromSuperview()
            cardsButtons.removeLast()
            cardsButtons.removeLast()
            cardsButtons.removeLast()
        }
        game.reinitGame()
        updateUI()
    }
    
    @IBAction func didTapRestart(_ sender: Any)
    {
        resetGame()
    }
    
    @IBAction func didTapOnCheat(_ sender: Any)
    {
        if let set = game.findValidSet()
        {
            for button in cardsButtons
            {
                if button.currentImage == UIImage(named:set[0].generateCardImageString())
                    || button.currentImage == UIImage(named:set[1].generateCardImageString())
                    || button.currentImage == UIImage(named:set[2].generateCardImageString())
                {
                    button.layer.borderWidth = 3.0
                    button.layer.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                    button.layer.cornerRadius = 8.0
                }
            }
        }
        
        scoreLabel.text = "Score: \(game.score)"
    }
    
    @IBAction func didTapDrawMoreCards(_ sender: Any)
    {
        game.drawThreeCardsToBoard()
        
        let boardCards = game.boardCards.compactMap{($0)}
        let boardCardsCount = game.boardCardsCount
        
        if boardCardsCount < 24
        {
            // get images of the last 3 images added to the board
            let image1 = UIImage(named: boardCards[boardCardsCount - 3].card.generateCardImageString())
            let image2 = UIImage(named: boardCards[boardCardsCount - 2].card.generateCardImageString())
            let image3 = UIImage(named: boardCards[boardCardsCount - 1].card.generateCardImageString())
            
            let button1 = UIButton(type: .custom)
            let button2 = UIButton(type: .custom)
            let button3 = UIButton(type: .custom)
            
            // set the images of the button to the images respectively
            button1.setImage(image1, for: .normal)
            button2.setImage(image2,for: .normal)
            button3.setImage(image3,for: .normal)
            
            // add the new set of buttons to the cardsButtons array
            cardsButtons.append(button1)
            cardsButtons.append(button2)
            cardsButtons.append(button3)
            
            // assign the new buttons to the DidTapOnCard IBAction
            button1.addTarget(self, action: #selector(didTapOnCard(_:)), for: .touchUpInside)
            button2.addTarget(self, action: #selector(didTapOnCard(_:)), for: .touchUpInside)
            button3.addTarget(self, action: #selector(didTapOnCard(_:)), for: .touchUpInside)
            
            // create a new row (stackView) with the buttons in it
            let stackView = UIStackView(arrangedSubviews: [button1, button2, button3])
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .equalCentering
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // add the row to the rootStackView
            rootStackView.addArrangedSubview(stackView)
            
        }
        else
        {
            //TODO:- import SVProgressHUD if Abdo approves
            //SVProgressHUD.show(status: "board can not have more than 24 card!")
        }
    }
    
    fileprivate func updateSelectionStateOfCards()
    {
        for index in 0 ..< cardsButtons.count
        {
            let button = cardsButtons[index]
            if let card = game.boardCards[index]
            {
                if card.selected
                {
                    button.layer.borderWidth = 3.0
                    button.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                    button.layer.cornerRadius = 8.0
                }
                else
                {
                    button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                    button.layer.cornerRadius = 0
                }
            }
            else
            {
                fatalError("boardCards[\(index)] is not updated from the deck[\(index)]\ntry debugging in the model layer")
            }
        }
    }
    
    fileprivate func updateCards()
    {
        for index in cardsButtons.indices
        {
            let image = UIImage(named: (game.boardCards.compactMap{($0)}[index].card.generateCardImageString()))
            cardsButtons[index].setImage(image, for: .normal)
        }
    }
    
    fileprivate func updateScoreLabel()
    {
        scoreLabel.text = "Score: \(game.score)"
    }
    
    fileprivate func updateUI()
    {
        updateSelectionStateOfCards()
        updateCards()
        updateScoreLabel()
    }
    
    fileprivate func selectCard(at cardNumber : Int)
    {
        game.selectCard(at: cardNumber)
        updateUI()
    }
    
    fileprivate func setupUI()
    {
        for index in cardsButtons.indices
        {
            
            let image = UIImage(named: (game.boardCards.compactMap{($0)}[index].card.generateCardImageString()))
            
            cardsButtons[index].setImage(image, for: .normal)
        }
    }
    
}

