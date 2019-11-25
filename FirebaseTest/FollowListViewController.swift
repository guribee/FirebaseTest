//
//  FollowListViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/25.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseCore

class FollowListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uid: String!
    var uname: String!
    var documentList: [QueryDocumentSnapshot] = []
    var listName: String!
    var giveUserDocument: DocumentSnapshot!
    var db: Firestore!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documentList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if listName == "Follow" {
            cell.textLabel!.text = self.documentList[indexPath.row].data()["followerUname"] as? String
        } else {
            cell.textLabel!.text = self.documentList[indexPath.row].data()["followUname"] as? String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let userID: String!
        if listName == "Follow" {
            userID = self.documentList[indexPath.row].data()["followerUID"] as? String
        } else {
            userID = self.documentList[indexPath.row].data()["followUID"] as? String
        }
        db.collection("Users").document(userID).getDocument() { (document, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                if let document = document, document.exists {
                    print(document)
                    self.giveUserDocument = document
                    self.performSegue(withIdentifier: "Segue", sender: nil)
                } else {
                    print("no data")
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let nextView = segue.destination as! OtherUserDetailViewController
            nextView.userDocument = giveUserDocument!
        }
    }
    
    func getMyFollows() {
        db.collection("Follows").whereField("followUID", isEqualTo: self.uid!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.documentList = queryList
                self.tableView.reloadData()
            }
        }
    }
    
    func getMyFollowers() {
        db.collection("Follows").whereField("followerUID", isEqualTo: self.uid!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.documentList = queryList
                self.tableView.reloadData()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        uid = appDelegate.uid
        uname = appDelegate.uname
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        titleName.text = listName + "LIST"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if listName == "Follow" {
            getMyFollows()
        } else {
            getMyFollowers()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
