//
//  editRecipeViewController.swift
//  CookPad
//

import UIKit
import Firebase

class editRecipeViewController: UIViewController {
    
    @IBOutlet weak var imageView = UIImageView()
    @IBOutlet weak var nameLabel = UILabel()
    //@IBOutlet weak var ingredientsList = UITextView() //lists steps to follow for recipe
    //@IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var overlayImageView = UIImageView()
    
    @IBOutlet weak var directionsList: UILabel!
    @IBOutlet weak var ingredientsList: UILabel!
    var recipe : Recipe?
    
    let likeOverlay = UIImage(named: "like button")
    var reference : DatabaseReference?
    let storage = Storage.storage()
    let currentUserId = Auth.auth().currentUser?.uid
    var myRecipes : NSArray?
    var userNumberOfLikedRecipes: Int! = 0
    let currentUserID = Auth.auth().currentUser?.uid
    let MyVc = myRecipeViewController(nibName: "myRecipeViewController", bundle: nil)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        reference = Database.database().reference()
        self.imageView?.image = self.recipe?.image
        self.nameLabel?.text = self.recipe?.name
        self.ingredientsList?.text = self.recipe?.ingredients
        self.directionsList?.text = self.recipe?.directions
        self.ingredientsList.sizeToFit()
        self.directionsList.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Edit Recipe", message: "What do you want to edit?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Title of Recipe", style: .default, handler: editRecipeTitle))
        //alert.addAction(UIAlertAction(title: "Description", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ingredients", style: .default, handler: editRecipeIngredients))
        alert.addAction(UIAlertAction(title: "Directions", style: .default, handler: editRecipeDirections))
        alert.addAction(UIAlertAction(title: "Delete Recipe", style: .default, handler: deleteRecipe))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.performSegue(withIdentifier: "showMyRecipes", sender: self)
        }))
        self.present(alert, animated: true)
    }
    
    func editRecipeTitle(alertAction: UIAlertAction) -> Void {
        let alert = UIAlertController(title: "Edit Recipe", message: "What do you want to rename it to?", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField) -> Void in
            textField.text = self.nameLabel?.text
        }
        alert.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: { (action) in
            self.nameLabel?.text = alert.textFields![0].text
            self.reference?.child("Recipes").child((self.recipe?.firebaseId)!).child("Name").setValue(self.nameLabel?.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func editRecipeIngredients(alertAction: UIAlertAction) -> Void {
        let alert = UIAlertController(title: "What ingredients would you like to change?", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let margin:CGFloat = 8.0
        print(alert.view.frame.size.width)
        let rect = CGRect(x: margin, y: margin+60.0,width: 254.0,height: 158.0)
        let customView = UITextView(frame: rect)
        customView.text = self.ingredientsList?.text
        customView.font = UIFont(name: "Helvetica", size: 12)
        alert.view.addSubview(customView)

        alert.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: { (action) in
            //actually change in database here:
            self.ingredientsList?.text = customView.text
            self.reference?.child("Recipes").child((self.recipe?.firebaseId)!).child("Ingredients").setValue(self.ingredientsList?.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func editRecipeDirections(alertAction: UIAlertAction) -> Void {
        let alert = UIAlertController(title: "What directions would you like to change?", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let margin:CGFloat = 8.0
        print(alert.view.frame.size.width)
        let rect = CGRect(x: margin, y: margin+60.0,width: 254.0,height: 158.0)
        let customView = UITextView(frame: rect)
        customView.text = self.directionsList?.text
        customView.font = UIFont(name: "Helvetica", size: 12)
        alert.view.addSubview(customView)
        
        alert.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: { (action) in
            //actually change in database here:
            self.directionsList.text = customView.text
            self.reference?.child("Recipes").child((self.recipe?.firebaseId)!).child("Directions").setValue(self.directionsList?.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func deleteRecipe(alertAction: UIAlertAction) -> Void {
        let alert = UIAlertController(title: "Are you sure?", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //Delete the recipe from Firebase
            //self.reference?.child("Users").child(currentUserID).child("MyRecipes")
            self.grabMyRecipesFromFirebase {
                var i: Int = 0
                for each in self.myRecipes! {
                    let x: String = each as! String
                    if x == self.recipe?.firebaseId {
                        print("found")
                        self.reference?.child("Users").child(self.currentUserID!).child("MyRecipes").child(String(i)).setValue("N/A")
                    } else {
                        i += 1
                    }
                }
                
            }
            let storageRef = self.storage.reference()
            self.reference?.child("Recipes").child((self.recipe?.firebaseId)!).removeValue()
            storageRef.child("Images").child((self.recipe?.firebaseId)!).delete { error in
                if let error = error{
                    print("Error:\(error)")
                } else {
                    //success
                }
            }
            //navController.popViewController(animated: true)
            //self.MyVc.loadMyRecipes()
            self.navigationController?.popViewController(animated: true)
            //self.performSegue(withIdentifier: "showMyRecipes", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        //Implement share
        let activity = UIActivityViewController(activityItems: [self.recipe?.image, self.recipe?.name, self.recipe?.ingredients, self.recipe?.directions], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        
        self.present(activity, animated: true, completion: nil)
    }
    
    func myFirebaseNetworkDataRequest(finished: @escaping () -> Void){ // the function thats going to take a little moment
        //this func grabs this data from the database and make sure that it waits for the fetch
        let userID = Auth.auth().currentUser?.uid
        reference?.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() && snapshot.hasChild("numOfLikedRecipes")
            {
                let value = snapshot.value as? NSDictionary
                let numRecipes: String = (value?["numOfLikedRecipes"] as? String)!
                self.userNumberOfLikedRecipes = Int(numRecipes)! + 1
            }
            else
            {
                self.userNumberOfLikedRecipes = 1
            }
            finished()
        })
        
    }
    
    func grabMyRecipesFromFirebase(finished: @escaping () -> Void){ // the function thats going to take a little moment
        reference?.child("Users").child(currentUserId!).observeSingleEvent(of: .value, with: {(UserRecipeSnap) in
            if UserRecipeSnap.exists(){
                if UserRecipeSnap.hasChild("MyRecipes") {
                    let Dict : NSDictionary = UserRecipeSnap.value as! NSDictionary
                    print("entered")
                    self.myRecipes = Dict["MyRecipes"] as? NSArray
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


