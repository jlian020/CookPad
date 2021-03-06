//
//  addRecipeViewController.swift
//  CookPad
//
//  Created by Justin Mac on 1/25/18.
//  Copyright © 2018 Justin Mac. All rights reserved.
//
import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import JGProgressHUD


class addRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var recipeTitleTextField: UITextField!
    @IBOutlet weak var recipeDescriptionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var recipeImage: UIImage!
    @IBOutlet weak var methodTextView: UITextView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    var methodPlaceholderLabel: UILabel!
    var ingredientsPlaceholderLabel: UILabel!
    var reference: DatabaseReference?
    let storage = Storage.storage() //get reference to Google Firebase Storage
    var userNumberOfRecipes: Int! = 0
    let vc = ViewController(nibName: "ViewController", bundle: nil)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        reference = Database.database().reference()
        recipeTitleTextField.delegate = self
        ingredientsTextView.delegate = self
        methodTextView.delegate = self
        
        ingredientsTextView.tag = 0
        methodTextView.tag = 1
        
        ingredientsPlaceholderLabel = UILabel()
        ingredientsPlaceholderLabel.text = "List ingredients here..."
        ingredientsPlaceholderLabel.font = UIFont.italicSystemFont(ofSize: (ingredientsTextView.font?.pointSize)!)
        ingredientsPlaceholderLabel.sizeToFit()
        ingredientsTextView.addSubview(ingredientsPlaceholderLabel)
        ingredientsPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (ingredientsTextView.font?.pointSize)! / 2)
        ingredientsPlaceholderLabel.textColor = UIColor.lightGray
        ingredientsPlaceholderLabel.isHidden = !ingredientsTextView.text.isEmpty
        
        methodPlaceholderLabel = UILabel()
        methodPlaceholderLabel.text = "Step-by-step instructions here..."
        methodPlaceholderLabel.font = UIFont.italicSystemFont(ofSize: (methodTextView.font?.pointSize)!)
        methodPlaceholderLabel.sizeToFit()
        methodTextView.addSubview(methodPlaceholderLabel)
        methodPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (methodTextView.font?.pointSize)! / 2)
        methodPlaceholderLabel.textColor = UIColor.lightGray
        methodPlaceholderLabel.isHidden = !methodTextView.text.isEmpty
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool { //when the user presses the return key, hide the keyboard
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func selectImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            recipeImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            recipeImage = possibleImage
        } else {
            return
        }
        
        imageView.image = recipeImage
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func submitRecipeTapped(_ sender: Any)
    {
        vc.recipeDoneSending = false
        if recipeTitleTextField.text?.isEmpty ?? true || ingredientsTextView.text?.isEmpty ?? true ||
            methodTextView.text?.isEmpty ?? true
        {
            var errorMsgString = "You still need to complete the following fields before submitting: "
            
            if recipeTitleTextField.text?.isEmpty ?? true
            {
                errorMsgString += "\n-Title"
            }
            if ingredientsTextView.text?.isEmpty ?? true
            {
                errorMsgString += "\n-Ingredients"
            }
            if methodTextView.text?.isEmpty ?? true
            {
                errorMsgString += "\n-Method"
            }
            
            let alert = UIAlertController(title: "Whoa, slow down chef!", message: errorMsgString, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK",style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            //Add recipe to database here:
            submitRecipeToDatabase()
            
            //Submit the recipe to the database and append the user id to the recipe created
            //self.view.makeToast("Submitted Recipe")
            vc.recipes.removeAll()
            
            var progress = JGProgressHUD(style: .dark)
            progress.textLabel.text = "Uploading Recipe"
            progress.show(in: self.view, animated: true)
            let delay = DispatchTime.now() + 3 // wait 3 seconds to display uploading recipe message
            DispatchQueue.main.asyncAfter(deadline: delay) {
                progress.indicatorView = JGProgressHUDSuccessIndicatorView.init() //display upload recipe success
                progress.dismiss(afterDelay: 2.0)
                let delay = DispatchTime.now() + 1 //wait a second to segue home
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.performSegue(withIdentifier: "showHome", sender: self)
                }
            }
        }
    }
    
    func submitRecipeToDatabase() {
        let recipeID =  reference?.child("Recipes").childByAutoId()
        let currentUserID = Auth.auth().currentUser?.uid
        recipeID?.child("Name").setValue(recipeTitleTextField.text)
        recipeID?.child("Directions").setValue(methodTextView.text)
        recipeID?.child("Ingredients").setValue(ingredientsTextView.text)
        myFirebaseNetworkDataRequest {
            //stuff that is down after the fetch from the database
            self.reference?.child("Users").child(currentUserID!).child("MyRecipes").child("\(self.userNumberOfRecipes! - 1)").setValue(recipeID!.key)
            self.reference?.child("Users").child((Auth.auth().currentUser?.uid)!).child("numOfRecipes").setValue("\(self.userNumberOfRecipes!)")
            self.addToStorage(ID: (recipeID)!)
        }
    }
    
    func myFirebaseNetworkDataRequest(finished: @escaping () -> Void){ // the function thats going to take a little moment
        //this func grabs this data from the database and make sure that it waits for the fetch
        let userID = Auth.auth().currentUser?.uid
        reference?.child("Users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() && snapshot.hasChild("numOfRecipes") {
                let value = snapshot.value as? NSDictionary
                let numRecipes: String = (value?["numOfRecipes"] as? String)!
                self.userNumberOfRecipes = Int(numRecipes)! + 1
            }
            else{
                self.userNumberOfRecipes = 1
            }
            finished()
        })
    }
    
    
    @objc func addToStorage(ID: DatabaseReference) -> Void {
        let storageRef = storage.reference() //create storage reference from Firebase Storage
        //dismiss(animated: true, completion: nil)
        var data = Data()
        data = UIImageJPEGRepresentation(imageView.image!, 0.8)!
        // set upload path
        let filePath = "\("Images")/\(ID.key)"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!.absoluteString
                //store downloadURL at database
                self.reference?.child("Recipes").child(ID.key).updateChildValues(["storageURL": downloadURL])
                self.vc.recipeDoneSending = true
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        if (textView.tag == 0)
        {
            ingredientsPlaceholderLabel.isHidden = !textView.text.isEmpty
        }
        else if (textView.tag == 1)
        {
            methodPlaceholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
