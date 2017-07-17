//
//  ChatRoom.swift
//  GHub
//
//  Created by Frank Joseph Boccia on 7/8/17.
//  Copyright © 2017 Frank Joseph Boccia. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

// MARK: Struct of Objects
struct Object {
    var image: UIImage?
    var imagePath: String?
    var title: String!
    var ratio: Double
    var name: String?
}
class ChatRoom: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    // Properties
    var object: Object?
    var objects: [Object] = []
    var picker: UIImagePickerController!
    // Firebase
    var ref: DatabaseReference?
    var storage = Storage.storage()
    let uid = Auth.auth().currentUser!.uid
    // Refresh
    let refresher = UIRefreshControl()
    let attributesForRefresherTitle = [NSForegroundColorAttributeName: UIColor(r: 0, g: 51, b: 102)]
    // CollectionView
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var nameForCreatedCell: UILabel!
    // Instance of a class
    var chatCellView: ChatCell?
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebase Data
        ref = Database.database().reference()
        fetchData()
        // Refresh Photo Collection View
        refreshPhotoCollectionView()
        // User Logged In
       checkIfUserLoggedIn()
        // CollectionView Data Loading
        photoCollectionViewDataLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: Refresh
    func refreshPhotoCollectionView() {
        self.photoCollectionView.alwaysBounceVertical = true
        self.photoCollectionView.showsVerticalScrollIndicator = false 
        self.refresher.tintColor = UIColor(r: 0, g: 51, b: 102)
        self.refresher.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: attributesForRefresherTitle)
        self.refresher.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        self.photoCollectionView.addSubview(refresher)
    }
    // Load Data
    func photoCollectionViewDataLoad() {
        photoCollectionView?.delegate = self
        photoCollectionView?.dataSource = self
        photoCollectionView?.reloadData()
    }
    // MARK: Create collection View cell with title, image, and rounded border
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChatCell
        let object = objects[indexPath.row]
        cell.chatLabel.text = object.title ?? ""
        cell.nameForCreatedCell.text = object.name
        cell.chatImage.image = object.image
        if let chatImagePath = object.imagePath {
            if let imageURL = URL(string: chatImagePath) {
            cell.chatImage.sd_setImage(with: imageURL)
            }
        }
        // Cell Layout
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 8
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let object = objects[indexPath.row]
        let itemWidth = photoCollectionView.bounds.width
        let itemHeight = (itemWidth - 16) * CGFloat(object.ratio) + 30
        return CGSize(width: itemWidth, height: itemHeight)
    }
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedObject = objects[indexPath.row]
        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailsVC")  as? DetailsViewController {
            detailsVC.object = selectedObject
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    // MARK: Firebase Database saving posts
    func fetchData() {
        ref?.child("posts").observeSingleEvent(of: .value, with: { (snapshot) in
            self.objects.removeAll()
            snapshot.children.forEach({ (child) in
                if let value = (child as? DataSnapshot)?.value as? [String : Any] {
                    if let imagePath = value["image"] as? String, let title = value["title"] as? String {
                        var ratio: Double = 1
                        if let height = value["height"] as? Double, let width = value["width"] as? Double {
                            ratio = height  / width
                        }
                        let name = value["author"] as? String
                        let aObject = Object(image: nil, imagePath: imagePath, title: title, ratio: ratio, name: name)
                        self.objects.insert(aObject, at: 0)
                    }
                }
            })
            self.photoCollectionView.reloadData()
            self.refresher.endRefreshing()
        })
    }
    // MARK: Save to Firebase
    func saveToFirebase() {
        if let theObject = object {
            if let theImage = theObject.image {
                if let imageData = UIImageJPEGRepresentation(theImage, 1.0) {
                    let storageRef = storage.reference()
                    let imageRef = storageRef.child("images").child(uid)
                    let storagePath = "\(arc4random()).jpg"
                    imageRef.child(storagePath).putData(imageData, metadata: nil, completion: { (metadata, error) in
                        if let imagePath = metadata?.downloadURL()?.absoluteString {
                            self.ref?.child("posts").childByAutoId().setValue(["author": Auth.auth().currentUser!.displayName!,"users" : self.uid,"image" : imagePath, "title" : theObject.title])
                        }
                    })
                }
            }
        }
    }
    // MARK: Camera / PhotoLibrary
    func openCamera()
    {
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
        
    }
    func openPhotoLibrary()
    {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    func accessPhotoControls() {
        
    let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default)
    {
        UIAlertAction in
        self.openCamera()
    }
    let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default)
    {
        UIAlertAction in
        self.openPhotoLibrary()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
    {
        UIAlertAction in
    }
    // MARK: Image control --> Add actions
    picker = UIImagePickerController()
    picker?.allowsEditing = false
    picker?.delegate = self
    alert.addAction(cameraAction)
    alert.addAction(photoLibraryAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true, completion: nil)
}
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        switch info[UIImagePickerControllerOriginalImage] as? UIImage {
        case let .some(image):
            object = Object(image: image, imagePath: nil, title: "", ratio: 1, name: Auth.auth().currentUser!.displayName!)
            object?.image = image
        default:
            break
        }
        picker.dismiss(animated: true) {
            self.showCellTitleAlert()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        object = nil
        dismiss(animated: true) {
            self.photoCollectionView!.reloadData()
        }
    }
    // MARK: Alert Views
    func showCellTitleAlert() {
        let alert = UIAlertController(title: "Create Group Title", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "New Group Title..." }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.object = nil
        })
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            self.object?.title = (alert.textFields?.first.flatMap { $0.text })!
            self.object.flatMap { self.objects.insert($0, at: 0) }
            self.photoCollectionView?.reloadData()
            self.saveToFirebase()
        })
        
        present(alert, animated: true, completion: nil)
    }
    // MARK: Create new Cell
    @IBAction func didSelectCreateButton() {
        // Access alert for camera / photo
        accessPhotoControls()
    }
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            
            let uid =  Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                /*if let dictonary = snapshot.value as? [String: AnyObject] {
                   // self.navigationItem.title = (dictonary["name"] as? String)
                    // **cell name needed stil**
                }*/
                
            }, withCancel: nil )
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
                self.performSegue(withIdentifier: "logOut", sender: self)
            }
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
    }
}
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

