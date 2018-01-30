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

class addRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var recipeTitleTextField: UITextField!
    @IBOutlet weak var recipeDescriptionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var recipeImage: UIImage!
    @IBOutlet weak var methodTextView: UITextView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        reference = Database.database().reference()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func selectImageButton(_ sender: Any)
    {
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
        if recipeTitleTextField.text?.isEmpty ?? true || ingredientsTextView.text?.isEmpty ?? true ||
            methodTextView.text?.isEmpty ?? true
        {
            var errorMsgString = "You are missing the following required fields: "
            
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
            
            let alert = UIAlertController(title: "Missing Required Fields!", message: errorMsgString, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK",style: UIAlertActionStyle.default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            //TODO: Add recipe to database here:
            
            //Submit the recipe to the database and append the user id to the recipe created
            self.view.makeToast("Submitted Recipe")
            let delay = DispatchTime.now() + 1 // wait a second to display submitted recipe message, then perform segue
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.performSegue(withIdentifier: "showHome", sender: self) }
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
