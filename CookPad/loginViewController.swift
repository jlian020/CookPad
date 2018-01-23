//
//  loginViewController.swift
//  CookPad
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class loginViewController : UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //super.viewDidAppear(true)
        
        self.loginButton.delegate = self
        
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.frame = CGRect(x: self.view.bounds.width/4, y: self.view.bounds.height-120, width: 200, height: 50)
        //loginButton.center = CGPointMake(self.view.bounds.width/2, self.view.bounds.height-50)
        //loginButton.delegate = self
        self.view.addSubview(loginButton)
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current() != nil) { //if the person is logged in, present the view controller
            print("Logged in")
            //print("ID is: \(self.getID())")
            //print("Email is: \(self.getEmail())")
            //self.getFirstName()
            
            //self.getEmail()
            self.loadViewController()
        }
        else {
            print("Not Logged in")
        }
    }
    
    func getEmail(_ completion:@escaping (_ result:String) -> Void) {
        let parameters = ["fields": "email"]
        var email : String = ""
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start {
        (connection, result, error) -> Void in
            if error != nil {
                print(error)
            }
            guard let data = result as? [String:Any] else {return}
            email = data["email"] as! String
            completion(email)
        }
    }
    
    //uses a completion handler to make sure it stores the name before continuing other actions
    func getFullName(_ completion:@escaping (_ result:String) -> Void) { //returns the name of the current logged profile
        let parameters = ["fields": "first_name, last_name"]
        var fullName : String = ""
        var firstName : String = ""
        var lastName : String = ""
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start {
            (connection, result, error) -> Void in
            if error != nil {
                print(error!)
            }
            guard let data = result as? [String:Any] else {return}
            firstName = data["first_name"] as! String
            lastName = data["last_name"] as! String
            fullName = "\(firstName) \(lastName)"
            completion(fullName)
        }
    }
    
    func getFacebookID(_ completion:@escaping (_ result:String) -> Void) {
        print("hi")
        let parameters = ["fields": "id"]
        var id : String!
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start {
            (connection, result, error) -> Void in
            if error != nil {
                print(error)
            }
            guard let data = result as? [String:Any] else {return}
            id = data["id"] as! String
            completion(id)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error == nil {
            print("Login Complete")
            self.loadViewController()
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loadViewController() -> Void {
        self.performSegue(withIdentifier: "showTabController", sender: self)
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
}
