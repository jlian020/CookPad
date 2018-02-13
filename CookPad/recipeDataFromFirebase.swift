//
//  Person.swift
//  CookPad
//

import UIKit
import CloudKit
import Firebase
//import FirebaseStorage

class recipeDataFromFirebase {
    var name = String()
    var recipeURL: URL

    init(name: String, recipeURL: URL) {
        self.name = name
        self.recipeURL = recipeURL
    }
    
}




