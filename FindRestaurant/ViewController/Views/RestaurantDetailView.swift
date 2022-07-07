//
//  RestaurantDetailView.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 07/07/22.
//

import UIKit
import Cosmos

class RestaurantDetailView: UIView {

    
    @IBOutlet weak var resImg: UIImageView!
    @IBOutlet weak var resNameLbl: UILabel!
    @IBOutlet weak var resRatingLbl: UILabel!
    @IBOutlet weak var resDistanceLbl: UILabel!
    @IBOutlet weak var resRatingView: CosmosView!
    @IBOutlet weak var resAddressLbl: UILabel!
    @IBOutlet weak var resOpenNowLbl: UILabel!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    private var objManager = LikedRestaurantManager()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    class func getGooglePlaceData(frame: CGRect, placeDetail: GooglePlace?, index: Int) -> RestaurantDetailView {
        
        let viewFromXib = Bundle.main.loadNibNamed("RestaurantDetailView", owner: self, options: nil)![0] as! RestaurantDetailView
        viewFromXib.frame = frame
        let photoreference = placeDetail?.photos[0].photoReference
        let urlString = APIHelper.baseUrl + "place/photo?maxwidth=5184&photoreference=\(photoreference ?? "")&key=\(googleApiKey)"

        let dis = CalculateDistance.sharedInstance.distanceInMile(source: currentLocation, destination: placeDetail?.coordinate)

        viewFromXib.resImg.sd_setImage(with: URL(string: urlString), completed: nil)
        viewFromXib.resNameLbl.text = placeDetail?.name
        viewFromXib.resRatingLbl.text = "Rating"
        viewFromXib.resDistanceLbl.text = "\(dis) Miles"
        viewFromXib.resRatingView.rating = placeDetail?.rating ?? 5
        viewFromXib.resAddressLbl.text = placeDetail?.address
        viewFromXib.likeBtn.tag = index
        viewFromXib.directionBtn.tag = index
        if placeDetail?.openingHours.openNow ?? false {
            viewFromXib.resOpenNowLbl.textColor = .blue
            viewFromXib.resOpenNowLbl.text = "Open Now"

        } else {
            viewFromXib.resOpenNowLbl.textColor = .red
            viewFromXib.resOpenNowLbl.text = "Close"

        }
        if viewFromXib.objManager.checkIfLikedRestaurantExist(id: placeDetail?.reference ?? "") {
            viewFromXib.likeBtn.setImage(UIImage(named: "icn_like"), for: .normal)
        } else {
            viewFromXib.likeBtn.setImage(UIImage(named: "ic_dislike"), for: .normal)
        }
        
            return viewFromXib
    }
    class func getWishListPlaceData(frame: CGRect, wishList: LikedRestaurantModel?, index: Int) -> RestaurantDetailView {
        let viewFromXib = Bundle.main.loadNibNamed("RestaurantDetailView", owner: self, options: nil)![0] as! RestaurantDetailView
        viewFromXib.frame = frame
        let photoreference = wishList?.photoReference
        let urlString = APIHelper.baseUrl + "place/photo?maxwidth=5184&photoreference=\(photoreference ?? "")&key=\(googleApiKey)"
        viewFromXib.resImg.sd_setImage(with: URL(string: urlString), completed: nil)
        viewFromXib.resNameLbl.text = wishList?.name
        viewFromXib.resRatingLbl.text = "Rating"
        viewFromXib.resDistanceLbl.text = "\(wishList?.distance ?? 0.0) Miles"
        viewFromXib.resRatingView.rating = wishList?.rating ?? 5
        viewFromXib.resAddressLbl.text = wishList?.address
        viewFromXib.likeBtn.tag = index
        viewFromXib.directionBtn.tag = index

        if wishList?.openNow ?? false {
            viewFromXib.resOpenNowLbl.textColor = .blue
            viewFromXib.resOpenNowLbl.text = "Open Now"
            
        } else {
            viewFromXib.resOpenNowLbl.textColor = .red
            viewFromXib.resOpenNowLbl.text = "Close"
            
        }
        if viewFromXib.objManager.checkIfLikedRestaurantExist(id: wishList?.id ?? "") {
            viewFromXib.likeBtn.setImage(UIImage(named: "icn_like"), for: .normal)
        } else {
            viewFromXib.likeBtn.setImage(UIImage(named: "ic_dislike"), for: .normal)
        }
        return viewFromXib
    }
  
}
