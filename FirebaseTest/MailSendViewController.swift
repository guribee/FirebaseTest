//
//  MailSendViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/16.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit

class MailSendViewController: UIViewController {
    @IBOutlet weak var mailtext: UILabel!
    var mailString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailtext.text = mailString
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextLoginButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let login = storyboard.instantiateViewController(identifier: "login")
        self.present(login, animated: true, completion: nil)
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
