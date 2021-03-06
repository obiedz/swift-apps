//
//  ViewController.swift
//  TamagotchiApp
//
//  Created by Obied, Zack (NA) on 14/01/2020.
//  Copyright © 2020 Obied, Zack (NA). All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tamagotchiStatistics: UILabel!
    @IBOutlet var tamagotchiImage: UIImageView!
    @IBOutlet var feedMealButton: UIButton!
    @IBOutlet var feedSnackButton: UIButton!
    @IBOutlet var playGameButton: UIButton!
    @IBOutlet var cleanUpButton: UIButton!
    @IBOutlet var medicateButton: UIButton!
    @IBOutlet var shrinkButton: UIButton!
    @IBOutlet var stateDisplay: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    
    var tamagotchi: Tamagotchi? {
        didSet {
            tamagotchiStatistics.text = tamagotchi?.displayStats()
            tamagotchiImage.image = UIImage(named: "happyTamagotchi")
            stateDisplay.text = state
        }
    }
    var timer: Timer?
    var ageTimer = 0
    var feedTimer = 0
    var playTimer = 0
    var cleanTimer = 0
    var medicateTimer = 0
    var timerInvalid = false
    var state = "Hello" {
        didSet {
            stateDisplay.text = state
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tamagotchi = Tamagotchi()
        ageTimer = 10
        feedTimer = 15
        playTimer = 5
        cleanTimer = 20
        medicateTimer = 25
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @IBAction func feedMeal(_ sender: Any) {
        tamagotchi?.feedMeal()
        display()
    }
    
    @IBAction func feedSnack(_ sender: Any) {
        tamagotchi?.feedSnack()
        display()
    }
    
    @IBAction func playGame(_ sender: Any) {
        tamagotchi?.playGame()
        display()
    }
    
    @IBAction func cleanUp(_ sender: Any) {
        tamagotchi?.cleanUp()
        display()
    }
    
    @IBAction func medicate(_ sender: Any) {
        tamagotchi?.medicate()
        display()
    }
    
    @IBAction func shrink(_ sender: Any) {
        tamagotchi?.shrink()
        display()
    }
    
    @IBAction func rules(_ sender: Any) {
        let alert = UIAlertController(title: "Rules", message:
            "Get your tamagotchi to live as long as you can. Here are the rules:\n\n0 < Weight < 10\n0 < Height < 10\nHappy > 0\nHungry < 10\n Ill < 10\nDirty < 10\n\nSurvive 50 days to win!\nCareful, it gets harder as you go!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (_) in
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countdown), userInfo: nil, repeats: true)
        }))
        self.present(alert, animated: true, completion: nil)
        timer?.invalidate()
    }
    
    @IBAction func retryButton(_ sender: Any) {
        tamagotchi?.resetGame()
        feedMealButton.isEnabled = true
        feedSnackButton.isEnabled = true
        playGameButton.isEnabled = true
        cleanUpButton.isEnabled = true
        medicateButton.isEnabled = true
        shrinkButton.isEnabled = true
        tamagotchiStatistics.text = tamagotchi?.displayStats()
        tamagotchiImage.image = UIImage(named: "happyTamagotchi")
        ageTimer = 10
        feedTimer = 15
        playTimer = 5
        cleanTimer = 20
        medicateTimer = 25
        timerInvalid = false
        state = "Hello"
        progressBar.progress = 0.0
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @IBAction func name(_ sender: Any) {
        let alertController = UIAlertController(title: "Name Your Tamagotchi", message: "Enter a name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = "\(self.tamagotchi?.getName() ?? "Tammy")"
        }
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak alertController] (_) in
            let textField = alertController?.textFields![0]
            if textField!.text?.count ?? 10 < 10 && textField!.text?.count ?? 0 > 0 {
                self.tamagotchi?.name(textField!.text ?? "Tammy")
                self.display()
            }
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countdown), userInfo: nil, repeats: true)
        }))
        self.present(alertController, animated: true, completion: nil)
        timer?.invalidate()
    }
    
    func display() {
        tamagotchiStatistics.text = tamagotchi?.displayStats()
        if tamagotchi?.getHealth() == true {
            var noun = "Days"
            if tamagotchi?.getAge() == 1 {
                noun = "Day"
            }
            tamagotchiStatistics.text = "Your Tamagotchi Died\nDue To \(tamagotchi?.getCauseOfDeath() ?? "Mysterious Causes")\n\nYour Tamagotchi Survived \(tamagotchi?.getAge() ?? 0) \(noun)"
            tamagotchiImage.image = UIImage(named: "deadTamagotchi")
            feedMealButton.isEnabled = false
            feedSnackButton.isEnabled = false
            playGameButton.isEnabled = false
            cleanUpButton.isEnabled = false
            medicateButton.isEnabled = false
            shrinkButton.isEnabled = false
            timerInvalid = true
            state = ""
            timer?.invalidate()
        }
    }
    
    @objc func countdown() {
        if ageTimer > 0 {
            ageTimer -= 1
        } else if timerInvalid == false {
            tamagotchi?.growUp()
            progressBar.progress += 0.02
            ageTimer = 10
        }
        if feedTimer > 0 {
            feedTimer -= 1
        } else if timerInvalid == false {
            if tamagotchi?.getHungry() ?? 1 >= 5 {
                state = "I'm Hungry"
                tamagotchiImage.image = UIImage(named: "sadTamagotchi")
            } else {
                tamagotchi?.randomlyIncreaseHungry()
                if tamagotchi?.getHappy() ?? 9 > 5 && tamagotchi?.getIll() ?? 1 < 5 && tamagotchi?.getDirty() ?? 1 < 5 {
                    state = "I'm Full"
                    tamagotchiImage.image = UIImage(named: "happyTamagotchi")
                }
            }
            feedTimer = Int.random(in: 1...30)
        }
        if playTimer > 0 {
            playTimer -= 1
        } else if timerInvalid == false {
            if tamagotchi?.getHappy() ?? 9 <= 5 {
                state = "I'm Sad"
                tamagotchiImage.image = UIImage(named: "sadTamagotchi")
            } else {
                tamagotchi?.randomlyDecreaseHappy()
                if tamagotchi?.getIll() ?? 1 < 5 && tamagotchi?.getHungry() ?? 1 < 5 && tamagotchi?.getDirty() ?? 1 < 5 {
                    state = "I'm Happy"
                    tamagotchiImage.image = UIImage(named: "happyTamagotchi")
                }
            }
            playTimer = Int.random(in: 1...30)
        }
        if cleanTimer > 0 {
            cleanTimer -= 1
        } else if timerInvalid == false {
            if tamagotchi?.getDirty() ?? 1 >= 5 {
                state = "I'm Dirty"
                tamagotchiImage.image = UIImage(named: "sadTamagotchi")
            } else {
                tamagotchi?.randomlyIncreaseDirty()
                if tamagotchi?.getHappy() ?? 9 > 5 && tamagotchi?.getHungry() ?? 1 < 5 && tamagotchi?.getIll() ?? 1 < 5 {
                    state = "I'm Clean"
                    tamagotchiImage.image = UIImage(named: "happyTamagotchi")
                }
            }
            cleanTimer = Int.random(in: 1...30)
        }
        if medicateTimer > 0 {
            medicateTimer -= 1
        } else if timerInvalid == false {
            if tamagotchi?.getIll() ?? 1 >= 5 {
                state = "I'm Sick"
                tamagotchiImage.image = UIImage(named: "sadTamagotchi")
            } else {
                tamagotchi?.randomlyIncreaseIll()
                if tamagotchi?.getHappy() ?? 9 > 5 && tamagotchi?.getHungry() ?? 1 < 5 && tamagotchi?.getDirty() ?? 1 < 5 {
                    state = "I'm Healthy"
                    tamagotchiImage.image = UIImage(named: "happyTamagotchi")
                }
            }
            medicateTimer = Int.random(in: 1...30)
        }
        display()
    }
    
}
