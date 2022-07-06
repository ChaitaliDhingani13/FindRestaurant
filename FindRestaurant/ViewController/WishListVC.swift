//
//  WishListVC.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit

class WishListVC: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var wishListArr : [LikedRestaurantModel] = []
    private var objManager = LikedRestaurantManager()
    @IBOutlet weak var noDataFound: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavigationBar()
        self.noDataFound.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    
    private func setUpNavigationBar() {
        self.navigationItem.title = "Wish List"
        self.navigationItem.titleView?.tintColor = UIColor(hexString: "282f58")
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
        wishListArr = objManager.getAllLikedRestaurantRecords() ?? []
        if wishListArr.count == 0 {
            self.noDataFound.isHidden = false
            self.tblView.isHidden = true
        } else {
            self.noDataFound.isHidden = true
            self.tblView.isHidden = false
        }
        self.tblView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        cell.wishList = dict
        
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: .touchUpInside)
        
        cell.directionBtn.tag = indexPath.row
        cell.directionBtn.addTarget(self, action: #selector(directionBtnClick), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func directionBtnClick(sender: UIButton) {
        let dict = wishListArr[sender.tag]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapVC") as! MapVC
        vc.placeDict = dict
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @objc func likeBtnClick(sender: UIButton) {
        let dict = wishListArr[sender.tag]
        
        let _ = objManager.deleteLikedRestaurant(id: dict.id ?? "")
        self.getWishListData()
    }
}
