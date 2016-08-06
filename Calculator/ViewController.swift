//
//  ViewController.swift
//  Calculator
//
//  Created by Matt Kelly on 7/31/16.
//  Copyright © 2016 Matt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Display-related functions and variables
    @IBOutlet weak var display: UILabel! // Entered digits/result
    @IBOutlet weak var displayHistory: UILabel! // History of entered numbers and commands
    var userIsInTheMiddleOfTyping = false
    private var displayValue: Double  {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    // Resets calculator to initial state
    private func resetDisplay() {
        display.text = "0"
        displayHistory.text = " "
        userIsInTheMiddleOfTyping =  false
        brain.reset()
    }
    
    // Update the display when the user presses a digit
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            // Add more digits to display, decimal point iff there is none present
            if digit != "." || display.text!.rangeOfString(".") == nil {
                display.text = display.text! + digit
            }
        } else {
            // Add the first digit or decimal point to the display
            display.text = (digit == "." ? "0." : digit)
            userIsInTheMiddleOfTyping = true
        }
    }
    
    // Update the display when the user wants to delete/clear display/etc???
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
        default: break
        }
    }
    

    // Send requested operations to the brain
    private var brain = CalculatorBrain()
    
    // TODO: TRACK WHETHER TO RESET HISTORY IF USER TYPED OPERAND!!!
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayHistory.text! = brain.description
        displayValue = brain.result
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
            displayHistory.text! = brain.description
        }
    }
    
    // XCode stuff
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

