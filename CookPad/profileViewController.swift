//
//  profileViewController.swift
//  CookPad
//
//  Created by Justin Mac on 1/8/18.
//  Copyright © 2016 Justin Mac. All rights reserved.
//

import UIKit

class profileViewController: UIViewController {
    @IBOutlet weak var imageView = UIImageView()
    @IBOutlet weak var nameLabel = UILabel()
    @IBOutlet weak var bioView = UITextView()
    @IBOutlet weak var overlayImageView = UIImageView()
    
    var image = UIImage()
    var name = String()
    var bio = String()
    let likeOverlay = UIImage(named: "like button")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView?.image = self.image
        self.nameLabel?.text = self.name
        self.bioView?.text = self.bio
        //overlayImageView?.hidden = true
        //if(personA likes personB) { overlayImageView?.image = likeOverlay }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func likeButtonPressed(_ sender: AnyObject) {
        print("like Button pressed")
        //stamp like, hide buttons
        overlayImageView?.isHidden = false
        overlayImageView?.image = likeOverlay
        //add Person to crush list
    }
    @IBAction func dislikeButtonPressed(_ sender: AnyObject) {
        print("Dislike button pressed")
        if(overlayImageView?.image == likeOverlay) {
            overlayImageView?.isHidden = true
        }
        //if (personA likes personB) remove Person from crush list //accidentally liked them
    }
}
