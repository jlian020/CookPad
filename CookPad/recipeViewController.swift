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
   
    let likeOverlay = UIImage(named: "like button")
    var reference : DatabaseReference?
    let currentUserId = Auth.auth().currentUser?.uid
    var myLikedRecipe : NSArray?
    var userNumberOfLikedRecipes: Int! = 0
    let savedVC = savedRecipeTVC(nibName: "savedRecipeTVC", bundle: nil)
    
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
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        //Implement share
        
        let activity = UIActivityViewController(activityItems: [self.recipe?.image, self.recipe?.name, self.recipe?.ingredients, self.recipe?.directions], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        print("like Button pressed")
        //stamp like, hide buttons, save the recipe to saved
        overlayImageView?.isHidden = false
        overlayImageView?.image = likeOverlay
        grabLikedFromFirebase {
            var alreadyLiked: Bool = false
            if self.myLikedRecipe != nil {
                for each in self.myLikedRecipe! {
                    print("reaches")
                    if (each as! String) == self.recipe?.firebaseId {
                        print("print")
                        alreadyLiked = true
                    }
                }
            }
            print(alreadyLiked)
            if alreadyLiked == false {
                print("got in")
                self.myFirebaseNetworkDataRequest {
                    //stuff that is down after the fetch from the database
                    self.reference?.child("Users").child(self.currentUserId!).child("LikedRecipes").child("\(self.userNumberOfLikedRecipes! - 1)").setValue(self.recipe?.firebaseId)
                    self.reference?.child("Users").child(self.currentUserId!).child("numOfLikedRecipes").setValue("\(self.userNumberOfLikedRecipes!)")
                    //self.savedVC.loadSavedRecipes()
                }
            }
        }

        
        //When pressed, save the recipe to the user's 'Saved Recipes' folder
    }
    @IBAction func dislikeButtonPressed(_ sender: AnyObject) {
        self.view.makeToast("Dislike button pressed")
        if(overlayImageView?.image == likeOverlay) {
            overlayImageView?.isHidden = true
        }
    }
    
    func myFirebaseNetworkDataRequest(finished: @escaping () -> Void){ // the function thats going to take a little moment
        //this func grabs this data from the database and make sure that it waits for the fetch
        let userID = Auth.auth().currentUser?.uid
        reference?.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() && snapshot.hasChild("numOfLikedRecipes") {
                let value = snapshot.value as? NSDictionary
                let numRecipes: String = (value?["numOfLikedRecipes"] as? String)!
                self.userNumberOfLikedRecipes = Int(numRecipes)! + 1
            }
            else{
                self.userNumberOfLikedRecipes = 1
            }
            finished()
        })
        
    }
    
    func grabLikedFromFirebase(finished: @escaping () -> Void){ // the function thats going to take a little moment
        reference?.child("Users").child(currentUserId!).observeSingleEvent(of: .value, with: {(UserRecipeSnap) in
            if UserRecipeSnap.exists(){
                if UserRecipeSnap.hasChild("LikedRecipes") {
                    let Dict : NSDictionary = UserRecipeSnap.value as! NSDictionary
                    print("entered")
                    self.myLikedRecipe = Dict["LikedRecipes"] as? NSArray
                    finished()
                }
                else {
                    print("LikedRecipes DOES NOT EXIST")
                    finished()
                }
            }
            else {
                print("Error with retrieving snapshot from Firebase")
            }
            
        })
    }

    

    
}

