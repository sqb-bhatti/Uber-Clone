//
//  Service.swift
//  UberClone
//


import Firebase


// To access our Firebase Database
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")


struct Service {
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid  // get current user ID
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        REF_USERS.child(currentUid ?? "0").observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            let user = User(dictionary: dict)
            completion(user)
        }
    }
}
