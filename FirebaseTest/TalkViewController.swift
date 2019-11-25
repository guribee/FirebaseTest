//
//  TalkViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class TalkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var commentTF: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var uid: String!
    var uname: String!
    var opponentUID: String!
    var opponentUname: String!
    var roomID: String!
    var talkDocumentList: [QueryDocumentSnapshot] = []
    var db: Firestore!
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkDocumentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TalkTableViewCell
        cell.commentLabel.text = talkDocumentList[indexPath.row].data()["text"] as? String
        cell.commentLabel.numberOfLines = 0
        cell.sizeToFit()
        if talkDocumentList[indexPath.row].data()["postuserID"] as? String == self.uid {
            cell.commentLabel.backgroundColor = UIColor(red:210/255,green:255/255,blue:255/255,alpha:1)
        } else {
            cell.commentLabel.backgroundColor = UIColor(red:200/255,green:255/255,blue:190/255,alpha:1)
        }
        cell.nameLabel.text = talkDocumentList[indexPath.row].data()["postuser"] as? String
        let timestamp = talkDocumentList[indexPath.item].data()["created"]! as! Timestamp
        let date: Date = timestamp.dateValue()
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja-JP")
        df.dateFormat = "MM/dd HH:mm"
        let strCreated = df.string(from: date)
        cell.createdLabel.text = strCreated
        return cell
    }
    
    func addTalkCollection(text: String) {
        db.collection("Rooms").document(roomID).collection("Talks").addDocument(data: [
            "postuser": self.uname!,
            "postuserID": self.uid!,
            "text": text,
            "created": Timestamp(date: Date())
        ]) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("add OK!")
                self.updateRoomCreated()
                self.getTalksCollection()
            }
        }
    }
    
    func updateRoomCreated() {
        db.collection("Rooms").document(roomID).updateData([
            "created": Timestamp(date: Date())
        ]) { err in
            if let err = err {
                print("Error: \(err)")
            } else {
                print("update OK!")
            }
        }
    }
    
    func getTalksCollection() {
        db.collection("Rooms").document(roomID).collection("Talks").order(by: "created").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot] = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.talkDocumentList = queryList
                self.tableView.reloadData()
                if self.talkDocumentList.count != 0 {
                    let indexPath = IndexPath(row: self.talkDocumentList.count-1 , section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
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
        
        tableView.rowHeight = UITableView.automaticDimension
        roomName.text = opponentUname
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTalksCollection()
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        if commentTF.text != nil || commentTF.text != ""  {
            addTalkCollection(text: commentTF.text!)
            commentTF.text = nil
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
