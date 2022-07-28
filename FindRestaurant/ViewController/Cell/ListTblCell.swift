//
//  ListTblCell.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import Cosmos
import SDWebImage

protocol ListTableDelegate {
    func listLikeBtnClick(index: Int)
    func listDirectionBtnClick(index: Int)
}

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
    var delegate: ListTableDelegate?
    var index = Int()
    var googlePlace: GooglePlaceModel? {
        
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
               
        let photoreference = googlePlace?.photos?[0].photoReference
        let urlString = APIHelper.baseUrl + "\(EndPoint.photoAPI.rawValue)\(photoreference ?? "")&key=\(googleApiKey)"

        let dis = CalculateDistance.sharedInstance.distanceInMile(source: LocationManager.shared.currentLocation, destination: googlePlace?.coordinate)

        self.resImg.sd_setImage(with: URL(string: urlString), placeholderImage: ImageUtility.shared.restPlaceImg, completed: nil)
        self.resNameLbl.text = googlePlace?.name
        self.resRatingLbl.text = "Rating"
        self.resDistanceLbl.text = "\(dis) Miles"
        self.resRatingView.rating = googlePlace?.rating ?? 5
        self.resAddressLbl.text = googlePlace?.address
        self.likeBtn.tag = index
        self.directionBtn.tag = index
        if googlePlace?.openingHours?.openNow ?? false {
            self.resOpenNowLbl.textColor = .blue
            self.resOpenNowLbl.text = "Open Now"

        } else {
            self.resOpenNowLbl.textColor = .red
            self.resOpenNowLbl.text = "Close"

        }
        self.likeBtn.setImage(ImageUtility.shared.disLikeImg, for: .normal)
        if LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: googlePlace?.reference ?? "") {
            self.likeBtn.setImage(ImageUtility.shared.likeImg, for: .normal)
        } else {
            self.likeBtn.setImage(ImageUtility.shared.disLikeImg, for: .normal)
        }
        
    }
    
    @IBAction func likeBtnClick(_ sender: UIButton) {
        delegate?.listLikeBtnClick(index: sender.tag)

    }
    @IBAction func directionBtnClick(_ sender: UIButton) {
        delegate?.listDirectionBtnClick(index: sender.tag)
    }
    private func setupLikedRestaurant() {
        let photoreference = wishList?.photoReference
        let urlString = APIHelper.baseUrl + "\(EndPoint.photoAPI.rawValue)\(photoreference ?? "")&key=\(googleApiKey)"
        self.resImg.sd_setImage(with: URL(string: urlString), placeholderImage: ImageUtility.shared.restPlaceImg, completed: nil)
        self.resNameLbl.text = wishList?.name
        self.resRatingLbl.text = "Rating"
        self.resDistanceLbl.text = "\(wishList?.distance ?? 0.0) Miles"
        self.resRatingView.rating = wishList?.rating ?? 5
        self.resAddressLbl.text = wishList?.address
        self.likeBtn.tag = index
        self.directionBtn.tag = index

        if wishList?.openNow ?? false {
            self.resOpenNowLbl.textColor = .blue
            self.resOpenNowLbl.text = "Open Now"
            
        } else {
            self.resOpenNowLbl.textColor = .red
            self.resOpenNowLbl.text = "Close"
            
        }
        self.likeBtn.setImage(ImageUtility.shared.disLikeImg, for: .normal)
        if LikedRestaurantManager.shared.checkIfLikedRestaurantExist(id: wishList?.id ?? "") {
            self.likeBtn.setImage(ImageUtility.shared.likeImg, for: .normal)
        } else {
            self.likeBtn.setImage(ImageUtility.shared.disLikeImg, for: .normal)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
