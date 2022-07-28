//
//  MapVC.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 06/07/22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Cosmos

class MapVC: UIViewController {
    @IBOutlet weak var resImg: UIImageView!
    @IBOutlet weak var resNameLbl: UILabel!
    @IBOutlet weak var resRatingLbl: UILabel!
    @IBOutlet weak var resDistanceLbl: UILabel!
    @IBOutlet weak var resRatingView: CosmosView!
    @IBOutlet weak var resAddressLbl: UILabel!
    @IBOutlet weak var resOpenNowLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    private let dataProvider = GoogleDataProviderModel()
    var placeDict = LikedRestaurantModel()
    var googlePlaceDict: GooglePlaceModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        self.setUpUI()
        self.setUpData()
        // Do any additional setup after loading the view.
    }
    
    private func setUpNavigationBar() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = placeDict.name
        self.navigationItem.titleView?.tintColor = ColorUtility.shared.themeColor
    }
    
    func setUpUI() {
        let desination = CLLocationCoordinate2D(latitude: self.placeDict.latitude ?? 0.0, longitude: self.placeDict.longitude ?? 0.0)
        self.fetchRoute(from: LocationManager.shared.currentLocation, to: desination)
    }
    
    func setUpData() {
        let photoreference = placeDict.photoReference
        let urlString = APIHelper.baseUrl + "\(EndPoint.photoAPI.rawValue)\(photoreference ?? "")&key=\(googleApiKey)"
        self.resImg.sd_setImage(with: URL(string: urlString), placeholderImage: ImageUtility.shared.restPlaceImg, completed: nil)
        self.resNameLbl.text = placeDict.name
        self.resRatingLbl.text = "Rating"
        self.resDistanceLbl.text = "\(placeDict.distance ?? 0.0) Miles"
        self.resRatingView.rating = placeDict.rating ?? 5
        self.resAddressLbl.text = placeDict.address
        if placeDict.openNow ?? false {
            self.resOpenNowLbl.textColor = .blue
            self.resOpenNowLbl.text = "Open Now"
        } else {
            self.resOpenNowLbl.textColor = .red
            self.resOpenNowLbl.text = "Close"
        }
        self.likeBtn.setImage(ImageUtility.shared.likeImg, for: .normal)
        if LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: placeDict.id ?? "") {
            self.likeBtn.setImage(ImageUtility.shared.likeImg, for: .normal)
        } else {
            self.likeBtn.setImage(ImageUtility.shared.disLikeImg, for: .normal)
        }
    }
    
    @IBAction func likeBtnClick(_ sender: UIButton) {
        
        if !LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: placeDict.id ?? "") {
            let desti = CLLocationCoordinate2D(latitude: placeDict.latitude ?? 0.0, longitude: placeDict.longitude ?? 0)
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: desti)
            let rest = LikedRestaurantModel(name: placeDict.name, address: placeDict.address, photoReference: placeDict.photoReference, distance: dis, rating: placeDict.rating, latitude: placeDict.latitude, longitude: placeDict.longitude, openNow: placeDict.openNow, id: placeDict.id)
            LikedRestaurantManager.shared.createLikedRestaurantRecord(likedRestaurant: rest)
            
        } else {
            let _ = LikedRestaurantManager.shared.deleteLikedRestaurant(id: placeDict.id ?? "")
            self.navigationController?.popViewController(animated: true)
        }
        self.setUpData()
    }
    
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        dataProvider.fetchDirection(source: source, destination: destination) { googleMap, error  in
            if error == nil {
                if let direction = googleMap {
                    let routes = direction.routes?.first
                    self.drawPath(from: routes, source: source, destination: destination)
                }
            }else {
                Utility.alert(message: error ?? "")
            }

        }
    }
    func drawPath(from routes: Route?, source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D){
        let path = GMSPath(fromEncodedPath: routes?.overviewPolyline?.points ?? "")
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 6
        polyline.strokeColor = ColorUtility.shared.themeColor
        polyline.geodesic = true
        polyline.map = self.mapView
        let tempBounds = routes?.bounds
        let northeast = CLLocationCoordinate2D(latitude: tempBounds?.northeast?.lat ?? 0.0, longitude: tempBounds?.northeast?.lng ?? 0.0)
        let southwest = CLLocationCoordinate2D(latitude: tempBounds?.southwest?.lat ?? 0.0, longitude: tempBounds?.southwest?.lng ?? 0.0)
        
        let bounds = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        let sourceMarker = GMSMarker()
        
        sourceMarker.position = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        sourceMarker.map = self.mapView
        
        // MARK: Marker for destination location
        let destinationMarker = GMSMarker()
        destinationMarker.icon = ImageUtility.shared.restImg
        destinationMarker.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        destinationMarker.title = self.placeDict.name
        destinationMarker.map = self.mapView
        self.mapView.moveCamera(update)
    }
}
