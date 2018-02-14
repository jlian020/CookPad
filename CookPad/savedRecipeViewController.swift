//
//  ViewController.swift
//  CookPad
//
import UIKit
import CloudKit
import FirebaseStorage

class savedRecipeCell: UITableViewCell {

    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!
}

class savedRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var refresh : UIRefreshControl!
    
    
    var profileRecords = [CKRecord]()
    var savedRecipes = [Recipe]() //array of recipes
    
    let storage = Storage.storage() //get reference to Google Firebase Storage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load recipes")
        refresh.addTarget(self, action: #selector(savedRecipeViewController.loadSavedRecipes), for: .valueChanged)
//        self.collectionView.addSubview(refresh) //adds a refresh action to the collectionView so we can update profiles
        self.tableView.addSubview(refresh)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 197/255, green: 42/255, blue: 53/255, alpha: 0.1) //changes the navigation bar color to light blue, divide by 255 to convert RGB
        //Status Bar White Font
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        loadSavedRecipes()
        
    }
    
    @objc func loadSavedRecipes() -> Void {
        
        let storageRef = storage.reference() //create storage reference from Firebase Storage
        for index in 1...5 {
            let imageRef = storageRef.child("Images/a\(index).JPG")
            imageRef.getData(maxSize: 2*1024*1024, completion: { (data, error) in
                if let error = error {
                    self.view.makeToast("Error: \(error)")
                } else {
                    var newRecipe = Recipe.init(name: "test", image: UIImage(data: data!)!, ingredients: ["Stuff"], directions: ["Do Stuff"]);
                    self.savedRecipes.append(newRecipe)
                    DispatchQueue.main.async(execute: {
                        //push the current info into the main thread, otherwise for loop would be asynchronous
//                        self.collectionView.reloadData() //add new recipe to collectionView
                        self.tableView.reloadData()
                        //self.refresh.endRefreshing()
                    })
                }
            })
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //required function for UICollectionView, counts how many cells are in the collection view
//        return savedRecipes.count
//    }
//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRecipes.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! recipeImageCell //searches for identifier labeled "cell" from storyboard
//        cell.nameLabel?.text = savedRecipes[indexPath.row].name
//        cell.imageView?.image = savedRecipes[indexPath.row].image
//        return cell
//    } //reuses cell for all cells in UICollectionView

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! savedRecipeCell
        
        cell.recipeLabel?.text = savedRecipes[indexPath.row].name
        cell.recipeImage?.image = savedRecipes[indexPath.row].image
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "showRecipe", sender: self)
//
//    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showRecipe" { //show the recipe that the user selected
//            let backButton = UIBarButtonItem()
//            backButton.title = "" //want an empty title, rather than app name near back button
//            navigationItem.backBarButtonItem = backButton //recreates bar button with empty title
//            let indexPaths = self.collectionView!.indexPathsForSelectedItems! //get the number of selected items in our collectionView
//            let indexPath = indexPaths[0] as IndexPath //start at first i
//
//            let recipeVC = segue.destination as! recipeViewController
//
//            //set the profile view up
//            let recipe = savedRecipes[indexPath.row]
//
//            recipeVC.name = recipe.name
//            recipeVC.image = recipe.image
//            recipeVC.ingredients = recipe.ingredients.first!
//
//            //vc.title = self.recipes[indexPath.row]
//        }
//    }
//
    
}

