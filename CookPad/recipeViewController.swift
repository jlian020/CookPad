//
//  recipeViewController.swift
//  CookPad
//

import UIKit
import Firebase

class recipeViewController: UIViewController {
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView = UIImageView()
    @IBOutlet weak var nameLabel = UILabel()
    @IBOutlet weak var ingredientsList = UITextView() //lists steps to follow for recipe
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var overlayImageView = UIImageView()
    
    var recipe : Recipe?
    //var image = UIImage()
    //var name = String()
    //var ingredients = String()
    let likeOverlay = UIImage(named: "like button")
    var reference : DatabaseReference?
    let currentUserId = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        reference = Database.database().reference()
        
        self.imageView?.image = self.recipe?.image
        self.nameLabel?.text = self.recipe?.name
        self.ingredientsList?.text = self.recipe?.ingredients
        self.directionsTextView?.text = self.recipe?.directions
        
        var numDirectionsLines = (directionsTextView.contentSize.height / (directionsTextView.font?.lineHeight)!) as? CGFloat
        var numIngredientsLines = ((ingredientsList?.contentSize.height)! / (ingredientsList?.font?.lineHeight)!) as? CGFloat
        let numOfLines = numDirectionsLines! + numIngredientsLines!
        print(numOfLines)
        viewHeight.constant = numOfLines > 8 ? 667 + numOfLines*(directionsTextView.font?.lineHeight)! : 667
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func likeButtonPressed(_ sender: AnyObject) {
        print("like Button pressed")
        //stamp like, hide buttons, save the recipe to saved
        overlayImageView?.isHidden = false
        overlayImageView?.image = likeOverlay
        reference?.child("Users").child(currentUserId!).child("LikedRecipes").child((recipe?.firebaseId)!).setValue(recipe?.firebaseId)
        
        
        //When pressed, save the recipe to the user's 'Saved Recipes' folder
    }
    @IBAction func dislikeButtonPressed(_ sender: AnyObject) {
        self.view.makeToast("Dislike button pressed")
        if(overlayImageView?.image == likeOverlay) {
            overlayImageView?.isHidden = true
        }
    }
}

