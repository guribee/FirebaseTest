//
//  TabBarController.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/20.
//  Copyright © 2019 会澤勇気. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = delegate
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
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

