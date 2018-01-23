//
//  Person.swift
//  CookPad
//

import UIKit

class Recipe {
    
    var name = String()
    var image = UIImage()
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
    
    init(name: String, image: UIImage, ingredients : [String], directions : [String]) {
        self.name = name
        self.image = image
        self.id = Recipe.generateUID()
        self.ingredients = ingredients
        self.directions = directions
    }
    
    
}

