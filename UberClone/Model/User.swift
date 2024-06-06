//
//  User.swift
//  UberClone
//


import Foundation
import CoreLocation


struct User {
    let uid: String
    let fullName: String
    let email: String
    let accountType: Int
    var location: CLLocation?
    
    // uid is passed as a separate parameter because in Firebase 'uid' is not a part of dictionary
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
