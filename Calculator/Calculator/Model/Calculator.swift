//
//  File.swift
//  CountOnMe
//
//  Created by Guillaume Bourlart on 31/12/2021.
//  Copyright © 2021 Vincent Saluzzo. All rights reserved.
//

import Foundation

protocol CalculatorDelegate{
    func equationDidChange(text: String)
    func errorOccured(error: Calculator.CalculatorError)
}
class Calculator {
    var delegate: CalculatorDelegate?
    var expression: String = "2 + 2 = 4"
    enum CalculatorError: String { case cantAddOperator = "Impossible d'ajouter cet operateur"
        case cantAddDot = "You can't add a dot"
        case invalidExpression = "Invalid expression"
        case cantDivideByZero = "You can't devide by zero"}
    
    
    enum Operator: String, CaseIterable {
        case plus = "+"
        case minus = "-"
        case multiply = "*"
        case divide = "/"
        case equal = "="
        var displayValue: String{
            return " \(rawValue) "
        }
    }
    
    static let dotSign = "."
    // split elements
    func splitElements() -> [String]{
        return expression.split(separator: " ").map { "\($0)" }
    }
    
    // Verify that last element is not a "+", "-", "*", "/" or "."
    func expressionIsCorrect() -> Bool {
        return splitElements().last != Operator.plus.rawValue && splitElements().last != Operator.minus.rawValue && splitElements().last != Operator.multiply.rawValue && splitElements().last != Operator.divide.rawValue
    }
    
    // verify there is at least 3 element in the expression
    func expressionHaveEnoughElement() -> Bool {
        return splitElements().count >= 3
    }
    
    // verify that operator can be added
    func canAddOperator() -> Bool {
        return splitElements().last != nil && expressionHaveResult() == false
    }
    func thereIsntAlreadyOperator() -> Bool{
        return Operator.allCases.contains { ope in
            return ope.rawValue == splitElements().last
        } == false
    }
    func removeLast(){
        var array = splitElements()
        array.removeLast()
        expression = array.joined(separator: " ")
    }
    // add an operator if it can be added
    func addOperator(operatorToAdd: Operator){
        if canAddOperator()  {
            if thereIsntAlreadyOperator() == false{
                removeLast()
            }
            expression.append(operatorToAdd.displayValue)
            delegate?.equationDidChange(text: expression)
            
            
        } else {
            delegate?.errorOccured(error: .cantAddOperator)
        }
        
    }
    
    // verify that Dot can be added
    func canAddDot() -> Bool {
        return splitElements().last?.contains(Self.dotSign) == false  && splitElements().last != Operator.plus.rawValue && splitElements().last != Operator.minus.rawValue && splitElements().last != Operator.multiply.rawValue && splitElements().last != Operator.divide.rawValue
    }
    // add a Dot if it can be added
    func addDot(){
        if canAddDot()  {
            expression.append(Self.dotSign)
            delegate?.equationDidChange(text: expression)
        } else {
            delegate?.errorOccured(error: .cantAddDot)
        }
        
    }
    
    
    
    func addNumber(number: String){
        guard let _ = Int(number) else {
            
            return
        }
        if expressionHaveResult() {
            resetCalcul()
        }
        expression.append(number)
        delegate?.equationDidChange(text: expression)
        
    }
    // check if expression have a result by looking for a "="
    func expressionHaveResult() -> Bool{
        
        return splitElements().firstIndex(of: Operator.equal.rawValue) != nil
        
    }
    //check if it can be divided by zero
    func devidinByZEro(operand: String, number: Double) -> Bool{
        return (operand == Operator.divide.rawValue && number == 0) == false
    }
    
    // reset the expression
    func resetCalcul(){
        expression = ""
        delegate?.equationDidChange(text: expression)
    }
    
    // calculate final result
    func calculateFinalResult() {
        if canAddOperator() && expressionIsCorrect() && expressionHaveEnoughElement() && expressionHaveResult() == false{
            
            
            // Create local copy of operations
            var operationsToReduce = splitElements()
            
            // Iterate over operations while an operand still here
            while operationsToReduce.count > 1 {
                
                //check if there is "*" or "/" and take the first one
                var i = 1
                var j: Int?
                if let value = operationsToReduce.firstIndex(of: Operator.multiply.rawValue)  {
                    i = value
                }
                if let value = operationsToReduce.firstIndex(of: Operator.divide.rawValue) {
                    j = value
                }
                if j != nil{
                    if i > j!{
                        i = j!
                    }
                }
                
                let left = Double(operationsToReduce[i-1])!
                let operand = operationsToReduce[i]
                let right = Double(operationsToReduce[i+1])!
                
                
                if devidinByZEro(operand: operand, number: right) {
                    
                    let result: Double
                    switch operand {
                    case Operator.plus.rawValue: result = left + right
                    case Operator.minus.rawValue: result = left - right
                    case Operator.multiply.rawValue: result = left * right
                    case Operator.divide.rawValue: result = left / right
                    default: fatalError("Unknown operator !")
                    }
                    
                    // Removes the calculation just done and put the result.
                    operationsToReduce.removeSubrange(i-1...i+1)
                    operationsToReduce.insert("\(result)", at: i-1)
                }else{
                    delegate?.errorOccured(error: .cantDivideByZero)
                    break
                }
                
            }
            if (operationsToReduce.count == 1){
                expression.append(" \(Operator.equal.rawValue) \(operationsToReduce[0])")
                delegate?.equationDidChange(text: expression)
            }
        }else{
            delegate?.errorOccured(error: .invalidExpression)
        }
        
    }
    
}
