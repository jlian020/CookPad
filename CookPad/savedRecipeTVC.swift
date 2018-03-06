//
//  savedRecipeTVC.swift
//  CookPad
//
//  Created by David Liang on 2/5/18.
//  Copyright © 2018 Justin Mac. All rights reserved.
//

import UIKit
import CloudKit
import Firebase

class savedRecipeCell: UITableViewCell {
        
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
}

class savedRecipeTVC: UITableViewController {
    
    var refresh : UIRefreshControl!
    var reference: DatabaseReference?
    let currentUserId = Auth.auth().currentUser?.uid
    var profileRecords = [CKRecord]()
    var savedRecipes = [Recipe]() //array of recipes
    var tempSavedRecipes = [Recipe]() //array of recipes
    var recipeImage : UIImage?
    var recipePictureURL : URL?
    var myLikedRecipeDict : NSArray?
    
    let vc = ViewController(nibName: "ViewController", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reference = Database.database().reference()
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load recipes")
        refresh.addTarget(self, action: #selector(savedRecipeTVC.loadSavedRecipes), for: .valueChanged)
        //        self.collectionView.addSubview(refresh) //adds a refresh action to the collectionView so we can update profiles
        self.tableView.addSubview(refresh)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 197/255, green: 42/255, blue: 53/255, alpha: 0.1) //changes the navigation bar color to light blue, divide by 255 to convert RGB
        //Status Bar White Font
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        loadSavedRecipes()
    }
    
    @objc func loadSavedRecipes() -> Void {
        tempSavedRecipes.removeAll()
        if refresh.isRefreshing {
            refresh.endRefreshing()
        }
        grabLikedRecipesFromFirebase {
            print(self.myLikedRecipeDict!)
            if self.myLikedRecipeDict!.count > 0 {
                self.grabRecipes {
                }

            }

        }
    }
    
    func grabRecipes(finished: @escaping () -> Void) { // the function thats going to take a little moment
        for each in self.myLikedRecipeDict!{
            let x: String = each as! String
            self.reference?.child("Recipes").child(x).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let value = snapshot.value as? NSDictionary
                    while snapshot.childrenCount != 4 {}
                    let tempRecipeName = value?["Name"] as? String ?? ""
                    let tempRecipeIngredients = value?["Ingredients"] as? String ?? ""
                    let tempRecipeDirections = value?["Directions"] as? String ?? ""
                    var tempRecipeURL = value?["storageURL"] as? String ?? ""
                    while(tempRecipeURL == "") {
                        tempRecipeURL = value?["storageURL"] as? String ?? ""
                    }
                    
                    self.recipePictureURL = URL(string: tempRecipeURL)
                    self.myFirebaseStorageImageGrab {
                        let newRecipe = Recipe.init(name: tempRecipeName, image: self.recipeImage!, ingredients: tempRecipeIngredients, directions: tempRecipeDirections, id: x)
                        self.tempSavedRecipes.append(newRecipe)
                        self.savedRecipes = self.tempSavedRecipes
                        DispatchQueue.main.async(execute: {
                            //push the current info into the main thread, otherwise for loop would be asynchronous
                            if self.vc.recipeDoneSending == true {
                                self.tableView.reloadData() //add new recipe to collectionView
                                //self.refresh.endRefreshing()
                            }
                        })
                    }
                    finished()
                }
                else {
                    print("Error: Snapshot doesnt exist")
                }
            })
        }
    }
    
    func grabLikedRecipesFromFirebase(finished: @escaping () -> Void){ // the function thats going to take a little moment
        reference?.child("Users").child(currentUserId!).observeSingleEvent(of: .value, with: {(UserRecipeSnap) in
            if UserRecipeSnap.exists(){
                if UserRecipeSnap.hasChild("LikedRecipes") {
                    let Dict : NSDictionary = UserRecipeSnap.value as! NSDictionary
                    print("entered")
                    self.myLikedRecipeDict = Dict["LikedRecipes"] as? NSArray
                    finished()
                }
                else {
                    print("MyRecipes DOES NOT EXIST")
                }
            }
            else {
                print("Error with retrieving snapshot from Firebase")
            }
            
        })
    }
    
    
    func myFirebaseStorageImageGrab(finished: @escaping () -> Void){ // the function thats going to take a little moment
        //this func grabs this data from the database and make sure that it waits for the fetch
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: recipePictureURL!) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading recipe picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded recipe picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        self.recipeImage = UIImage(data: imageData)!
                        finished()
                        // Do something with your image.
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! savedRecipeCell
        
        cell.recipeLabel?.text = savedRecipes[indexPath.row].name
        cell.recipeImage?.image = savedRecipes[indexPath.row].image

        cell.star1?.image = UIImage(named: "star2")
        cell.star2?.image = UIImage(named: "star2")
        cell.star3?.image = UIImage(named: "star2")
        cell.star4?.image = UIImage(named: "star2")
        cell.star5?.image = UIImage(named: "star")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipe" { //show the recipe that the user selected
            let backButton = UIBarButtonItem()
            backButton.title = "" //want an empty title, rather than app name near back button
            navigationItem.backBarButtonItem = backButton //recreates bar button with empty title
            //            let indexPaths = self.collectionView!.indexPathsForSelectedItems! //get the number of selected items in our collectionView
            let indexPaths = self.tableView!.indexPathsForSelectedRows!
            let indexPath = indexPaths[0] as IndexPath //start at first i
            
            let recipeVC = segue.destination as! recipeViewController
            
            //set the profile view up
            let recipe = savedRecipes[indexPath.row]
            recipeVC.recipe = recipe
            
        }
    }
    
    
}
