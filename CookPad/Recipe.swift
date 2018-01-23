//
//  Person.swift
//  CookPad
//
//  Created by Justin Mac on 1/8/18.
//  Copyright © 2016 Justin Mac. All rights reserved.
//

import UIKit

class Recipe {
    
    var name = String()
    var id = Int()
    var ingredients = [String]()
    var directions = [String]()
    
    static var nextUID = 1
    static func generateUID() -> Int { //creates a unique identifier for each recipe
        nextUID += 1
        return nextUID
    }
    
    init() {
        name = "No name"
        id = -1
    }
    
    init(name: String, id: Int, ingredients : [String], directions : [String]) {
        self.name = name
        self.id = Recipe.generateUID()
        self.ingredients = ingredients
        self.directions = directions
    }
    
    
}

