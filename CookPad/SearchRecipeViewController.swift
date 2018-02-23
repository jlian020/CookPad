//
//  SearchRecipeViewController.swift
//  CookPad
//

import UIKit
import CloudKit
import Firebase
import FirebaseStorage

class SearchRecipeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refresh : UIRefreshControl!
    var searchActive : Bool = false
    var filteredRecipes:[Recipe] = []
    var profileRecords = [CKRecord]()
    var recipes = [Recipe]() //array of recipes
    var reference: DatabaseReference!
    let storage = Storage.storage() //get reference to Google Firebase Storage
    var myRecipeIDS = [String]()
    var postRecipe = [String: AnyObject]()
    var myRecipeDict : NSArray?
    var currentUserID = Auth.auth().currentUser?.uid
    var recipePictureURL : URL?
    var recipeImage : UIImage?
    var recipeDoneSending: Bool = true
    let vc = ViewController(nibName: "ViewController", bundle: nil)
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.alwaysBounceVertical = true
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Recipes"
        searchController.searchBar.sizeToFit()
        
        searchController.searchBar.becomeFirstResponder()
        
        self.navigationItem.titleView = searchController.searchBar
        
        reference = Database.database().reference()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load recipes")
        refresh.addTarget(self, action: #selector(myRecipeViewController.loadMyRecipes), for: .valueChanged)
        
        self.collectionView.addSubview(refresh) //adds a refresh action to the collectionView so we can update profiles
        
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 197/255, green: 42/255, blue: 53/255, alpha: 0.1) //changes the navigation bar color to light blue, divide by 255 to convert RGB
        //Status Bar White Font
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        print("Filtered Recipe count: \(recipes.count)")
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        if let searchString = searchController.searchBar.text {
            filterRecipes(for: searchString)
            collectionView.reloadData()
        }
        
        //print("Filtered Recipe count: \(recipes.count)")
    }
    
    func filterRecipes(for searchText: String) {
        filteredRecipes = recipes.filter({ (recipe: Recipe) -> Bool in
            let name = recipe.name
            let ingredients = recipe.ingredients
            let directions = recipe.directions
            
            if let searchText = self.searchController.searchBar.text?.lowercased() {
                return (name.lowercased().contains(searchText) ||
                    ingredients.lowercased().contains(searchText) ||
                    directions.lowercased().contains(searchText))
            }
            else {
                return false
            }
        })
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //corrects auto layout, using 2 rows
        return CGSize(width: self.view.bounds.width/2, height: self.view.bounds.height/4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //required function for UICollectionView, counts how many cells are in the collection view
        return filteredRecipes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! recipeImageCell //searches for identifier labeled "cell" from storyboard
        cell.nameLabel?.text = filteredRecipes[indexPath.row].name
        cell.imageView?.image = filteredRecipes[indexPath.row].image
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
            let recipe = filteredRecipes[indexPath.row]
            recipeVC.recipe = recipe
            
            //vc.title = self.recipes[indexPath.row]
        }
    }
    
    
}




