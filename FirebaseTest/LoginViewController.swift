//
//  LoginViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var mailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    
    private func basicAlert (_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        guard let error = errorOrNil else {
            return }
        let message = errorMessage(of: error)
        basicAlert(message)
        
    }
    
    private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        switch errcd {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザーが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でログインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードがせ脆弱すぎます"
        default: break
        }
        return message
    }
    
    func moveView(identifier view: String) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(identifier: view)
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            mailTF.text = user.email
        }
        passTF.delegate = self
        passTF.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    


    
    @IBAction func loginButton(_ sender: Any) {
        let mail = mailTF.text ?? ""
        let pass = passTF.text ?? ""
        
        Auth.auth().signIn(withEmail: mail, password: pass)  { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                if user.isEmailVerified == true {
                    self.moveView(identifier: "content")
                } else {
                    self.moveView(identifier: "mailagein")
                }
            }
            self.showErrorIfNeeded(error)
        }
    }
    
    @IBAction func signupButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let login = storyboard.instantiateViewController(identifier: "signup")
        self.present(login, animated: true, completion: nil)
        
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
