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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpUI()

    }
    func setUpUI() {
        tblView.register(UINib(nibName: "ListTblCell", bundle: nil), forCellReuseIdentifier: "ListTblCell")
        self.getWishListData()
        
    }
    func getWishListData() {
        wishListArr = objManager.getAllLikedRestaurantRecords() ?? []
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
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func likeBtnClick(sender: UIButton) {
        let dict = wishListArr[sender.tag]
        
        objManager.deleteLikedRestaurant(id: dict.id ?? "")
        self.getWishListData()
    }
}
