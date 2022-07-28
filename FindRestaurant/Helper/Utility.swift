//
//  Utility.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 12/07/22.
//

import Foundation
import UIKit
import CoreLocation

class Utility {
    
    class func alert(message: String, title: String? = nil, button1: String, button2: String? = nil, button3: String? = nil, action:@escaping (Int)->())
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let action1 = UIAlertAction(title: button1, style: .default) { _ in
                action(0)
            }
            alert.addAction(action1)
            if button2 != nil {
                let action2 = UIAlertAction(title: button2, style: .default) { _ in
                    action(1)
                }
                alert.addAction(action2)
            }
            
            if button3 != nil {
                let action3 = UIAlertAction(title: button3, style: .default) { _ in
                    action(2)
                }
                alert.addAction(action3)
            }
            alert.show()
        }
    }
    
    class func alert(message: String, title: String? = "") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            alert.show()
        }
    }
}
