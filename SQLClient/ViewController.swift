//
//  ViewController.swift
//  SQLClient
//
//  Created by vinayaka s yattinahalli on 03/06/20.
//  Copyright © 2020 vinayaka s yattinahalli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding the observer for error and to receive the message
        NotificationCenter.default.addObserver(self, selector: #selector(error(_:)), name: NSNotification.Name.SQLClientError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(message(_:)), name: NSNotification.Name.SQLClientMessage, object: nil)
        
        let client = SQLClient.sharedInstance()!
                  client.connect("ServerNameOrIP", username: "cool", password: "cool", database: "database") { success in
                  client.execute("SELECT * FROM table", completion: { (_ results: ([Any]?)) in
                   for table in results as! [[[String:AnyObject]]] {
                       for row in table {
                           for (columnName, value) in row {
                               print("\(columnName) = \(value)")
                           }
                       }
                   }
                   client.disconnect()
               })
           }
          }
  
    @objc func error(_ notification: Notification?) {
     let code = notification?.userInfo?[SQLClientCodeKey] as? NSNumber
     let message = notification?.userInfo?[SQLClientMessageKey] as? String
     let severity = notification?.userInfo?[SQLClientSeverityKey] as? NSNumber
     if let code = code, let severity = severity {
         print("Error #\(code): \(message ?? "") (Severity \(severity))")
     }
 }

    @objc func message(_ notification: Notification?) {
        let message = notification?.userInfo?[SQLClientMessageKey] as? String
        print("Message: \(message ?? "")")
    }
}

