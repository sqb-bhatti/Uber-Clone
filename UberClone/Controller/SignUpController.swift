//
//  SignUpController.swift
//  UberClone
//


import UIKit


class SignUpController: UIViewController {
    // MARK: - Properties
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
    
    private let signUpBtn: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    
    private let alreadyHaveAccountBtn: UIButton = {
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
}
