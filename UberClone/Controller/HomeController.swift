//
//  HomeController.swift
//  UberClone
//


import UIKit
import Firebase
import MapKit


class HomeController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        checkIfUserLoggedIn()
        signOut()
    }
    
    
    func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } 
        else {
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error Signing out")
        }
    }
    
    
    func configureUI() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
}
