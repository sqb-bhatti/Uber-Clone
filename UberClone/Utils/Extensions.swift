//
//  Extensions.swift
//  UberClone


import UIKit



// MARK: - UIView extension
extension UIView {
    
    func setConstraints(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0, paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0, paddingRight: CGFloat = 0,
                width: CGFloat? = nil, height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    
    func centerX(inView view: UIView) {
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    // Centre vertically with left padding
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            setConstraints(left: left, paddingLeft: paddingLeft)
        }
    }
    
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentedCtrl: UISegmentedControl? = nil) -> UIView {
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87

        
        if let textField = textField {
            self.addSubview(imageView)
            imageView.centerY(inView: self)
            imageView.setConstraints(left: self.leftAnchor, paddingLeft: 8, width: 24, height: 24)
            
            self.addSubview(textField)
            textField.centerY(inView: self)
            textField.setConstraints(left: imageView.rightAnchor, right: self.rightAnchor, paddingLeft: 8)
        }
        
        if let sc = segmentedCtrl {
            self.addSubview(imageView)
            
            // ImageView constraints will be different in case of Segmented control
            imageView.setConstraints(top: self.safeAreaLayoutGuide.topAnchor, left: self.leftAnchor, paddingTop: -20, paddingLeft: 8,
                                     width: 24, height: 24)
            self.addSubview(sc)
            sc.centerY(inView: self)
            sc.setConstraints(left: self.leftAnchor, bottom: self.safeAreaLayoutGuide.bottomAnchor, right: self.rightAnchor, paddingLeft: 8, paddingBottom: 8, paddingRight: 8)
        }
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        self.addSubview(separatorView)
        separatorView.setConstraints(left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor,
                                     paddingLeft: 8, height: 0.75)
        
        return self
    }
}




// MARK: - UITextField extension
extension UITextField {
    
    func textField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        
        self.borderStyle = .none
        self.font = UIFont.systemFont(ofSize: 16)
        self.textColor = .white
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        self.isSecureTextEntry = isSecureTextEntry
        self.autocapitalizationType = .none
        
        return self
    }
}




// MARK: - UIColor extension
extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
}






extension UIApplication {
    
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
}

