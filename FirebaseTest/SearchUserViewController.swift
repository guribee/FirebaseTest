//
//  SearchUserViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/21.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class SearchUserViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDocumentList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = userDocumentList[indexPath.row].data()["username"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        giveUserDocument = userDocumentList[indexPath.row]
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue" {
            let nextView = segue.destination as! OtherUserDetailViewController
            nextView.userDocument = giveUserDocument
        }
    }
    

    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var userDocumentList: [QueryDocumentSnapshot] = []
    var db:Firestore!
    var giveUserDocument: DocumentSnapshot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.showsSearchResultsButton = true
        searchBar.placeholder = "usernameで検索してください"
        
        
        // Do any additional setup after loading the view.
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        db.collection("Users").whereField("username", isEqualTo: searchBar.text ?? "").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error: \(err)")
            } else {
                var queryList: [QueryDocumentSnapshot]! = []
                for document in querySnapshot!.documents {
                    queryList.append(document)
                }
                self.userDocumentList = queryList
                self.tableView.reloadData()
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
