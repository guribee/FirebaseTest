//
//  PhotoDetailViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI

class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var commentLabel: UITextView!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var document: QueryDocumentSnapshot!
    var documentID: String!
    var postUsername: String!
    var postUserID: String!
    var downloadURL: String!
    var comment: String!
    var created: String!
    var uid: String!
    var uname: String!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentID = document.documentID
        postUsername = document.data()["postuser"]! as? String
        postUserID = document.data()["postuserID"]! as? String
        downloadURL = document.data()["photoURL"]! as? String
        comment = document.data()["comment"]! as? String
        let timestamp = document.data()["created"] as! Timestamp
        let date: Date = timestamp.dateValue()
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja-JP")
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        created = df.string(from: date)
        
        usernameLabel.text = postUsername!
        commentLabel.text = comment!
        let storageRef = Storage.storage().reference(forURL: downloadURL!)
        photoView.sd_setImage(with: storageRef)
        createdLabel.text = created
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        uname = appDelegate.uname
        uid = appDelegate.uid
        if uid != postUserID {
            deleteButton.isHidden = true
        }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    private func basicAlert (_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        db.collection("Users").document(uid).collection("Photos").document(documentID).delete() { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("delete!")
                self.basicAlert("投稿を削除しました")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
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
