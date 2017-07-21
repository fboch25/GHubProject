//
//  Category.swift
//  GHub
//
//  Created by Frank Joseph Boccia on 7/20/17.
//  Copyright © 2017 Frank Joseph Boccia. All rights reserved.
//

import UIKit
import Firebase

class Category: NSObject {
    
    var name: String?
    var moreInfo: String?
    var image: UIImage?
    var id: String
    
    init(snapshot: DataSnapshot) {
        if let info = snapshot.value as? [String : Any] {
            name  = info["name"] as? String
            moreInfo = info["description"] as? String
         }
        id = snapshot.key
    }
    
}
