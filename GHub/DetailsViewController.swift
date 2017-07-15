//
//  DetailsViewController.swift
//  GHub
//
//  Created by Frank Joseph Boccia on 7/14/17.
//  Copyright © 2017 Frank Joseph Boccia. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class DetailsViewController: UIViewController {
    
    var object: Object?
    
    @IBOutlet weak var topImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let theImage = object?.image {
            topImageView.image = theImage
        }
        else if let imagePath = object?.imagePath {
            if let imageURL = URL(string: imagePath) {
                topImageView.sd_setImage(with: imageURL)
            }
        }
    }
}
