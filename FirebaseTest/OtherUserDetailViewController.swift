//
//  OtherUserDetailViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/17.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseFirestore

class OtherUserDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    
    var userDocument: DocumentSnapshot!
    var documentList: [QueryDocumentSnapshot] = []
    var giveDocument: QueryDocumentSnapshot!
    var uid: String = ""
    var username: String = ""
    var comment: String = ""
    var db: Firestore!
    var selfUid: String!
    var selfUname: String!
    var checkRoom = false
    var roomDocumentID: String!
    var checkFollow
        = false
    var followsDocumentID: String!
    var followsCount: Int = 0
    var followersCount: Int = 0
    
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
    
    func getPhotosCollection() {
        db.collection("Users").document(uid).collection("Photos").order(by: "created", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                if querySnapshot != nil {
                    var queryList: [QueryDocumentSnapshot] = []
                    for document in querySnapshot!.documents {
                        queryList.append(document)
                    }
                    self.documentList = queryList
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        selfUid = appDelegate.uid!
        selfUname = appDelegate.uname!
        
        uid = userDocument.documentID
        username = userDocument.data()!["username"] as! String
        comment = userDocument.data()!["comment"] as! String
        usernameLabel.text = username
        commentLabel.text = comment
        
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collectionView.collectionViewLayout = layout
        
        if self.selfUid == uid {
            chatButton.isHidden = true
            followButton.isHidden = true
        }
        
        followCountButton.titleLabel!.numberOfLines = 2
        followCountButton.titleLabel!.textAlignment = NSTextAlignment.center
        followCountButton.layer.borderWidth = 2
        followCountButton.layer.borderColor = UIColor.systemTeal.cgColor
        followCountButton.layer.cornerRadius = 20
        
        followerCountButton.titleLabel!.numberOfLines = 2
        followerCountButton.titleLabel!.textAlignment = NSTextAlignment.center
        followerCountButton.layer.borderWidth = 2
        followerCountButton.layer.borderColor = UIColor.systemTeal.cgColor
        followerCountButton.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        roomDocumentID = roomDocumentID(selfUid: self.selfUid!, opponentUid: uid)
        checkRoomsCollection(dID: roomDocumentID)
        
        checkFollowsCollection()
        
        getPhotosCollection()
        getMyFollowers()
        getMyFollows()
    }
    
    @IBAction func chatButton(_ sender: Any) {
        if checkRoom {
            setRoomsCollection(dID: roomDocumentID)
            checkRoom = false
            print("新規room作成")
            basicAlert("新規chatRoomを作成しました")
        } else {
            print("room作成済み")
            basicAlert("chatRoomは既に作成済みです")
        }
    }
    
    @IBAction func followButton(_ sender: Any) {
        if checkFollow {
            addFollowsCollection()
            checkFollow = false
            followButton.setTitle("Follow中", for: .normal)
            print("新規follow追加")
            basicAlert("\(username)さんをFollowしました")
        } else {
            deleteFollowsCollection()
            checkFollow = true
            followButton.setTitle("Follow!", for: .normal)
            print("follow解除")
            basicAlert("followを解除しました")
        }
        self.getMyFollowers()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setRoomsCollection(dID: String) {
        db.collection("Rooms").document(dID).setData([
            "user1ID": self.selfUid!,
            "user1name": self.selfUname!,
            "user2ID": self.uid,
            "user2name": self.username,
            "created": Timestamp(date: Date())
        ]) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("setOK!")
            }
        }
    }
    
    func roomDocumentID(selfUid: String, opponentUid: String) -> String {
        var sortArray = [selfUid, opponentUid]
        sortArray.sort { $0 < $1 }
        let roomDocumentID = sortArray.joined()
        return roomDocumentID
    }
    
    func checkRoomsCollection(dID: String) {
        db.collection("Rooms").document(dID).getDocument() { (query, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                if query!.data() == nil {
                    self.checkRoom = true
                    print("作れる")
                }
            }
        }
    }
    
    func addFollowsCollection() {
        var ref: DocumentReference? = nil
        ref = db.collection("Follows").addDocument(data: [
            "followUID": self.selfUid!,
            "followUname": self.selfUname!,
            "followerUID": uid,
            "followerUname": username,
            "created": Timestamp(date: Date())
        ]) { err in
            if let err = err {
                print("Erro: \(err)")
            } else {
                print("Follow OK!")
                self.followsDocumentID = ref!.documentID
            }
        }
    }
    
    func checkFollowsCollection() {
        db.collection("Follows").whereField("followUID", isEqualTo: self.selfUid!).whereField("followerUID", isEqualTo: uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                if querySnapshot!.count == 0 {
                    self.checkFollow = true
                    self.followButton.setTitle("follow!", for: .normal)
                    print("新規followl可")
                } else {
                    self.checkFollow = false
                    self.followButton.setTitle("follow中", for: .normal)
                    for document in querySnapshot!.documents {
                        self.followsDocumentID = document.documentID
                    }
                }
            }
        }
    }
    
    func deleteFollowsCollection() {
        db.collection("Follows").document(self.followsDocumentID).delete() { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("delete OK!")
                self.followsDocumentID = nil
            }
        }
    }
    
    func getMyFollows() {
        db.collection("Follows").whereField("followUID", isEqualTo: self.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                self.followsCount = querySnapshot!.count
                self.followCountButton.setTitle("Follow\n\(self.followsCount)", for: .normal)
            }
        }
    }
    
    func getMyFollowers() {
        db.collection("Follows").whereField("followerUID", isEqualTo: self.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                self.followersCount = querySnapshot!.count
                self.followerCountButton.setTitle("Follower\n\(self.followersCount)", for: .normal)
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
