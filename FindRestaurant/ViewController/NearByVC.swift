//
//  NearByVC.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import GoogleMaps
import Cosmos

class NearByVC: UIViewController, ListTableDelegate {
    @IBOutlet weak var detailResView: RestaurantDetailView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var mapListView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet private weak var mapView: GMSMapView!
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProviderModel()
    private let searchRadius: Double = 1500
    private var googlePlaceArr: [GooglePlace] = []
    private let objManager = LikedRestaurantManager()
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewHC: NSLayoutConstraint!
    @IBOutlet weak var noDataFound: UILabel!
    
    var placeDict: GooglePlace? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBar()
        listView.isHidden = false
        mapListView.isHidden = true
        detailView.isHidden = true
        noDataFound.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setUpMap()
        self.setUpUI()
        self.tblView.reloadData()
        
    }
    func setUpUI() {
        tblView.register(UINib(nibName: "ListTblCell", bundle: nil), forCellReuseIdentifier: "ListTblCell")
    }
    
    func setUpMap() {
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                switch self.locationManager.authorizationStatus {
                case .notDetermined:
                    print("notDetermined")

                case .restricted:
                    print("restricted")

                case .denied:
                    let alert = UIAlertController(title: "", message: Constant.Location_Permission, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Open Setting", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        case .cancel:
                            print("cancel")
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        case .destructive:
                            print("destructive")
                            
                        @unknown default:
                            print("error")
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.locationManager.requestAlwaysAuthorization()
                    self.locationManager.requestWhenInUseAuthorization()
                    self.locationManager.startUpdatingLocation()
                @unknown default:
                    break
                }
            }
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
        if self.googlePlaceArr.count > 0 {
            self.placeDict = googlePlaceArr[0]
            self.setDataMap(self.placeDict)
        }
        mapListView.isHidden = false
        listView.isHidden = true
    }
    
    @objc func listBtnClick(sender: AnyObject){
        self.tblView.reloadData()
        mapListView.isHidden = true
        listView.isHidden = false
    }
    
    func fetchPlaces(near coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        var bounds = GMSCoordinateBounds()
        dataProvider.fetchPlaces(coordinate: coordinate) { googlePlaceArr in
            self.googlePlaceArr = googlePlaceArr
            if googlePlaceArr.count == 0 {
                self.noDataFound.isHidden = false
                self.tblView.isHidden = true
            } else {
                self.noDataFound.isHidden = true
                self.tblView.isHidden = false
            }
            self.tblView.reloadData()
            self.googlePlaceArr.forEach { place in
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
                bounds = bounds.includingCoordinate(marker.position)
                
            }
            self.mapView.setMinZoom(1, maxZoom: 15)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            self.mapView.animate(with: update)
            
            if self.googlePlaceArr.count > 0 {
                self.placeDict = googlePlaceArr[0]
                self.setDataMap(self.placeDict)
            }
        }
    }
    func setDataMap(_ placeDict: GooglePlace?) {
        detailView.isHidden = false
        for view in detailResView.subviews {
            if view is RestaurantDetailView {
                view.removeFromSuperview()
            }
        }
        let view = RestaurantDetailView.getGooglePlaceData(frame: detailResView.frame, placeDetail: placeDict, index: 0)
        view.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
        view.directionBtn.addTarget(self, action: #selector(directionBtnClick), for: .touchUpInside)
        
        self.detailResView.addSubview(view)
    }
    
}

// MARK: - UITableViewDelegate
extension NearByVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource

extension NearByVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googlePlaceArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTblCell", for: indexPath) as! ListTblCell
        let dict = googlePlaceArr[indexPath.row]
        cell.index = indexPath.row
        cell.googlePlace = dict
        cell.delegate = self
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func listLikeBtnClick(index: Int) {
        let dict = googlePlaceArr[index]
        
        if !objManager.checkIfLikedRestaurantExist(id: dict.reference) {
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: dict.coordinate)
            
            objManager.createLikedRestaurantRecord(likedRestaurant: LikedRestaurantModel(name: dict.name,
                                                                                         address: dict.address,
                                                                                         photoReference: dict.photos[0].photoReference,
                                                                                         distance: dis,
                                                                                         rating: dict.rating,
                                                                                         latitude: dict.coordinate.latitude,
                                                                                         longitude: dict.coordinate.longitude,
                                                                                         openNow: dict.openingHours.openNow,
                                                                                         id: dict.reference))
            
        } else {
            let _ = objManager.deleteLikedRestaurant(id: dict.reference)
        }
        self.tblView.reloadData()
    }
    
    func listDirectionBtnClick(index: Int) {
        let dict = googlePlaceArr[index]
        let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: dict.coordinate)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let Liked = LikedRestaurantModel(name: dict.name,
                                         address: dict.address,
                                         photoReference: dict.photos[0].photoReference,
                                         distance: dis,
                                         rating: dict.rating,
                                         latitude: dict.coordinate.latitude,
                                         longitude: dict.coordinate.longitude,
                                         openNow: dict.openingHours.openNow,
                                         id: dict.reference)
        vc.placeDict = Liked
        self.navigationController?.pushViewController(vc, animated: true)
        
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let placeMarker = marker as? PlaceMarker
        placeDict = placeMarker?.place
        self.setDataMap(placeDict)
        return false
    }
    
    
    @objc func likeBtnClick() {
        if !objManager.checkIfLikedRestaurantExist(id: placeDict?.reference ?? "") {
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: placeDict?.coordinate)
            
            objManager.createLikedRestaurantRecord(likedRestaurant: LikedRestaurantModel(name: placeDict?.name,
                                                                                         address: placeDict?.address,
                                                                                         photoReference: placeDict?.photos[0].photoReference,
                                                                                         distance: dis,
                                                                                         rating: placeDict?.rating,
                                                                                         latitude: placeDict?.coordinate.latitude,
                                                                                         longitude: placeDict?.coordinate.longitude,
                                                                                         openNow: placeDict?.openingHours.openNow,
                                                                                         id: placeDict?.reference))
            
        } else {
            let _ = objManager.deleteLikedRestaurant(id: placeDict?.reference ?? "")
        }
        if placeDict != nil {
            self.setDataMap(placeDict)
            
        }
    }
    
    @objc func directionBtnClick() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: placeDict?.coordinate)
        let Liked = LikedRestaurantModel(name: placeDict?.name,
                                         address: placeDict?.address,
                                         photoReference: placeDict?.photos[0].photoReference,
                                         distance: dis,
                                         rating: placeDict?.rating,
                                         latitude: placeDict?.coordinate.latitude,
                                         longitude: placeDict?.coordinate.longitude,
                                         openNow: placeDict?.openingHours.openNow,
                                         id: placeDict?.reference)
        
        vc.placeDict = Liked
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}
