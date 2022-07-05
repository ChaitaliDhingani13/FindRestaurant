//
//  ListTblCell.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import Cosmos
import SDWebImage

class ListTblCell: UITableViewCell {

    @IBOutlet weak var resImg: UIImageView!
    @IBOutlet weak var resNameLbl: UILabel!
    @IBOutlet weak var resRatingLbl: UILabel!
    @IBOutlet weak var resDistanceLbl: UILabel!
    @IBOutlet weak var resRatingView: CosmosView!
    @IBOutlet weak var resAddressLbl: UILabel!
    @IBOutlet weak var resOpenNowLbl: UILabel!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    private let objManager = LikedRestaurantManager()

    var googlePlace: GooglePlace? {
        
        willSet {
            self.googlePlace = newValue
            self.setupGooglePlaceData()
        }
        
    }
    
    var wishList: LikedRestaurantModel? {
        
        willSet {
            self.wishList = newValue
            self.setupLikedRestaurant()
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func setupGooglePlaceData() {
        
        let photoreference = googlePlace?.photos[0].photoReference
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=5184&photoreference=\(photoreference ?? "")&key=\(googleApiKey)"

        self.resImg.sd_setImage(with: URL(string: urlString), completed: nil)
        self.resNameLbl.text = googlePlace?.name
        self.resRatingLbl.text = "Rating"
        self.resDistanceLbl.text = "5.5 Miles"
        self.resRatingView.rating = googlePlace?.rating ?? 5
        self.resAddressLbl.text = googlePlace?.address
        self.resOpenNowLbl.text = "Open Now"
        if objManager.checkIfLikedRestaurantExist(id: googlePlace?.reference ?? "") {
            self.likeBtn.setImage(UIImage(named: "icn_like"), for: .normal)
        } else {
            self.likeBtn.setImage(UIImage(named: "ic_dislike"), for: .normal)
        }
        
    }
    
    private func setupLikedRestaurant() {
        
        let photoreference = wishList?.photoReference
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=5184&photoreference=\(photoreference ?? "")&key=\(googleApiKey)"

        self.resImg.sd_setImage(with: URL(string: urlString), completed: nil)
        self.resNameLbl.text = wishList?.name
        self.resRatingLbl.text = "Rating"
        self.resDistanceLbl.text = "5.5 Miles"
        self.resRatingView.rating = wishList?.rating ?? 5
        self.resAddressLbl.text = wishList?.address
        self.resOpenNowLbl.text = "Open Now"
    
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
