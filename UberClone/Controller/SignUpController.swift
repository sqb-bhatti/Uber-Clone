//
//  SignUpController.swift
//  UberClone
//


import UIKit
import Firebase
import GeoFire


class SignUpController: UIViewController {
    // MARK: - Properties
    private var location = LocationsHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        return UIView().inputContainerView(image: UIImage(named: "ic_mail")!, textField: emailTextField)
    }()
    
    private lazy var fullNameContainerView: UIView = {
        return UIView().inputContainerView(image: UIImage(named: "ic_person")!, textField: fullNameTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
        return UIView().inputContainerView(image: UIImage(named: "ic_lock")!, textField: passwordTextField)
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_account")!, segmentedCtrl: accountTypeSegmentedCtrl)
        return view
    }()
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    private let accountTypeSegmentedCtrl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = .white
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private lazy var signUpBtn: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    
    private lazy var alreadyHaveAccountBtn: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account ?   ",
                                                        attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                                                                     NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        print("DEBUG: Location is \(location)")
    }
    
    
    // MARK: - Selectors
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        view.addSubview(emailContainerView)
        view.addSubview(passwordContainerView)
        view.addSubview(fullNameContainerView)
        view.addSubview(accountTypeContainerView)
        view.addSubview(signUpBtn)
        view.addSubview(alreadyHaveAccountBtn)
        
        titleLabel.setConstraints(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        emailContainerView.setConstraints(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        passwordContainerView.setConstraints(top: emailContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        fullNameContainerView.setConstraints(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        accountTypeContainerView.setConstraints(top: fullNameContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        signUpBtn.setConstraints(top: accountTypeContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        alreadyHaveAccountBtn.centerX(inView: view)
        alreadyHaveAccountBtn.setConstraints(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        let accountTypeIndex = accountTypeSegmentedCtrl.selectedSegmentIndex
        
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to register user with error \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // create dictionary to upload on Firebase database
            let values = ["email": email, "fullName": fullName, "accountType": accountTypeIndex]
            
            // If the user is a driver
            if accountTypeIndex == 1 {
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                
                guard let location = self.location else { return }
                geofire.setLocation(location, forKey: uid, withCompletionBlock: { (error) in
                    self.uploadUserDataAndShowHomeVC(uid: uid, values: values)
                })
            }
            self.uploadUserDataAndShowHomeVC(uid: uid, values: values)
        }
    }
    
    
    func uploadUserDataAndShowHomeVC(uid: String, values: [String: Any]) {
        REF_USERS.child(uid).updateChildValues(values) { error, ref in
            DispatchQueue.main.async {
                let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                if let homeController = keyWindow?.rootViewController as? HomeController {
                    homeController.configure()
                }
            }
            
            // Because in case of No Login we are presenting Login screen over Home screen. So, when user logs in successfully we dismiss the Login screen. Similar logic with Sign up screen.
            self.dismiss(animated: true, completion: nil)
        }
    }
}
