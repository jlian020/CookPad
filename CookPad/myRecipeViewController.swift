//
//  myRecipeViewController.swift
//  CookPad
//

import UIKit
import CloudKit
import FirebaseStorage

class myRecipeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refresh : UIRefreshControl!
    
    
    var profileRecords = [CKRecord]()
    var myRecipes = [Recipe]() //array of recipes
    
    let storage = Storage.storage() //get reference to Google Firebase Storage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load recipes")
        refresh.addTarget(self, action: #selector(ViewController.loadRecipes), for: .valueChanged)
        self.collectionView.addSubview(refresh) //adds a refresh action to the collectionView so we can update profiles
        
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 197/255, green: 42/255, blue: 53/255, alpha: 0.1) //changes the navigation bar color to light blue, divide by 255 to convert RGB
        //Status Bar White Font
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        loadMyRecipes()
        
    }
    
    @objc func loadMyRecipes() -> Void {
        
        let storageRef = storage.reference() //create storage reference from Firebase Storage
        for index in 1...3 {
            let imageRef = storageRef.child("Images/a\(index).JPG")
            imageRef.getData(maxSize: 4*1024*1024, completion: { (data, error) in
                if let error = error {
                    print("couldn't find image")
                    //print(error)
                } else {
                    print("image is being populated")
                    var newRecipe = Recipe.init(name: "test", image: UIImage(data: data!)!, ingredients: ["Stuff"], directions: ["Do Stuff"]);
                    self.myRecipes.append(newRecipe)
                    DispatchQueue.main.async(execute: {
                        //push the current info into the main thread, otherwise for loop would be asynchronous
                        self.collectionView.reloadData() //add new recipe to collectionView
                        //self.refresh.endRefreshing()
                    })
                }
            })
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //corrects auto layout, using 2 rows
        return CGSize(width: self.view.bounds.width/2, height: self.view.bounds.height/4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //required function for UICollectionView, counts how many cells are in the collection view
        return myRecipes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! recipeImageCell //searches for identifier labeled "cell" from storyboard
        cell.nameLabel?.text = myRecipes[indexPath.row].name
        cell.imageView?.image = myRecipes[indexPath.row].image
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
            let recipe = myRecipes[indexPath.row]
            
            recipeVC.name = recipe.name
            recipeVC.image = recipe.image
            recipeVC.ingredients = recipe.ingredients.first!
            
            //vc.title = self.recipes[indexPath.row]
        }
    }
    
    
}



