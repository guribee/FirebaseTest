//
//  MailageinViewController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/17.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit

class MailageinViewController: UIViewController {
    @IBOutlet weak var mailTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func mailageinButton(_ sender: Any) {
    }
    
    @IBAction func nextLoginButton(_ sender: Any) {
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
