//
//  User.swift
//  UberClone
//


import Foundation
import CoreLocation


enum AccountType: Int {
    case passenger
    case driver
}



struct User {
    let uid: String
    let fullName: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    
    // uid is passed as a separate parameter because in Firebase 'uid' is not a part of dictionary
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
