//
//  CategoryTableView.swift
//  GHub
//
//  Created by Frank Joseph Boccia on 7/19/17.
//  Copyright © 2017 Frank Joseph Boccia. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CategoryTableView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet weak var menuTableView: UITableView!
    var ref: DatabaseReference!
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableViewCleanUp()
        ref = Database.database().reference()
        loadData()
    }
    
    func categoryTableViewCleanUp() {
        menuTableView?.delegate = self
        menuTableView?.dataSource = self
    }
    
    func loadData() {
        ref.child("Categories").observeSingleEvent(of: .value, with: { (snapshot) in
            self.categories.removeAll()
            snapshot.children.forEach({ (child) in
                if let obj = child as? DataSnapshot {
                    let category = Category(snapshot: obj)
                    self.categories.append(category)
                }
            })
            self.menuTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        cell.categoryLabel.text = category.name
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.row]
        
        if let chatRoomVC = storyboard?.instantiateViewController(withIdentifier: "chatRoom")  as? ChatRoom {
            chatRoomVC.category = selectedCategory
            self.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }
    // MARK: Log Out
    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("user signedout")
            
            if Auth.auth().currentUser == nil {
                print("Logged out, no user now, key removed")
                UserDefaults.standard.removeObject(forKey: "loggedIn")
                UserDefaults.standard.synchronize()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
    }
}
