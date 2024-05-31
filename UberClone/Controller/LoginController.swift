//
//  LoginController.swift
//  UberClone
//
//  Created by Saqib Bhatti on 27/9/23.
//

import UIKit

class LoginController: UIViewController {
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
    
    
    private lazy var passwordContainerView: UIView = {
        return UIView().inputContainerView(image: UIImage(named: "ic_lock")!, textField: passwordTextField)
    }()
    
    
    private let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    
    private let loginBtn: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Log In", for: .normal)
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    
    private let dontHaveAccountBtn: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account ?   ",
                                                        attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                                                                     NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.mainBlueTint]))
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
    }

    
    // MARK: - Selectors
    @objc func handleShowSignUp() {
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        view.addSubview(emailContainerView)
        view.addSubview(passwordContainerView)
        view.addSubview(loginBtn)
        view.addSubview(dontHaveAccountBtn)

        titleLabel.setConstraints(top: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(inView: view)
        
        emailContainerView.setConstraints(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        passwordContainerView.setConstraints(top: emailContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        loginBtn.setConstraints(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 15, paddingRight: 15, height: 50)
        
        dontHaveAccountBtn.centerX(inView: view)
        dontHaveAccountBtn.setConstraints(bottom: view.safeAreaLayoutGuide.bottomAnchor, height: 32)
    }
    
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
