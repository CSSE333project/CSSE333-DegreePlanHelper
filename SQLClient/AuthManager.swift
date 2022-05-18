//
//  AuthManager.swift
//  SQLClient
//
//  Created by Yujie Zhang on 4/28/22.
//  Copyright © 2022 vinayaka s yattinahalli. All rights reserved.
//

import Foundation
import Pods_SQLClient
import FirebaseAuth
import FirebaseFirestore

class AuthManager{
    static let shared = AuthManager()
    private init(){
        
    }
    var currentUser: User?
    
    var isSignedIn: Bool = false
    
    var loginObserver: (()->Void)?
    
    
    func registerNewUser(role: String, firstName: String, lastName: String, userName: String, password: String, rank:String){//return true if signed in
        //TODO: return 0 for error
        let client = SQLClient.sharedInstance()!
        var loginQuery = ""
        if(role == "s"){
            loginQuery = "Declare @newID int EXECUTE [insertNewUser] '\(role)', '\(firstName)', '\(lastName)','\(userName)', '\(password)', null, @newID OUTPUT Select @newID"
        }else if(role == "p"){
            loginQuery = "Declare @newID int EXECUTE [insertNewUser] @Role = '\(role)', @FName = '\(firstName)', @LName = '\(lastName)', @UserName = '\(userName)', @UserPassword = '\(password)', @Rank = 'test', @UserID = @newID OUTPUT Select @newID"
        }
//        print("LoginQuery = \(loginQuery)")
        client.connect("titan.csse.rose-hulman.edu", username: kUserName, password: kPassword, database: kDatabase) { success in
            client.execute(loginQuery, completion: { (_ results: ([Any]?)) in
                if let r = results as? [[[String:AnyObject]]] {
                for table in r {
                    for row in table {
                        for (columnName, value) in row {
                            print("\(columnName) = \(value)")
                            let uid = value as! Int
                            if(uid != -1){
                                self.currentUser = User(uid: uid, userName: userName, firstName: firstName, lastName: lastName, role: role, rank: rank)
                                self.loginObserver!()
                            }else{
                                print("error register")
                            }
                        }
                    }
                }
                }else{
                    print("no return from database")
                
                }
                
                
                client.disconnect()
            })
        }
        
       
    }
    
    func loginExistingUser(UserName: String, password: String){// return true if logged in
       //TODO: return uid
        
        var loginQuery = ""
        loginQuery = "DECLARE @output int EXEC [CheckUser] '\(UserName)','\(password)', @output OUTPUT SELECT @output"
        
        let client = SQLClient.sharedInstance()!
        client.connect("titan.csse.rose-hulman.edu", username: kUserName, password: kPassword, database: kDatabase) { success in
            client.execute(loginQuery, completion: { (_ results: ([Any]?)) in
                if let r = results as? [[[String:AnyObject]]] {
                for table in r {
                    for row in table {
                        for (columnName, value) in row {
                            print("\(columnName) = \(value)")
                            let r = value as! Int
                            if(r != -1){
                                self.loginObserver!()
                                self.currentUser = User(uid: r)
                            }else{
                                print("error login")
                            }
                            
                        }
                    }
                }
                }else{
                    print("no return from database")
                
                }
                
                client.disconnect()
            })
        }
       
    }
    
    func logout(){
        self.currentUser = nil
        loginObserver!()
    }
    
    func signInWithRosefireToken(_ rosefireToken: String){
        Auth.auth().signIn(withCustomToken: rosefireToken) { (authResult, error) in
            if let error = error {
              print("Firebase sign in error! \(error)")
              return
            }
            // User is signed in using Firebase!
            print("The user is now actually signed in using the Rosefire token")
            self.loginObserver!()
          }
    }
    
    func signInNewEmailPasswordUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error{
                print("There was an error creating the user: \(error)")
                return
            }
            print("User created")
        }
    }
    
    func loginExistingEmailPasswordUser(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error{
                print("There was an error logging in existing user: \(error)")
                return
            }
            print("User login")
            let docRef = Firestore.firestore().collection(kUsersCollectionPath).document(email)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let sqlid = document.get(ksqlID) as! Int
                    self.currentUser = User(uid: sqlid)
                    print("update uid: \(sqlid)")
                    self.loginObserver!()
                } else {
                    print("Document does not exist")
                }
            }
//            self.loginObserver!()
        }
    }
    
    
}
