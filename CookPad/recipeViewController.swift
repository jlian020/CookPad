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
    var ingredientString = String()
    let likeOverlay = UIImage(named: "like button")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView?.image = self.image
        self.nameLabel?.text = self.name
        self.ingredientsList?.text = self.ingredientString
        //overlayImageView?.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func likeButtonPressed(_ sender: AnyObject) {
        print("like Button pressed")
        //stamp like, hide buttons, save the recipe to saved
        overlayImageView?.isHidden = false
        overlayImageView?.image = likeOverlay
    }
    @IBAction func dislikeButtonPressed(_ sender: AnyObject) {
        print("Dislike button pressed")
        if(overlayImageView?.image == likeOverlay) {
            overlayImageView?.isHidden = true
        }
    }
}
