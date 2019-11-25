//
//  ListViewController.swift
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

class ListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITabBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var documentList: [QueryDocumentSnapshot] = []
    var giveDocument: QueryDocumentSnapshot!
    var uid: String!
    var uname: String!
    var db: Firestore!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AllPhotoCellCollectionViewCell
        cell.usernameLabel.text = documentList[indexPath.item].data()["postuser"] as? String
        let timestamp = documentList[indexPath.item].data()["created"]! as! Timestamp
        let date: Date = timestamp.dateValue()
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja-JP")
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let strCreated = df.string(from: date)
        cell.createdLabel.text = "投稿日：" + strCreated
        let imageURL = documentList[indexPath.item].data()["photoURL"] as! String
        let storageRef = Storage.storage().reference(forURL: imageURL)
        cell.photoCellImageView.sd_setImage(with: storageRef)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 10
        let cellSize : CGFloat = self.view.bounds.width - horizontalSpace
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = Auth.auth().currentUser
        if let user = user {
            uid = user.uid
            uname = user.displayName
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.uid = uid
            appDelegate.uname = uname
        }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db.collectionGroup("Photos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else  {
                var queryList: [QueryDocumentSnapshot] = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.documentList = queryList
                self.collectionView.reloadData()
            }
        }
    }
        
        
        // Do any additional setup after loading the view.    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
