//
//  DetailsViewController.swift
//  GHub
//
//  Created by Frank Joseph Boccia on 7/14/17.
//  Copyright © 2017 Frank Joseph Boccia. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

    struct Message {
        var author: String
        var comment: String!
    }

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var object: Object?
    var objects: [Object] = []
    //var message: Message?
    var messages: [Message] = []
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var chatTableViewController: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    // Instance of cell
    var tableChatCell: TableChatCell!
    var ref = DatabaseReference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImageFromChatRoom()
        tableViewDataLoad()
        cleanUp()
        loadData()
        
    }
    func cleanUp(){
        hideKeyboardWhenTappedAround()
        self.chatTableViewController.rowHeight = UITableViewAutomaticDimension
        self.chatTableViewController.estimatedRowHeight = 100
    }
    
    func loadData() {
        ref.child("Comments").observeSingleEvent(of: .value, with: { (snapshot) in
            self.messages.removeAll()
            snapshot.children.forEach({ (child) in
                if let obj = (child as? DataSnapshot)?.value as? [String : Any] {
                    if let author = obj["author"] as? String, let text = obj["text"] as? String {
                        let message = Message(author: author, comment: text)
                        self.messages.append(message)
                    }
                }
            })
            self.chatTableViewController.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableViewController.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableChatCell
        let comment = messages[indexPath.row]
        cell.usernameForChat.text = comment.author
        cell.loadCommentToView.text = comment.comment
        //cell.loadCommentToView.text = commentTextField.text
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableViewDataLoad() {
        chatTableViewController?.delegate = self
        chatTableViewController?.dataSource = self
        chatTableViewController?.reloadData()
    }
    @IBAction func handleSend(_ sender: Any) {
        let ref = Database.database().reference().child("Comments")
        let childRef = ref.childByAutoId()
        if let author = Auth.auth().currentUser?.displayName, let text = commentTextField.text {
            let values = ["author": author, "text": text]
            let aMessage = Message(author: author, comment: text)
            self.messages.append(aMessage)
            chatTableViewController.reloadData()
            childRef.updateChildValues(values)
        }
    }
    // Loads image from chatroom
    func loadImageFromChatRoom() {
    
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
extension DetailsViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
        
    }
}
