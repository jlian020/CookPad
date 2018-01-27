//
//  MyProfileView.swift
//  CookPad
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MyProfileView: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioView: UITextView!
    var loginButton = FBSDKLoginButton()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.image = UIImage(named: "a47")
        loginViewController().getFullName({
            (result)->Void in
            self.nameLabel.text = result
        })
        
        //load profile picture from facebook by using facebook ID
        loginViewController().getFacebookID({
            (result)->Void in
            //grab profile pic from Facebook ID
            var facebookProfileUrl = URL(string: "https://graph.facebook.com/\(result)/picture?width=2560&height=2560")
            if let data = try? Data(contentsOf: facebookProfileUrl!)
            {
                let profilePic: UIImage = UIImage(data: data)!
                print(profilePic.size)
                self.imageView.image = profilePic
                
            }
        })
        bioView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        loginButton.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 150) //logout button
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error == nil {
            print("Login Complete")
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
        self.performSegue(withIdentifier: "showLoginController", sender: self)
    }
}
