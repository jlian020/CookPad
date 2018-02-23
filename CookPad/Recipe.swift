//
//  Person.swift
//  CookPad
//

import UIKit
import CloudKit
import Firebase
//import FirebaseStorage

class Recipe {
    
    var name = String()
    var image = UIImage()
    var firebaseId = String()
    var ingredients = String()
    var directions = String()
    
    init(name: String, image: UIImage, ingredients : String, directions : String, id: String) {
        self.name = name
        self.firebaseId = id
        self.ingredients = ingredients
        self.image = image
        self.directions = directions
    }
}



