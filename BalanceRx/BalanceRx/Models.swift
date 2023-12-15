//
//  Models.swift
//  BalanceRx
//
//  Created by Admin on 12/14/23.
//

import Foundation

enum ReactionAddons: Int, CaseIterable {
    case heat
}

struct CombinedElement: Hashable {
    var coefficient: Int
    var elements: [Element]
    
    func encode() -> String {
        return "\(coefficient) \(elements.map { $0.encode() })"
    }
}

struct Element: Hashable {
    var element: String
    var sub: Int
    
    func encode() -> String {
        return "\(element.uppercased())\(sub)"
    }
}

struct Equation {
    let reactants: [CombinedElement]
    let products:  [CombinedElement]
    let reactionAddons: ReactionAddons?
    
    public init(reactants: [CombinedElement],
                products:  [CombinedElement],
                reactionAddons: ReactionAddons? = nil)
    {
        self.reactants = reactants
        self.products  = products
        self.reactionAddons = reactionAddons
    }
    
    func encode() -> String {
        return encodeSide(elements: reactants) + " -> " + encodeSide(elements: products)
    }
    
    private func encodeSide(elements: [CombinedElement]) -> String {
        var stringURL = ""
        
        for element in elements {
            stringURL += element.encode() + "+ "
        }
        
        stringURL.removeLast(2) // for last plus
        
        return stringURL
    }
    
    func decode(xml: String) {
        
    }
}
