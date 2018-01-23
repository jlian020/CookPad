//
//  ViewController.swift
//  CookPad
//

import UIKit
import CloudKit
import FirebaseStorage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var refresh : UIRefreshControl!
    
    
    var profileRecords = [CKRecord]()
    var recipes = [Recipe]() //array of recipes
    
    let storage = Storage.storage() //get reference to Google Firebase Storage
    
    var testImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load profiles")
        refresh.addTarget(self, action: #selector(ViewController.loadRecipes), for: .valueChanged)
        self.collectionView.addSubview(refresh) //adds a refresh action to the collectionView so we can update profiles
        
        
        navigationController!.navigationBar.barTintColor = UIColor(red: 197/255, green: 42/255, blue: 53/255, alpha: 0.1) //changes the navigation bar color to light blue, divide by 255 to convert RGB
        //Status Bar White Font
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        loadRecipes()
        
    }
    
    @objc func loadRecipes() -> Void { //parameter: index
        //populate Profile name, images, bios, age
        /*profileRecords = [CKRecord]()
        let publicData = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "Person", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        //sort query here later
        
        publicData.perform(query, inZoneWith: nil, completionHandler: { results,error -> Void in //perform a database query to cloud kit to load
            if let profiles = results {
                self.profileRecords = profiles //load them one at a time
                DispatchQueue.main.async(execute: { //push the current info into the main thread
                    self.collectionView.reloadData()
                    //self.refresh.endRefreshing()
                })
            }
            else {
                print("error in populating profiles")
                print(error)
            }
        })*/
        
        var name: String = "Default"
        var email: String = "Default"
        var ID : String = ""
        loginViewController().getFullName({
            (result)->Void in
            name = result
            print("Name is: \(name)")
        })
        loginViewController().getEmail({
            (result)->Void in
            email = result
            print("Email is: \(email)")
        })
        loginViewController().getFacebookID({
            (result)->Void in
            ID = result
            print("ID is: \(ID)")
        })
        
        let storageRef = storage.reference() //create storage reference from Firebase Storage
        let imageRef = storageRef.child("Images/IMG_0005.JPG")
        imageRef.getData(maxSize: 4*1024*1024, completion: { (data, error) in
            if let error = error {
                print(error)
            } else {
                print("test image is now populated")
                self.testImage = UIImage(data: data!)!
                DispatchQueue.main.async(execute: { //push the current info into the main thread
                    self.collectionView.reloadData()
                    //self.refresh.endRefreshing()
                })
            }
            })
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { //corrects auto layout, using 2 rows
        return CGSize(width: self.view.bounds.width/2, height: self.view.bounds.height/4)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { //required function for UICollectionView
         //return profileRecords.count //limit a specific profile amount
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! recipeImageCell //searches for identifier labeled "cell" from storyboard
        /*let profile = profileRecords[indexPath.row]
        if let profileName = profile["Name"] as? String {
            cell.nameLabel?.text = profileName //automatically increments the indexPath like ++i
        }
        if let profileImage = profile["Image"] as? CKAsset,
            let data = try? Data(contentsOf: profileImage.fileURL),
            let image = UIImage(data: data) { //cannot directly convert Asset to UIImage
            cell.imageView?.image = image//populate the imageViews from the collectionView cells with the profileImages in database
        }*/
        cell.nameLabel?.text = "Hi testing"
        cell.imageView?.image = testImage
        return cell
    } //reuses cell for all cells in UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showRecipe", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipe" {
            let backButton = UIBarButtonItem()
            backButton.title = "" //want an empty title, rather than app name near back button
            navigationItem.backBarButtonItem = backButton //recreates bar button with empty title
            let indexPaths = self.collectionView!.indexPathsForSelectedItems! //get the number of selected items in our collectionView
            let indexPath = indexPaths[0] as IndexPath //start at first i
            
            let vc = segue.destination as! recipeViewController
            /*
            //set the profile view up
            let recipe = recipes[indexPath.row]
            if let profileImage = recipe["Image"] as? CKAsset, //find the profile Image for the profileView
                let data = try? Data(contentsOf: profileImage.fileURL),
                let image = UIImage(data: data) { //cannot directly convert Asset to UIImage
                vc.image = image
            }
            if let profileName = profile["Name"] as? String {
                vc.name = profileName
            }
            if let profileBio = profile["Bio"] as? String {
                vc.bio = profileBio
            }*/
            //print(profileNames[indexPath.row])
            //vc.title = self.profileNames[indexPath.row]
        }
    }

}

