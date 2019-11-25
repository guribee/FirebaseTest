//
//  File.swift
//  FirebaseTest
//
//  Created by 会澤勇気 on 2019/11/17.
//  Copyright © 2019 会澤勇気. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCore


struct fsOperation {
    static func moveView(identifier view: String) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(identifier: view)
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    
    
}
