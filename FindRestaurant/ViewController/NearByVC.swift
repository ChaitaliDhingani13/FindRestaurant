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
    
    @IBOutlet weak var resImg: UIImageView!
    @IBOutlet weak var resNameLbl: UILabel!
    @IBOutlet weak var resRatingLbl: UILabel!
    @IBOutlet weak var resDistanceLbl: UILabel!
    @IBOutlet weak var resRatingView: CosmosView!
    @IBOutlet weak var resAddressLbl: UILabel!
    @IBOutlet weak var resOpenNowLbl: UILabel!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var mapListView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet private weak var mapView: GMSMapView!
    private let dataProvider = GoogleDataProviderModel()
    private let searchRadius: Double = 1500
    private var googlePlaceArr: [GooglePlaceModel] = []
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewHC: NSLayoutConstraint!
    @IBOutlet weak var noDataFound: UILabel!
    
    var placeDict: GooglePlaceModel? = nil
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
        LocationManager.shared.start { info in
            print(info)
            let location = CLLocation(latitude: info.latitude ?? 0.0, longitude: info.longitude ?? 0.0)
            self.mapView.camera = GMSCameraPosition(
                target: location.coordinate,
                zoom: 15,
                bearing: 0,
                viewingAngle: 0)
            self.fetchPlaces(near: location.coordinate)
        }
        mapView.delegate = self
    }
    
    private func setUpNavigationBar() {
        let MapButton = UIButton(type: .custom)
        MapButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let mapIcon = ImageUtility.shared.mapImg
        MapButton.setBackgroundImage(mapIcon, for: .normal)
        
        MapButton.tintColor = ColorUtility.shared.themeColor
        MapButton.addTarget(self, action: #selector(mapBtnClick(sender:)), for: .touchUpInside)
        if #available(iOS 11, *) {
            MapButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
            MapButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        }
        let MapBarBtn = UIBarButtonItem(customView: MapButton)
        let ListButton = UIButton(type: .custom)
        ListButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let ListIcon = ImageUtility.shared.listImg
        ListButton.setBackgroundImage(ListIcon, for: .normal)
        ListButton.tintColor = ColorUtility.shared.themeColor
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
        self.navigationItem.titleView?.tintColor = ColorUtility.shared.themeColor
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
                let marker = PlaceMarkerModel(place: place)
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
    func setDataMap(_ placeDict: GooglePlaceModel?) {
        detailView.isHidden = false
        let photoreference = placeDict?.photos?[0].photoReference
        let urlString = APIHelper.baseUrl + "\(EndPoint.photoAPI.rawValue)\(photoreference ?? "")&key=\(googleApiKey)"

        let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: placeDict?.coordinate)

        self.resImg.sd_setImage(with: URL(string: urlString), completed: nil)
        self.resNameLbl.text = placeDict?.name
        self.resRatingLbl.text = "Rating"
        self.resDistanceLbl.text = "\(dis) Miles"
        self.resRatingView.rating = placeDict?.rating ?? 5
        self.resAddressLbl.text = placeDict?.address
        if placeDict?.openingHours?.openNow ?? false {
            self.resOpenNowLbl.textColor = .blue
            self.resOpenNowLbl.text = "Open Now"

        } else {
            self.resOpenNowLbl.textColor = .red
            self.resOpenNowLbl.text = "Close"

        }
        if LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: placeDict?.reference ?? "") {
            self.likeBtn.setImage(ImageUtility.shared.likeImg, for: .normal)
        } else {
            self.likeBtn.setImage(ImageUtility.shared.disLikeImg, for: .normal)
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
        cell.index = indexPath.row
        cell.googlePlace = dict
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    
    func listLikeBtnClick(index: Int) {
        let dict = googlePlaceArr[index]
        
        if !LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: dict.reference ?? "") {
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: dict.coordinate)
            let res = LikedRestaurantModel(name: dict.name,
                                           address: dict.address,
                                           photoReference: dict.photos?[0].photoReference,
                                           distance: dis,
                                           rating: dict.rating,
                                           latitude: dict.coordinate?.latitude,
                                           longitude: dict.coordinate?.longitude,
                                           openNow: dict.openingHours?.openNow,
                                           id: dict.reference)
            
            LikedRestaurantManager.shared.createLikedRestaurantRecord(likedRestaurant: res)
            
        } else {
            let _ = LikedRestaurantManager.shared.deleteLikedRestaurant(id: dict.reference ?? "")
        }
        self.tblView.reloadData()
    }
    
    func listDirectionBtnClick(index: Int) {
        let dict = googlePlaceArr[index]
        let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: dict.coordinate)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let Liked = LikedRestaurantModel(name: dict.name,
                                         address: dict.address,
                                         photoReference: dict.photos?[0].photoReference,
                                         distance: dis,
                                         rating: dict.rating,
                                         latitude: dict.coordinate?.latitude,
                                         longitude: dict.coordinate?.longitude,
                                         openNow: dict.openingHours?.openNow,
                                         id: dict.reference)
        vc.placeDict = Liked
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

// MARK: - GMSMapViewDelegate
extension NearByVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let placeMarker = marker as? PlaceMarkerModel
        placeDict = placeMarker?.place
        self.setDataMap(placeDict)
        return false
    }
    
    
    @IBAction func likeBtnClick(_ sender: UIButton) {
        if !LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: placeDict?.reference ?? "") {
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: placeDict?.coordinate)
            let likeRes = LikedRestaurantModel(name: placeDict?.name,
                                               address: placeDict?.address,
                                               photoReference: placeDict?.photos?[0].photoReference,
                                               distance: dis,
                                               rating: placeDict?.rating,
                                               latitude: placeDict?.coordinate?.latitude,
                                               longitude: placeDict?.coordinate?.longitude,
                                               openNow: placeDict?.openingHours?.openNow,
                                               id: placeDict?.reference)
            LikedRestaurantManager.shared.createLikedRestaurantRecord(likedRestaurant: likeRes)
            
        } else {
            let _ = LikedRestaurantManager.shared.deleteLikedRestaurant(id: placeDict?.reference ?? "")
        }
        if placeDict != nil {
            self.setDataMap(placeDict)
            
        }
    }
    
    @IBAction func directionBtnClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: placeDict?.coordinate)
        let Liked = LikedRestaurantModel(name: placeDict?.name,
                                         address: placeDict?.address,
                                         photoReference: placeDict?.photos?[0].photoReference,
                                         distance: dis,
                                         rating: placeDict?.rating,
                                         latitude: placeDict?.coordinate?.latitude,
                                         longitude: placeDict?.coordinate?.longitude,
                                         openNow: placeDict?.openingHours?.openNow,
                                         id: placeDict?.reference)
        
        vc.placeDict = Liked
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
}
