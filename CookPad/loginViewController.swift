//
//  loginViewController.swift
//  CookPad
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import GoogleSignIn

class loginViewController : UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
    let FBLoginButton = FBSDKLoginButton()
    let GoogleLoginButton = GIDSignInButton()
    
    var reference: DatabaseReference?
    var videoPlayer: AVPlayer!
    var videoLayer: AVPlayerLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        //super.viewDidAppear(true)
        
        reference = Database.database().reference()
        
        
        
        //Setup view
        let URL = Bundle.main.url(forResource: "food", withExtension: "mp4")
        videoPlayer = AVPlayer.init(url: URL!)
        videoLayer = AVPlayerLayer(player: videoPlayer)
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoLayer.frame = view.layer.frame
        
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        videoPlayer.isMuted = true
        
        videoPlayer.play()
        
        
        view.layer.insertSublayer(videoLayer, at: 0)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.videoPlayer.currentItem, queue: .main) { _ in
            self.videoPlayer?.seek(to: kCMTimeZero)
            self.videoPlayer?.play()
        }
        
        //Setup Facebook Login and Authentication
        self.FBLoginButton.delegate = self
        
        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        FBLoginButton.frame = CGRect(x: self.view.bounds.width/4, y: self.view.bounds.height-150, width: 200, height: 50)
        FBLoginButton.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-150)
        //FBLoginButton.center = CGPointMake(self.view.bounds.width/2, self.view.bounds.height-50)
        //FBLoginButton.delegate = self
        self.view.addSubview(FBLoginButton)
        
        //Setup Google Login and Authentication
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        GoogleLoginButton.frame = CGRect(x: self.view.bounds.width/4, y: self.view.bounds.height-90, width: 208.5, height: 80)
        GoogleLoginButton.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-90)
        //GoogleLoginButton.colorScheme = GIDSignInButtonColorScheme.light
        self.view.addSubview(GoogleLoginButton)
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()){
            print("Logged into Google")
            self.loadViewController()
        }
    }
 
    func getFacebookID(_ completion:@escaping (_ result:String) -> Void) {
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
    
    func loginButton(_ LoginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        if error == nil {
            if result.isCancelled { return }
            print("FB Login Complete")
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("Facebook Login Error")
                    let alertController = UIAlertController(title: "Login Error!", message: "Try Again!", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Try Again!", style : .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                //user is signed in
                self.videoPlayer.pause()
                self.reference?.child("Users").child(user!.uid)
                let currentUser = Auth.auth().currentUser?.displayName
                self.reference?.child("Users").child(user!.uid).child("Name").setValue(currentUser)
                self.loadViewController()
            }
        }
        else {
            print("Facebook Login Error")
        }
    }
    
    func loadViewController() -> Void {
        self.performSegue(withIdentifier: "showTabController", sender: self)
    }
    
    
    func loginButtonDidLogOut(_ LoginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
}
