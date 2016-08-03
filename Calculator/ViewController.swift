//
//  ViewController.swift
//  Calculator
//
//  Created by Matt Kelly on 7/31/16.
//  Copyright © 2016 Matt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var displayHistory: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var numberInDisplayIsInt = true
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            } else {
                display.text = digit
                userIsInTheMiddleOfTyping = true
            }
    }
    
    private var displayValue: Double  {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            numberInDisplayIsInt = true
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayHistory.text! = brain.description
        displayValue = brain.result
    }
    
    private func resetDisplay() {
        display.text = "0"
        displayHistory.text = " "
        userIsInTheMiddleOfTyping =  false
        numberInDisplayIsInt = true
    }
 
    @IBAction private func manipulateDisplay(sender: UIButton) {
        let manipulation = sender.currentTitle!
        switch manipulation {
        case "AC" :
            resetDisplay()
        case "DEL" :
            if userIsInTheMiddleOfTyping {
                if display.text!.characters.count == 1 {
                    resetDisplay()
                } else {
                    display.text!.removeAtIndex(display.text!.endIndex.predecessor())
                }
            }
        case "D" :
            if numberInDisplayIsInt {
                if userIsInTheMiddleOfTyping == false {
                    display.text = "0"
                    userIsInTheMiddleOfTyping = true
                }
                display.text = display.text! + "."
                numberInDisplayIsInt = false
            }
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

