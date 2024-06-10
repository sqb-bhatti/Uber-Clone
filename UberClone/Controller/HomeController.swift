//
//  HomeController.swift
//  UberClone
//


import UIKit
import Firebase
import MapKit


private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"


private enum ActionBtnConfiguration {
    case sideMenu
    case dismissActionView
    
    init() {
        self = .sideMenu  // Initially 'actionButton' functionality will be to open Side Menu
    }
}


class HomeController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationsHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200
    private final let rideActionViewHeight: CGFloat = 300
    private var searchResults = [MKPlacemark]()
    private var actionBtnConfig = ActionBtnConfiguration()
    private var route: MKRoute?
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(actionBtnTapped), for: .touchUpInside)
        return btn
    }()
    
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
            } else {
                observeTrips()
            }
        }
    }
    
    
    private var trip: Trip? {
        didSet {
            guard let trip = trip else { return }
            let controller = PickupController(trip: trip)
            controller.delegate = self
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserLoggedIn()
        enableLocationServices()
//        signOut()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let trip = trip else { return }
        print("Trip state is \(trip.state)")
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
            configure()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } catch {
            print("Error Signing out")
        }
    }
    
    
    func configure() {
        configureUI()
        fetchUserData()
    }
    
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(actionButton)
        
        actionButton.setConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                                    paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        configureTableView()
    }
    
    
    func configureLocationInputActivationView() {
        view.addSubview(inputActivationView)
        
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.setConstraints(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.delegate = self
        inputActivationView.alpha = 0
        
        // Animate the appearance of location input view
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.delegate = self
        locationInputView.setConstraints(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor,
                            height: locationInputViewHeight)
        
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight // tableView will get display under inputView
            })
        }
    }
    
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        
        rideActionView.delegate = self
        
        print("view.frame.height: \(view.frame.height)")
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
    }
    
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
    }
    
    
    fileprivate func configureActionBtn(config: ActionBtnConfiguration) {
        switch config {
        case .sideMenu:
            self.actionButton.setImage(UIImage(named: "menu")?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionBtnConfig = .sideMenu
        case .dismissActionView:
            actionButton.setImage(UIImage(named: "arrow_back")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionBtnConfig = .dismissActionView
        }
    }
    
    
    @objc func actionBtnTapped() {
        switch actionBtnConfig {
        case .sideMenu:
            print("DEBUG: Handle Side Menu")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionBtn(config: .sideMenu)
                // Hide the Ride action view from where user can confirm the ride
                self.presentRideActionView(shouldShow: false)
            }
            // zooms out and show all the annotations
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    
    // MARK: - Firebase API
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(coordinate: coordinate, uid: driver.uid)
            print("DEBUG: Driver Coordinate is \(coordinate)")
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    
                    if driverAnno.uid == driver.uid {  // means driver is already visible on map. Update Annotation mark on Map with animation
                        driverAnno.updateAnnotationPosition(withCordinate: coordinate)
                        return true
                    }
                    return false
                })
            }
            
            if !driverIsVisible {
                //Add the above annotation to MapView
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    func observeTrips() {
        Service.shared.observeTrips { (trip) in
            self.trip = trip
        }
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height // this will hide the tableView
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    
    func presentRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil) {
        if shouldShow {
            guard let destination = destination else { return }
            self.rideActionView.destination = destination
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height - self.rideActionViewHeight
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
}






// MARK: - Location Services
extension HomeController {

    func enableLocationServices() {
//        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not Determined")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Authorize always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}





// MARK: - MKMapView Delegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}







private extension HomeController {
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()  // Local search based on User's location
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach ({ (item) in
                results.append(item.placemark)
            })
            completion(results)
        }
    }
    
    
    // generate a geometric route from source to destination
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { response, error in
            guard let response = response else { return }
            
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { (annotation) in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}




extension HomeController: LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        inputActivationView.alpha = 0  // Hide the view before showing LocationInputView
        configureLocationInputView()
    }
}




extension HomeController: LocationInputViewDelegate {
    
    // This delegate method gets called when user clicks on Back button
    func dismissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.inputActivationView.alpha = 1
            })
        }
    }
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (placemarks) in
            self.searchResults = placemarks
            self.tableView.reloadData()
        }
    }
}





// MARK: - TableViewDelegate/TableViewDelegate
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        //var annotations = [MKAnnotation]()
        
        // When user selects a row from a tableView results, actionButton functionality will be to dismiss
        configureActionBtn(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            // zooms in to show the selected place annotation
            // filter out the driver annotations because we want to show user location annotation and point annotatiob
            let annotations = self.mapView.annotations.filter( { !$0.isKind(of: DriverAnnotation.self)})
            
//            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            
            
            // Show the Ride action view from where user can confirm the ride
            // Pass the selected destination as well to show in the Ride Action View
            self.presentRideActionView(shouldShow: true, destination: selectedPlacemark)
            
        }
    }
}




// Mark - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (err, ref) in
            if let error = err {
                print("DEBUG: Failed to upload trip with \(error)")
                return
            }
            
            print("DEBUG: Did upload trip successfully")
        }
    }
}






// Mark - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    
    func didAcceptTrip(_ trip: Trip) {
        self.trip?.state = .accepted
        self.dismiss(animated: true, completion: nil)
    }
}
