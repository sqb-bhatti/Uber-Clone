//
//  LocationInputView.swift
//  UberClone
//


import UIKit



protocol LocationInputViewDelegate: AnyObject {
    func dismissLocationInputView()
}



class LocationInputView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(startingLocationTextField)
        addSubview(destinationLocationTextField)
        addSubview(startLocationIndicatorView)
        addSubview(destinationIndicatorView)
        addSubview(linkingView)
        
        backgroundColor = .white
        backButton.setConstraints(top: self.topAnchor, left: self.leftAnchor, paddingTop: 44, paddingLeft: 12,
                        width: 24, height: 24)
        
        addShadow()
        
        titleLabel.centerY(inView: backButton)  // centre titleLabel with respect to back button
        titleLabel.centerX(inView: self)
        
        startingLocationTextField.setConstraints(top: backButton.bottomAnchor, left: self.leftAnchor,
                                                 right: self.rightAnchor, paddingTop: 4, paddingLeft: 40,
                                                 paddingRight: 40, height: 30)
        
        destinationLocationTextField.setConstraints(top: startingLocationTextField.bottomAnchor, left: self.leftAnchor,
                                                 right: self.rightAnchor, paddingTop: 12, paddingLeft: 40,
                                                    paddingRight: 40, height: 30)
        
        startLocationIndicatorView.centerY(inView: startingLocationTextField,
                                           leftAnchor: self.leftAnchor, paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        
        destinationIndicatorView.centerY(inView: destinationLocationTextField,
                                           leftAnchor: self.leftAnchor, paddingLeft: 20)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.setConstraints(top: startLocationIndicatorView.bottomAnchor, bottom: destinationIndicatorView.topAnchor,
                                   paddingTop: 4, paddingBottom: 4, width: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Properties
    weak var delegate: LocationInputViewDelegate?
    
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        // set image in it's original color without default tint color
        button.setImage(UIImage(named: "arrow_back")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackBtnTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SAQIB"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    // The reason for lazy var that we add a padding view to have a padding from left
    private lazy var startingLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .systemGroupedBackground
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isEnabled = false  // It will show user current location here. User cannot change it
        
        // Insert padding to the left of text field
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination..."
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    
    // MARK: - Selectors
    @objc func handleBackBtnTapped() {
        delegate?.dismissLocationInputView()
    }
}
