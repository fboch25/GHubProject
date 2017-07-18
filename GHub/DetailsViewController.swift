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
        //var timeStamp: String!
    }

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var object: Object?
    var objects: [Object] = []
    var messages: [Message] = []
    
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var chatTableViewController: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentView: UIView!
    // Instance of cell
    var tableChatCell: TableChatCell!
    var ref: DatabaseReference!
    // MARK: viewDidAppear()
    override func viewDidAppear(_ animated: Bool) {
    }
    // MARK: viewDidLoad() 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        loadData()
        tableViewDataLoad()
        cleanUp()
        loadImageFromChatRoom()
        setupViewResizerOnKeyboardShown()
    }
    // clean up UI function
    func cleanUp(){
        hideKeyboardWhenTappedAround()
        self.chatTableViewController.rowHeight = UITableViewAutomaticDimension
        self.chatTableViewController.estimatedRowHeight = 100
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    // MARK: Load to Firebase
    func loadData() {
        if let theObject = object {
        ref.child("Comments").child(theObject.id).observeSingleEvent(of: .value, with: { (snapshot) in
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
    }
    // MARK: Table View creation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableViewController.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableChatCell
        let comment = messages[indexPath.row]
        cell.usernameForChat.text = comment.author
        cell.loadCommentToView.text = comment.comment
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableViewDataLoad() {
        chatTableViewController?.delegate = self
        chatTableViewController?.dataSource = self
        self.commentTextField.delegate = self
    }
    // MARK: Send to Firebase
    @IBAction func handleSend(_ sender: Any) {
        if let theObject = object {
            let ref = Database.database().reference().child("Comments").child(theObject.id)
            let childRef = ref.childByAutoId()
            if let author = Auth.auth().currentUser?.displayName, let text = commentTextField.text {
                let values = ["author": author, "text": text]
                let aMessage = Message(author: author, comment: text)
                self.messages.append(aMessage)
                childRef.updateChildValues(values)
            }
            self.chatTableViewController.reloadData()
            commentTextField.text = nil
        }
    }
    // Dismiss Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend(Any.self)
        self.view.endEditing(true)
        return true
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
    
    
    
    // MARK - Scroll View Resize on Keyboard Events
    
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShowForResizing),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHideForResizing),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            commentViewBottomConstraint.constant = keyboardSize.height
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    func keyboardWillHideForResizing(notification: Notification) {
        commentViewBottomConstraint.constant = 0
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
