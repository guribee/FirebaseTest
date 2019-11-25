//
//  SignupViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class SignupViewController: UIViewController {
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    func setUsersCollection (documentId: String, username: String) {
        db.collection("Users").document(documentId).setData([
            "username": username,
            "photoURL": "",
            "comment": "",
            "created": Timestamp(date: Date()),
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document seccessfully writen!")
            }
        }
    }
    
    private func showErrorIfNeeded(_ errorOrnil: Error?, _ num: Int) {
        guard errorOrnil != nil else { return }
        let message = "エラーが起きました(\(num))"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func createButton(_ sender: Any) {
        let name = usernameTF.text ?? ""
        let mail = mailTF.text ?? ""
        let pass = passTF.text ?? ""
        
        Auth.auth().createUser(withEmail: mail, password: pass) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                let req = user.createProfileChangeRequest()
                req.displayName = name
                req.commitChanges() { [weak self] error in
                    guard let self = self else { return }
                    if error == nil {
                        user.sendEmailVerification() { [weak self] error in
                            guard let self = self else { return }
                            if error == nil {
                                self.setUsersCollection(documentId: user.uid, username: user.displayName!)
                                let storyboard: UIStoryboard = self.storyboard!
                                let nextView = storyboard.instantiateViewController(identifier: "mailsend") as! MailSendViewController
                                nextView.mailString = user.email!
                                self.present(nextView, animated: true, completion: nil)
                            }
                            self.showErrorIfNeeded(error, 1)                        }
                    }
                    self.showErrorIfNeeded(error, 2)
                }
            }
            self.showErrorIfNeeded(error, 3)
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
