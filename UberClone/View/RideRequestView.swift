//
//  RideRequestView.swift
//  UberClone
//


import UIKit
import MapKit



protocol RideRequestViewDelegate: AnyObject {
    func uploadTrip(_ view: RideRequestView)
}



enum RideRequestViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}



enum ButtonAction: CustomStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
        case .requestRide: return "CONFIRM UBERX"
        case .cancel: return "CANCEL RIDE"
        case .getDirections: return "GET DIRECTIONS"
        case .pickup: return "PICKUP PASSENGER"
        case .dropOff: return "DROPOFF PASSENGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}






class RideRequestView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.setConstraints(top: self.topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.setConstraints(top: stack.bottomAnchor, paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
        addSubview(uberXLabel)
        uberXLabel.centerX(inView: self)
        uberXLabel.setConstraints(top: infoView.bottomAnchor, paddingTop: 8)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.setConstraints(top: uberXLabel.bottomAnchor, left: leftAnchor,
                                     right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(confirmBtn)
        confirmBtn.centerX(inView: self)
        confirmBtn.setConstraints(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor,
                                  paddingLeft: 12, paddingBottom: 12, paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Properties
    weak var delegate: RideRequestViewDelegate?
    var config = RideRequestViewConfiguration()
    var buttonAction = ButtonAction()
    var user: User?
    
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(inView: view)
        infoViewLabel.centerY(inView: view)
        
        return view
    }()
    
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    private let uberXLabel: UILabel = {
        let label = UILabel()
        label.text = "UberX"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
        
    private let confirmBtn: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(confirmBtnPressed), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Selectors
    @objc func confirmBtnPressed() {
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            print("DEBUG: Handle Cancel...")
        case .getDirections:
            print("DEBUG: Handle Get Directions...")
        case .pickup:
            print("DEBUG: Handle Pickup...")
        case .dropOff:
            print("DEBUG: Handle Dropoff...")
        }
        
    }
    
    
    func configureUI(withConfig config: RideRequestViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            confirmBtn.setTitle(buttonAction.description, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                titleLabel.text = "En Route to Passenger"
                buttonAction = .getDirections
                confirmBtn.setTitle(buttonAction.description, for: .normal)
            } else {
                titleLabel.text = "Driver En Route"
                buttonAction = .cancel
                confirmBtn.setTitle(buttonAction.description, for: .normal)
            }
            infoViewLabel.text = String(user.fullName.first ?? "X")
            uberXLabel.text = user.fullName
        case .pickupPassenger:
            titleLabel.text = "Arrived at Passenger location"
            buttonAction = .pickup
            confirmBtn.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                confirmBtn.setTitle("TRIP IN PROGRESS", for: .normal)
                confirmBtn.isEnabled = false
            } else {
                buttonAction = .getDirections
                confirmBtn.setTitle(buttonAction.description, for: .normal)
            }
            titleLabel.text = "En Route to Destination"
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                confirmBtn.setTitle("ARRIVED AT DESTINATION", for: .normal)
                confirmBtn.isEnabled = false
            } else {
                buttonAction = .dropOff
                confirmBtn.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
}
