//
//  ListTblCell.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import Cosmos
import SDWebImage
import CoreLocation

protocol ListTableDelegate {
    func listLikeBtnClick(index: Int)
    func listDirectionBtnClick(index: Int)
}

class ListTblCell: UITableViewCell {

    @IBOutlet weak var view: RestaurantDetailView!
    var delegate: ListTableDelegate?
    var index = Int()
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
        for view in subviews {
            if view is RestaurantDetailView {
               view.removeFromSuperview()
           }
        }

        let view = RestaurantDetailView.getGooglePlaceData(frame: self.contentView.frame, placeDetail: googlePlace, index: index)
        view.directionBtn.tag = index
        view.likeBtn.tag = index
        view.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
        view.directionBtn.addTarget(self, action: #selector(directionBtnClick), for: .touchUpInside)

        self.view.addSubview(view)
    }
    
    @objc func likeBtnClick(_ sender: UIButton) {
        delegate?.listLikeBtnClick(index: sender.tag)

    }
    @objc func directionBtnClick(_ sender: UIButton) {
        delegate?.listDirectionBtnClick(index: sender.tag)
    }
    private func setupLikedRestaurant() {
        let view = RestaurantDetailView.getWishListPlaceData(frame: self.contentView.frame, wishList: wishList, index: index)
        view.directionBtn.tag = index
        view.likeBtn.tag = index
        view.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
        view.directionBtn.addTarget(self, action: #selector(directionBtnClick), for: .touchUpInside)

        self.view.addSubview(view)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
