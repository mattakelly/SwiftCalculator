//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Matt Kelly on 7/31/16.
//  Copyright © 2016 Matt. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private var accumulator = 0.0
    private var history: [String] = []
    
    func setOperand(operand: Double) {
        history.append(String(operand))
        accumulator = operand
    }
    
    func reset() {
        accumulator = 0.0
        history = []
    }
    
    var operations: Dictionary<String, Operation> = [
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
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            if symbol != "=" {
                history.append(symbol)
            }
            
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            isPartialResult = false
        }
        else {
            // TODO: THIS IS BROKEN!
            var firstElement = "0.0"
            if history.count >= 2 {
                firstElement = history[history.count-2]
            }
            history = [firstElement, history[history.count-1]]
            isPartialResult = true
        }
    }
    
    
    private var pending: PendingBinaryOperationInfo?
    private var isPartialResult = false
    
    struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var description: String {
        get {
            var historyString = ""
            for element in history {
                historyString += element
            }
            if isPartialResult {
                historyString += "..."
            }
            else {
                historyString += "="
            }
            return historyString
        }
    }
}