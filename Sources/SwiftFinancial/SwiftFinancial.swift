//
//  Amortization.swift
//  RateSim
//
//  Created by Zachary Luety on 1/16/22.
//

import Foundation

// Compute the payment against loan principal plus interest.
public func pmt(rate: Double, numPeriods: Int, presentValue: Double, futureValue: Double = 0, whenDue: Int = 0) -> Double {
    
    let temp: Double = pow(1 + rate, Double(numPeriods))
    let fact: Double = (1 + rate * Double(whenDue)) * (temp - 1) / rate
    return -(futureValue + presentValue * temp) / fact
}

// Compute the present value.
public func pv(rate: Double, numPeriods: Int, payment: Double, futureValue: Double, whenDue: Int = 0) -> Double {
    
    let temp: Double = pow(1 + rate, Double(numPeriods))
    let fact: Double = (1 + rate * Double(whenDue)) * (temp - 1) / rate
    
    return -(futureValue + payment * fact) / temp
}


// Compute the future value.
public func fv(rate: Double, numPeriods: Int, payment: Double, presentValue: Double, whenDue: Int = 0) -> Double {
    
    let temp: Double = pow(1 + rate, Double(numPeriods))
    let fact: Double = (1 + rate * Double(whenDue)) * (temp - 1) / rate
    
    return -presentValue * temp - payment * fact
}

// Compute the interest portion of a payment.
public func ipmt(rate: Double, period: Int, numPeriods: Int, presentValue: Double, futureValue: Double = 0, whenDue: Int = 0) -> Double {
    
    let totalPayment: Double = pmt(rate: rate, numPeriods: numPeriods, presentValue: presentValue, futureValue: futureValue, whenDue: whenDue)
    
    let remainingBalance = fv(rate: rate, numPeriods: period - 1, payment: totalPayment, presentValue: presentValue, whenDue: whenDue)
    
    return remainingBalance * rate
}

// Compute the payment against loan principal.
public func ppmt(rate: Double, period: Int, numPeriods: Int, presentValue: Double, futureValue: Double = 0, whenDue: Int = 0) -> Double {
    
    let totalPayment: Double = pmt(rate: rate, numPeriods: numPeriods, presentValue: presentValue, futureValue: futureValue, whenDue: whenDue)
    
    return totalPayment - ipmt(rate: rate, period: period, numPeriods: numPeriods, presentValue: presentValue, futureValue: futureValue, whenDue: whenDue)
}

// Compute the Internal Rate of Return of a series of cash flows.
public func irr(cashFlows: [Double], estimate: Double? = nil) -> Double {
    var iteration: Int = 1
    let n: Int = cashFlows.count - 1
    let exponent: Double = 1.0 / (1.0 + 0.5 * (Double(n) - 1.0)) - 1.0
    
    
    // Pascual, Nerio & Sison, Ariel & Gerardo, Bobby & Medina, Ruji. (2018). Calculating Internal Rate of Return (IRR) in Practice using Improved Newton-Raphson Algorithm. Philippine Computing Journal. 13. 17-21.
    var guess: Double = estimate ?? pow(cashFlows[1...].reduce(0, +) / -cashFlows[0], exponent)
    var nextGuess: Double
    
    while abs(npv(rate: guess, cashFlows: cashFlows)) >= 0.0000000000001 && iteration <= 10 {
        nextGuess = guess - npv(rate: guess, cashFlows: cashFlows) / dnpv(rate: guess, cashFlows: cashFlows)
        guess = nextGuess
        iteration += 1
    }
    
    return guess

}

// Compute the Net Present Value of a series of cash flows.
public func npv(rate: Double, cashFlows: [Double]) -> Double {
    let periods = 0...cashFlows.count
    let discountFactors = periods.map {1 / pow(1 + rate, Double($0))}
    
    var discountedCashFlows = [Double]()
    for (cashFlow, discountFactor) in zip(cashFlows, discountFactors) {
        discountedCashFlows.append(cashFlow * discountFactor)
    }
    
    return discountedCashFlows.reduce(0, +)
}

private func dnpv(rate: Double, cashFlows: [Double]) -> Double {
    let periods = 0...cashFlows.count
    let discountFactors = periods.map { 1 / pow(1 + rate, Double($0 + 1))}
    
    let zipped = Array(zip(cashFlows, discountFactors))
    
    var values = [Double]()
    var cashFlow: Double
    var discountFactor: Double

    for (index, item) in zipped.enumerated() {
        cashFlow = item.0
        discountFactor = item.1
        values.append(Double(-index) * cashFlow * discountFactor)
    }
    
    return values.reduce(0, +)
}
