//
//  NearByVC.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import GoogleMaps
import Cosmos

class NearByVC: UIViewController {
    
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var mapListView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet private weak var mapView: GMSMapView!
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProviderModel()
    private let searchRadius: Double = 1500
    private var googlePlaceArr: [GooglePlace] = []
    private let objManager = LikedRestaurantManager()
    
    
    @IBOutlet weak var resImg: UIImageView!
    @IBOutlet weak var resNameLbl: UILabel!
    @IBOutlet weak var resRatingLbl: UILabel!
    @IBOutlet weak var resDistanceLbl: UILabel!
    @IBOutlet weak var resRatingView: CosmosView!
    @IBOutlet weak var resAddressLbl: UILabel!
    @IBOutlet weak var resOpenNowLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewHC: NSLayoutConstraint!
    
    var placeDict: GooglePlace? = nil
    
    //    let placeDict: GooglePlace?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpNavigationBar()
        listView.isHidden = false
        mapListView.isHidden = true
        detailView.isHidden = true
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
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
    
    @IBAction func directionButtonClick(_ sender: UIButton) {

        if self.googlePlaceArr.count > 0 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: placeDict?.coordinate)
            placeDict = self.googlePlaceArr[0]
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
        
        
    }
    
    @IBAction func likeBtnClick(_ sender: UIButton) {
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
        if objManager.checkIfLikedRestaurantExist(id: placeDict?.reference ?? "") {
            self.likeBtn.setImage(UIImage(named: "icn_like"), for: .normal)
        } else {
            self.likeBtn.setImage(UIImage(named: "ic_dislike"), for: .normal)
        }
    }
    
    func fetchPlaces(near coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        var bounds = GMSCoordinateBounds()
        dataProvider.fetchPlaces(coordinate: coordinate) { googlePlaceArr in
            self.googlePlaceArr = googlePlaceArr
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
                self.setDataMap(self.googlePlaceArr[0])
            }
        }
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
        cell.googlePlace = dict
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeButtonClick), for: .touchUpInside)
        cell.directionBtn.tag = indexPath.row
        cell.directionBtn.addTarget(self, action: #selector(directionBtnClick), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func directionBtnClick(sender: UIButton) {
        let dict = googlePlaceArr[sender.tag]
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
    
    @objc func likeButtonClick(sender: UIButton) {
        let dict = googlePlaceArr[sender.tag]
        
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
    
}

// MARK: - GMSMapViewDelegate
extension NearByVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let placeMarker = marker as? PlaceMarker
        placeDict = placeMarker?.place
        self.setDataMap(placeDict)
        return false
    }
    
    func setDataMap(_ placeDict: GooglePlace?) {
        let photoreference = placeDict?.photos[0].photoReference
        let urlString = APIHelper.baseUrl + "place/photo?maxwidth=5184&photoreference=\(photoreference ?? "")&key=\(googleApiKey)"

        self.resImg.sd_setImage(with: URL(string: urlString), completed: nil)
        self.resNameLbl.text = placeDict?.name
        self.resRatingLbl.text = "Rating"
        let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: placeDict?.coordinate)
        self.resDistanceLbl.text = "\(dis) Miles"
        self.resRatingView.rating = placeDict?.rating ?? 5
        self.resAddressLbl.text = placeDict?.address
        if placeDict?.openingHours.openNow ?? false {
            self.resOpenNowLbl.textColor = .blue
            self.resOpenNowLbl.text = "Open Now"

        } else {
            self.resOpenNowLbl.textColor = .red
            self.resOpenNowLbl.text = "Close"

        }
        if objManager.checkIfLikedRestaurantExist(id: placeDict?.reference ?? "") {
            self.likeBtn.setImage(UIImage(named: "icn_like"), for: .normal)
        } else {
            self.likeBtn.setImage(UIImage(named: "ic_dislike"), for: .normal)
        }
        detailView.isHidden = false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}
