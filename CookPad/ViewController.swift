//
//  ViewController.swift
//  CookPad
//

import UIKit
import CloudKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import Firebase


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refresh : UIRefreshControl!
    
    var recipes = [Recipe]() //array of recipes
    var reference: DatabaseReference?
    
    var recipeImage: UIImage?
    
    var recipePictureURL: URL?
    
    var recipeDoneSending: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.alwaysBounceVertical = true
        reference = Database.database().reference()
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load recipes")
        refresh.addTarget(self, action: #selector(ViewController.loadRecipes), for: .valueChanged)
        self.collectionView.addSubview(refresh) //adds a refresh action to the collectionView so we can update recipes
        
        navigationController!.navigationBar.barTintColor = UIColor(red: 197/255, green: 42/255, blue: 53/255, alpha: 0.1) //changes the navigation bar color to light blue, divide by 255 to convert RGB
        //Status Bar White Font
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        loadRecipes()
        
    }
    
    @objc func loadRecipes() -> Void {
        recipes.removeAll()
        self.collectionView.reloadData()
        self.refresh.endRefreshing()
        reference?.child("Recipes").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let firebaseSnap: NSArray = snapshot.children.allObjects as NSArray
                
                for child in firebaseSnap {
                    let snap = child as! DataSnapshot
                    if snap.value is NSDictionary {
                        let data: NSDictionary = snap.value as! NSDictionary
                        while data.count != 4 {
                            //wait if new recipe is being added
                        }
                        let tempRecipeName = data.value(forKey: "Name") as? String ?? ""
                        let tempRecipeURL = data.value(forKey: "storageURL") as? String ?? ""
                        let tempRecipeIngredients = data.value(forKey: "Ingredients") as? String ?? ""
                        let tempRecipeDirections = data.value(forKey: "Directions") as?  String ?? ""
                        self.recipePictureURL = URL(string: tempRecipeURL)
                        self.myFirebaseStorageImageGrab {
                            let newRecipe = Recipe.init(name: tempRecipeName, image: self.recipeImage!, ingredients: [tempRecipeIngredients], directions: [tempRecipeDirections] )
                            self.recipes.append(newRecipe)
                            DispatchQueue.main.async(execute: {
                                //push the current info into the main thread, otherwise for loop would be asynchronous
                                if self.recipeDoneSending == true {
                                    self.collectionView.reloadData() //add new recipe to collectionView
                                    //self.refresh.endRefreshing()
                                }
                            })
                        }
                    }
                }
            }
            else {
                print("Error: Snapshot does not exist")
            }
            
        })
        
        
    }
    
    func getRecipeArray() -> [Recipe] {
        return recipes
    }
    
    func myFirebaseStorageImageGrab(finished: @escaping () -> Void){ // the function thats going to take a little moment
        //this func grabs this data from the database and make sure that it waits for the fetch
        print(recipePictureURL)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //corrects auto layout, using 2 rows
        return CGSize(width: self.view.bounds.width/2, height: self.view.bounds.height/4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //required function for UICollectionView, counts how many cells are in the collection view
        return recipes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! recipeImageCell //searches for identifier labeled "cell" from storyboard
        cell.nameLabel?.text = recipes[indexPath.row].name
        cell.imageView?.image = recipes[indexPath.row].image
        return cell
    } //reuses cell for all cells in UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipe" { //show the recipe that the user selected
            let backButton = UIBarButtonItem()
            backButton.title = "" //want an empty title, rather than app name near back button
            navigationItem.backBarButtonItem = backButton //recreates bar button with empty title
            let indexPaths = self.collectionView!.indexPathsForSelectedItems! //get the number of selected items in our collectionView
            let indexPath = indexPaths[0] as IndexPath //start at first i
            
            let recipeVC = segue.destination as! recipeViewController
            
            //set the profile view up
            let recipe = recipes[indexPath.row]
            
            recipeVC.name = recipe.name
            recipeVC.image = recipe.image
            recipeVC.ingredients = recipe.ingredients.first!
            recipeVC.directions = recipe.directions.first!
            
            //vc.title = self.recipes[indexPath.row]
        }
        
        if segue.identifier == "addRecipe" {
            let backButton = UIBarButtonItem()
            backButton.title = ""
            navigationItem.backBarButtonItem = backButton
        }
        
        if segue.identifier == "searchRecipe" {
            let backButton = UIBarButtonItem()
            backButton.title = ""
            navigationItem.backBarButtonItem = backButton
            let searchVC = segue.destination as! SearchRecipeViewController
            
            //set the profile view up
            searchVC.recipes = self.recipes
            print(searchVC.recipes.count)
        }
    }
    
    
}

