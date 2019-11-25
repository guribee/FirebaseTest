//
//  UserViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore
import FirebaseUI

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    
    var documentList: [QueryDocumentSnapshot] = []
    var giveDocument: QueryDocumentSnapshot!
    var uid: String!
    var uname: String!
    var db: Firestore!
    var followsCount: Int = 0
    var followersCount: Int = 0
    var followDocumentList: [QueryDocumentSnapshot] = []
    var followerDocumentList: [QueryDocumentSnapshot] = []
    
    //cellの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.documentList.count
    }
    //cellの中身
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCellCollectionViewCell
        let imageURL = documentList[indexPath.item].data()["photoURL"] as! String
        let storageRef = Storage.storage().reference(forURL: imageURL)
        cell.photoCellImageView.sd_setImage(with: storageRef)
        return cell
    }
    //cellのサイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 10
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        giveDocument = documentList[indexPath.item]
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let nextView = segue.destination as! PhotoDetailViewController
            nextView.document = giveDocument
        }
    }
    

    
    private func basicAlert (_ message: String) {
          let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          present(alert, animated: true, completion: nil)
      }
    
    func moveView(identifier view: String) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(identifier: view)
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    func getPhotosCollection() {
    db.collection("Users").document(self.uid).collection("Photos").order(by: "created", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error:\(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.documentList = queryList
                self.collectionView.reloadData()
            }
        }
    }
    
    func getMyFollows() {
        db.collection("Follows").whereField("followUID", isEqualTo: self.uid!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                self.followsCount = querySnapshot!.count
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.followDocumentList = queryList
                self.followButton.setTitle("Follow\n\(self.followsCount)", for: .normal)
            }
        }
    }
    
    func getMyFollowers() {
        db.collection("Follows").whereField("followerUID", isEqualTo: self.uid!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                self.followersCount = querySnapshot!.count
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.followerDocumentList = queryList
                self.followerButton.setTitle("Follower\n\(self.followersCount)", for: .normal)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        uid = appDelegate.uid
        uname = appDelegate.uname
        usernameLabel.text = uname
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.collectionViewLayout = layout
        
        followButton.titleLabel!.numberOfLines = 2
        followButton.titleLabel!.textAlignment = NSTextAlignment.center
        followButton.layer.borderWidth = 2
        followButton.layer.borderColor = UIColor.systemTeal.cgColor
        followButton.layer.cornerRadius = 20
        
        followerButton.titleLabel!.numberOfLines = 2
        followerButton.titleLabel!.textAlignment = NSTextAlignment.center
        followerButton.layer.borderWidth = 2
        followerButton.layer.borderColor = UIColor.systemTeal.cgColor
        followerButton.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPhotosCollection()
        getMyFollows()
        getMyFollowers()
    }
    
    
    @IBAction func followButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(identifier: "followlist") as! FollowListViewController
        nextView.listName = "Follow"
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func followerButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(identifier: "followlist") as! FollowListViewController
        nextView.listName = "Follower"
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    
    @IBAction func nextNewPhotoV(_ sender: Any) {
        moveView(identifier: "newphoto")
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            moveView(identifier: "login")
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    
    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
