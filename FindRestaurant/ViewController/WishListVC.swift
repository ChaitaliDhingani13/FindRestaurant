//
//  WishListVC.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit

class WishListVC: UIViewController, ListTableDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    var wishListArr : [LikedRestaurantModel] = []
    @IBOutlet weak var noDataFound: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        self.noDataFound.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    
    private func setUpNavigationBar() {
        self.navigationItem.title = "Wish List"
        self.navigationItem.titleView?.tintColor = ColorUtility.shared.themeColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setUpUI()

    }
    func setUpUI() {
        tblView.register(UINib(nibName: "ListTblCell", bundle: nil), forCellReuseIdentifier: "ListTblCell")
        self.getWishListData()
        
    }
    func getWishListData() {
        wishListArr = LikedRestaurantManager.shared.getAllLikedRestaurantRecords() ?? []
        if wishListArr.count == 0 {
            self.noDataFound.isHidden = false
            self.tblView.isHidden = true
        } else {
            self.noDataFound.isHidden = true
            self.tblView.isHidden = false
        }
        self.tblView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension WishListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishListArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension//150
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTblCell", for: indexPath) as! ListTblCell
        let dict = wishListArr[indexPath.row]
        cell.index = indexPath.row
        cell.delegate = self
        cell.wishList = dict
        cell.selectionStyle = .none
        return cell
    }
    
    func listLikeBtnClick(index: Int) {
        let dict = wishListArr[index]
        let _ = LikedRestaurantManager.shared.deleteLikedRestaurant(id: dict.id ?? "")
        self.getWishListData()

    }
    
    func listDirectionBtnClick(index: Int) {
        let dict = wishListArr[index]
        let vc = Storyboard.MAIN.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.placeDict = dict
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
