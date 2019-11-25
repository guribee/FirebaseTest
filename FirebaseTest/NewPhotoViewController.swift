//
//  NewPhotoViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

class NewPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var commentTF: UITextView!
    
    var uname: String!
    var uid: String!
    let storage = Storage.storage()
    var db: Firestore!
    
    private func basicAlert (_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setPhotosCollection(photoURL: String, comment: String) {
        db.collection("Users").document(self.uid).collection("Photos").document().setData([
            "postuser": uname!,
            "postuserID": uid!,
            "photoURL": photoURL,
            "comment": self.commentTF.text ?? "",
            "created": Timestamp(date: Date()),
        ]) { err in
            if err != nil {
                print("Error")
            } else {
                print("OK")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        uname = appDelegate.uname
        uid = appDelegate.uid
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.selectImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func uploadButton(_ sender: Any) {
        let storageRef = storage.reference(forURL: "gs://fir-testproject-45097.appspot.com/")
        if let data = selectImageView.image?.jpegData(compressionQuality: 0.3) {
            let reference = storageRef.child("image/\(uid!)/" + NSUUID().uuidString + ".jpeg" )
//            let metaData = StorageMetadata()
//            metaData.contentType = "image/jpeg"
            reference.putData(data, metadata: nil) { (metadata, error) in
                guard let metadData = metadata else {
                    //error
                    return
                }
                reference.downloadURL { (url, erro) in
                    guard let url = url else {
                        //error
                        return
                    }
                    self.setPhotosCollection(photoURL: url.absoluteString, comment: self.commentTF.text)
                    self.basicAlert("投稿しました")
                    self.selectImageView.image = nil
                    self.commentTF.text = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
