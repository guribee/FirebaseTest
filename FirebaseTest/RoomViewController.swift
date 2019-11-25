//
//  RoomViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class RoomViewController: UIViewController, UITabBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomDocumentList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if roomDocumentList[indexPath.row].data()["user1name"] as? String == self.uname {
            cell.textLabel!.text = roomDocumentList[indexPath.row].data()["user2name"] as? String
        } else {
            cell.textLabel!.text = roomDocumentList[indexPath.row].data()["user1name"] as? String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let document = roomDocumentList[indexPath.row]
        giveRoomID = document.documentID
        if roomDocumentList[indexPath.row].data()["user1name"] as? String == self.uname {
            giveOpponentUname = roomDocumentList[indexPath.row].data()["user2name"] as? String
            giveOpponentUID = roomDocumentList[indexPath.row].data()["user2ID"] as? String
        } else {
            giveOpponentUname = roomDocumentList[indexPath.row].data()["user1name"] as? String
            giveOpponentUID = roomDocumentList[indexPath.row].data()["user1ID"] as? String
        }
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let nextView = segue.destination as! TalkViewController
            nextView.roomID = giveRoomID
            nextView.opponentUID = giveOpponentUID
            nextView.opponentUname = giveOpponentUname
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var uid: String!
    var uname: String!
    var opponentUid: String!
    var opponentUname: String!
    var db: Firestore!
    var ref: DocumentReference!
    var roomDL1: [QueryDocumentSnapshot] = []
    var roomDL2: [QueryDocumentSnapshot] = []
    var roomDocumentList: [QueryDocumentSnapshot] = []
    var giveRoomID: String!
    var giveOpponentUID: String!
    var giveOpponentUname: String!
    
    func basicAlert (_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func getRoomsCollection1() {
        db.collection("Rooms").whereField("user1ID", isEqualTo: self.uid!).getDocuments() { ( querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.roomDL1 = queryList
                self.getRoomsCollection2()
            }
        }
    }
    
    func getRoomsCollection2() {
         db.collection("Rooms").whereField("user2ID", isEqualTo: self.uid!).getDocuments() { ( querySnapshot, err) in
             if let err = err {
                 print("Error: \(err)")
             } else {
                 var queryList: [QueryDocumentSnapshot] = []
                 for document in querySnapshot!.documents {
                     queryList.append(document)
                 }
                self.roomDL2 = queryList
                self.sortDocument()
             }
         }
     }
    
    func sortDocument() {
        var list: [QueryDocumentSnapshot] = []
        for document in roomDL1 {
            list.append(document)
        }
        for document in roomDL2 {
            list.append(document)
        }
        for i in 0..<list.count {
            for j in 0..<list.count {
                let iTS = list[i].data()["created"] as! Timestamp
                let iDate = iTS.dateValue()
                let jTS = list[j].data()["created"] as! Timestamp
                let jDate = jTS.dateValue()
                if iDate < jDate {
                    list.append(list[i])
                    list.remove(at: i)
                }
            }
        }
        roomDocumentList = list
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        uid = appDelegate.uid
        uname = appDelegate.uname
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRoomsCollection1()
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
