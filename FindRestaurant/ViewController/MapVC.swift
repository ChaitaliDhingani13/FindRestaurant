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
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var detailResView: RestaurantDetailView!
    
    private let objManager = LikedRestaurantManager()
    
    
    private let dataProvider = GoogleDataProviderModel()
    var placeDict = LikedRestaurantModel()
    var googlePlaceDict: GooglePlace?
    
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
        self.navigationItem.titleView?.tintColor = UIColor(hexString: "282f58")
    }
    
    func setUpUI() {
        let desination = CLLocationCoordinate2D(latitude: self.placeDict.latitude ?? 0.0, longitude: self.placeDict.longitude ?? 0.0)
        self.fetchRoute(from: currentLocation, to: desination)
    }
    
    func setUpData() {
        
        for view in detailResView.subviews {
            if view is RestaurantDetailView {
                view.removeFromSuperview()
            }
        }
        let view = RestaurantDetailView.getWishListPlaceData(frame: detailResView.frame, wishList: placeDict, index: 0)
        view.directionBtn.isHidden = true
        view.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
        self.detailResView.addSubview(view)
        
    }
    
    @objc func likeBtnClick(_ sender: UIButton) {
        
        if !objManager.checkIfLikedRestaurantExist(id: placeDict.id ?? "") {
            let desti = CLLocationCoordinate2D(latitude: placeDict.latitude ?? 0.0, longitude: placeDict.longitude ?? 0)
            let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: desti)
            
            objManager.createLikedRestaurantRecord(likedRestaurant: LikedRestaurantModel(name: placeDict.name, address: placeDict.address, photoReference: placeDict.photoReference, distance: dis, rating: placeDict.rating, latitude: placeDict.latitude, longitude: placeDict.longitude, openNow: placeDict.openNow, id: placeDict.id))
            
        } else {
            let _ = objManager.deleteLikedRestaurant(id: placeDict.id ?? "")
        }
        self.setUpData()
    }
    
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        dataProvider.fetchDirection(source: source, destination: destination) { googleMap in
            if let direction = googleMap {
                let routes = direction.routes.first
                self.drawPath(from: routes, source: source, destination: destination)
            }
        }
    }
    func drawPath(from routes: Route?, source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D){
        let path = GMSPath(fromEncodedPath: routes?.overviewPolyline.points ?? "")
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 6
        polyline.strokeColor = UIColor(hexString: "282f58")
        polyline.geodesic = true
        polyline.map = self.mapView
        let tempBounds = routes?.bounds
        let northeast = CLLocationCoordinate2D(latitude: tempBounds?.northeast.lat ?? 0.0, longitude: tempBounds?.northeast.lng ?? 0.0)
        let southwest = CLLocationCoordinate2D(latitude: tempBounds?.southwest.lat ?? 0.0, longitude: tempBounds?.southwest.lng ?? 0.0)
        
        let bounds = GMSCoordinateBounds(coordinate: northeast, coordinate: southwest)
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        let sourceMarker = GMSMarker()
        
        sourceMarker.position = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        sourceMarker.map = self.mapView
        
        
        // MARK: Marker for destination location
        let destinationMarker = GMSMarker()
        destinationMarker.icon = UIImage(named: "icn_restaurant")
        destinationMarker.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        destinationMarker.title = self.placeDict.name
        destinationMarker.map = self.mapView
        
        self.mapView.moveCamera(update)
    }
}
