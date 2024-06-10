//
//  PickupController.swift
//  UberClone
//


import UIKit
import MapKit


protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}




class PickupController: UIViewController {
    
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureMapView()
    }
    
    
    
    // MARK: - Properties
    private let mapView = MKMapView()
    let trip: Trip
    weak var delegate: PickupControllerDelegate?
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "ic_off_white")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return btn
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("ACCEPT TRIP", for: .normal)
        btn.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return btn
    }()
    
    
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.setConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270 / 2
        mapView.centerX(inView: view)
        mapView.setConstraints(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.setConstraints(top: mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.centerX(inView: view)
        acceptTripButton.setConstraints(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                        paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
    
    
    // MARK: - Selectors
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func handleAcceptTrip() {
        Service.shared.acceptTrip(trip: trip) { Error, ref in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
}
