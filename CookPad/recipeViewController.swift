//
//  recipeViewController.swift
//  CookPad
//

import UIKit

class recipeViewController: UIViewController {
    @IBOutlet weak var imageView = UIImageView()
    @IBOutlet weak var nameLabel = UILabel()
    @IBOutlet weak var ingredientsList = UITextView() //lists steps to follow for recipe
    @IBOutlet weak var overlayImageView = UIImageView()
    
    var image = UIImage()
    var name = String()
    var ingredients = String()
    let likeOverlay = UIImage(named: "like button")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView?.image = self.image
        self.nameLabel?.text = self.name
        self.ingredientsList?.text = self.ingredients
        //overlayImageView?.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func likeButtonPressed(_ sender: AnyObject) {
        print("like Button pressed")
        //stamp like, hide buttons
        overlayImageView?.isHidden = false
        overlayImageView?.image = likeOverlay
        //When pressed, save the recipe to the user's 'Saved Recipes' folder
    }
    @IBAction func dislikeButtonPressed(_ sender: AnyObject) {
        print("Dislike button pressed")
        if(overlayImageView?.image == likeOverlay) {
            overlayImageView?.isHidden = true
        }
    }
}
