//
//  NearByVC.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import GoogleMaps

class NearByVC: UIViewController {
    
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var mapListView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet private weak var mapView: GMSMapView!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1500
    private var googlePlaceArr: [GooglePlace] = []
    private let objManager = LikedRestaurantManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationBar()
        listView.isHidden = false
        mapListView.isHidden = true

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.setUpMap()
        self.setUpUI()

    }
    func setUpUI() {
        tblView.register(UINib(nibName: "ListTblCell", bundle: nil), forCellReuseIdentifier: "ListTblCell")
    }
    
    func setUpMap() {
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            //          mapView.isMyLocationEnabled = true
            //          mapView.settings.myLocationButton = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.delegate = self
    }
    
    private func setUpNavigationBar() {
        let MapButton = UIButton(type: .custom)
        MapButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let mapIcon = UIImage(named: "icn_map")
        MapButton.setBackgroundImage(mapIcon, for: .normal)
        
        MapButton.tintColor = UIColor(hexString: "282f58")
        MapButton.addTarget(self, action: #selector(mapBtnClick(sender:)), for: .touchUpInside)
        if #available(iOS 11, *) {
            MapButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
            MapButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        }
        let MapBarBtn = UIBarButtonItem(customView: MapButton)
        
        
        let ListButton = UIButton(type: .custom)
        ListButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let ListIcon = UIImage(named: "icn_list")
        ListButton.setBackgroundImage(ListIcon, for: .normal)
        ListButton.tintColor = UIColor(hexString: "282f58")
        ListButton.addTarget(self, action: #selector(listBtnClick(sender:)), for: .touchUpInside)
        if #available(iOS 11, *) {
            ListButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
            ListButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        }
        let ListBarBtn = UIBarButtonItem(customView: ListButton)
        var rightBarButtonItems = [UIBarButtonItem]()
        rightBarButtonItems.append(MapBarBtn)
        rightBarButtonItems.append(ListBarBtn)
        
        if rightBarButtonItems.count > 0 {
            self.navigationItem.rightBarButtonItems = rightBarButtonItems
        } else {
            self.navigationItem.rightBarButtonItems = nil
        }
        self.navigationItem.title = "Nearby Restaurants"
        self.navigationItem.titleView?.tintColor = UIColor(hexString: "282f58")
    }
    
    @objc func mapBtnClick(sender: AnyObject){
        mapListView.isHidden = false
        listView.isHidden = true
    }
    
    @objc func listBtnClick(sender: AnyObject){
        mapListView.isHidden = true
        listView.isHidden = false
    }
    //    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
    //      let geocoder = GMSGeocoder()
    //
    //      geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
    //
    //
    //
    //      }
    //    }
    func fetchPlaces(near coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        
        dataProvider.fetchPlaces(
            near: coordinate,
            radius: searchRadius
        ) { places in
            self.googlePlaceArr = places
            self.tblView.reloadData()
            places.forEach { place in
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
            }
            
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NearByVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googlePlaceArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension//150
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTblCell", for: indexPath) as! ListTblCell
        let dict = googlePlaceArr[indexPath.row]
        cell.googlePlace = dict
        
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func likeBtnClick(sender: UIButton) {
        let dict = googlePlaceArr[sender.tag]
        
        if !objManager.checkIfLikedRestaurantExist(id: dict.reference) {
            objManager.createLikedRestaurantRecord(likedRestaurant: LikedRestaurantModel(name: dict.name, address: dict.address, photoReference: dict.photos[0].photoReference, distance: 0.0, rating: dict.rating, openNow: dict.openingHours.openNow, id: dict.reference))

        } else {
            objManager.deleteLikedRestaurant(id: dict.reference)
        }
        self.tblView.reloadData()
    }
}

// MARK: - CLLocationManagerDelegate
extension NearByVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        locationManager.requestLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(
            target: location.coordinate,
            zoom: 15,
            bearing: 0,
            viewingAngle: 0)
        fetchPlaces(near: location.coordinate)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - GMSMapViewDelegate
extension NearByVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //    reverseGeocode(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //    addressLabel.lock()
        
        if gesture {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }
        
        infoView.nameLabel.text = placeMarker.place.name
        infoView.addressLabel.text = placeMarker.place.address
        
        return infoView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}
