//
//  MyProfileView.swift
//  CookPad
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn

class MyProfileView: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioView: UITextView!
    var FacebookLogoutButton = FBSDKLoginButton()
    
    @IBOutlet weak var googleLogout: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = Auth.auth().currentUser?.displayName
        
        bioView.text = "         Tell the world about yourself here!"
        FacebookLogoutButton.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height - 150) //logout button
        FacebookLogoutButton.delegate = self
        
        //Check whether user logged in through Facebook or Google to show correct logout button
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    googleLogout.isHidden = true
                    self.view.addSubview(FacebookLogoutButton)
                    //load profile picture from facebook by using facebook ID
                    loginViewController().getFacebookID({
                        (result)->Void in
                        //grab profile pic from Facebook ID
                        var facebookProfileUrl = URL(string: "https://graph.facebook.com/\(result)/picture?width=2560&height=2560")
                        if let data = try? Data(contentsOf: facebookProfileUrl!)
                        {
                            let profilePic: UIImage = UIImage(data: data)!
                            self.imageView.image = profilePic
                            
                        }
                    })
                    
                case "google.com":
                    FacebookLogoutButton.isHidden = true
                    //Grab URL from Google for Profile Pic
                    var profileURL = Auth.auth().currentUser?.photoURL?.absoluteString
                    profileURL = profileURL?.replacingOccurrences(of: "s96-c/photo.jpg", with: "s800-c/photo.jpg")
                    let newProfileURL = URL(string: profileURL!)
                    
                    if let data = try? Data(contentsOf: newProfileURL!)
                    {
                        let profilePic: UIImage = UIImage(data: data)!
                        self.imageView.image = profilePic
                    }
                default:
                    print("user is signed in with \(userInfo.providerID)")
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error == nil {
            print("MyProfileView Login Button")
        }
        else {
            print("Facebook Login Button Error")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
        FBSDKLoginManager().logOut()
        self.performSegue(withIdentifier: "showLoginController", sender: self)
    }
    
    @IBAction func GoogleLogoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        GIDSignIn.sharedInstance().signOut()
        self.performSegue(withIdentifier: "showLoginController", sender: self)
    }
    
}
