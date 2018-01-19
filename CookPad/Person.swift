//
//  Person.swift
//  CookPad
//
//  Created by Justin Mac on 1/8/18.
//  Copyright © 2016 Justin Mac. All rights reserved.
//

import UIKit

class Person {
    
    var name = String()
    var bio = String()
    var email = String()
    var gender = String()
    var id = Int() //unique identifier for every person
    var age = Int()
    var crushes = [Person]() //stores who the person likes in this array
    var matches = [Person]() //stores the matches the person has
    
    static var nextUID = 1
    static func generateUID() -> Int { //creates a unique identifier for each person
        nextUID += 1
        return nextUID
    }
    
    init() {
        name = "No name"
        id = -1
        age = 100
        bio = "Empty Bio"
    }
    
    init(name: String, id: Int, age : Int, bio : String) {
        self.name = name
        self.id = Person.generateUID()
        self.age = age
        self.bio = bio
    }
    
    func addCrush(_ p : Person) -> Void {
        crushes.append(p)
    }
    
    func deleteCrush(_ p: Person) -> Void { //have yet to test this function out
        for index in (0...crushes.count) {
            if (crushes[index] == p) {
                crushes.remove(at: index)
            }
        }
    }
    
    func hasCrushOn(_ p : Person) -> Bool { //checks if the person liked them or not
        for crush in crushes {
            if(crush == p) {
                return true
            }
        }
        return false
    }
    
}

func ==(left : Person, right : Person) -> Bool { //overrides the equality operator
    if (left.name == right.name && left.id == right.id) {
        return true
    }
    return false
}
