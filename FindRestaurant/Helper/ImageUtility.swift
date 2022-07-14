//
//  ImageUtility.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 14/07/22.
//

import Foundation
import UIKit
final class ImageUtility {
    static let shared = ImageUtility()
    let likeImg = UIImage(named: "icn_like")
    let disLikeImg = UIImage(named: "ic_dislike")
    let mapImg = UIImage(named: "icn_map")
    let listImg = UIImage(named: "icn_list")
    let restImg = UIImage(named: "icn_restaurant")
}

final class ColorUtility {
    static let shared = ColorUtility()
    let themeColor = UIColor(hexString: "282f58")
    let whiteColor = UIColor.white

}
