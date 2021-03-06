//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Matt Kelly on 7/31/16.
//  Copyright © 2016 Matt. All rights reserved.
//

import Foundation

class CalculatorBrain {
    // PUBLIC
    // Result of a calculation
    var result: Double {
        get {
            return accumulator
        }
    }
    
    // String containing the history of operands and operations
    var description: String {
        get {
            var historyString = ""
            for element in history {
                historyString += element
            }
            if isPartialResult == true {
                historyString += "..."
            }
            else {
                historyString += "="
            }
            return historyString
        }
    }
    
    // Resets the calculator brain to initial state
    func reset() {
        accumulator = 0.0
        isPartialResult = false
        pending = nil
        userOperand = false
        internalProgram.removeAll()
        history.removeAll()
        variableValues.removeAll()
    }
    
    // Sends the on-screen value to the accumulator
    func setOperand(operand: Double) {
        history.append(String(operand))
        accumulator = operand
        internalProgram.append(operand)
        userOperand = true
    }
    
    // Stores a variable's value to the dictionary
    func setOperand(variableName: String) {
        if let value = variableValues[variableName] {
            history.append(variableName)
            accumulator = value
            internalProgram.append(value)
            userOperand = true
        }
    }

    // Performs a mathematical operation
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            internalProgram.append(symbol)
            
            switch operation {
            case .Constant(let value):
                if pending == nil {
                    history = []
                }
                accumulator = value
                history.append(symbol)
                userOperand = true
                isPartialResult = true
                
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
                if history.count == 0 {
                    history.append("0.0")
                }
                if userOperand == true && pending == nil {
                    history = [history.last!]
                }
                userOperand = false
                if pending == nil {
                    history.insert(symbol + "(", atIndex: 0)
                } else {
                    executePendingBinaryOperation()
                    history.insert(symbol + "(", atIndex: history.endIndex-1)
                }
                history.append(")")
                isPartialResult = false
                
            case .BinaryOperation(let function):
                if userOperand == true && pending == nil {
                    history = [history.last!]
                }
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                history.append(symbol)
                isPartialResult = true
                userOperand = false
                
            case .Equals:
                executePendingBinaryOperation()
                isPartialResult = false
                userOperand = false
            }
        }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            reset()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    // TODO: IF OP IS STRING AND IN DICTIONARY...
                    
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    // PRIVATE
    private var accumulator = 0.0
    private var history: [String] = []
    private var userOperand = false
    private var internalProgram = [AnyObject]()
    
    // Supported Operations
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    // Operation Implementations
    private var operations: [String: Operation] = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "±": Operation.UnaryOperation({ -$0 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    // Variable Storage
    var variableValues = [String: Double]()

    // Execute the binary operation if it is in progress
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    // First operand and operation for a pending binary operation
    private var pending: PendingBinaryOperationInfo?
    private var isPartialResult = false
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
}