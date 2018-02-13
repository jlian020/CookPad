//
//  savedRecipeTVC.swift
//  CookPad
//
//  Created by David Liang on 2/5/18.
//  Copyright © 2018 Justin Mac. All rights reserved.
//

import UIKit
import CloudKit
import FirebaseStorage

class savedRecipeCell: UITableViewCell {
        
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeLabel: UILabel!

}

class savedRecipeTVC: UITableViewController {
    
    var refresh : UIRefreshControl!
    
    var profileRecords = [CKRecord]()
    var savedRecipes = [Recipe]() //array of recipes
    
    let storage = Storage.storage() //get reference to Google Firebase Storage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let storageRef = storage.reference() //create storage reference from Firebase Storage
        for index in 1...5 {
            let imageRef = storageRef.child("Images/a\(index).JPG")
            imageRef.getData(maxSize: 4*1024*1024, completion: { (data, error) in
                if let error = error {
                    //print(error)
                    self.view.makeToast("Error: \(error)")
                } else {
                    print("image is being populated")
                    var newRecipe = Recipe.init(name: "test", image: UIImage(data: data!)!, ingredients: ["Stuff"], directions: ["Do Stuff"]);
                    self.savedRecipes.append(newRecipe)
                    DispatchQueue.main.async(execute: {
                        //push the current info into the main thread, otherwise for loop would be asynchronous
                        // self.collectionView.reloadData() //add new recipe to collectionView
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

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRecipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! savedRecipeCell
        
        cell.recipeLabel?.text = savedRecipes[indexPath.row].name
        cell.recipeImage?.image = savedRecipes[indexPath.row].image
        
        return cell
    }

}
