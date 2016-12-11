//
//  MemoCell.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/14.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class MemoCell: UITableViewCell {
    
    var userData = UserDefaults.standard
    let user = NCMBUser.current()
    var fav : Favorite = Favorite()
    let star_on = UIImage(named: "myMenu_on")
    let star_off = UIImage(named: "myMenu_off")
    
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var updateDate: UILabel!
    
    // 隠し
    @IBOutlet weak var objectID: UILabel!
    @IBOutlet weak var fileName: UILabel!
    
    @IBOutlet weak var favoriteCounter: UILabel!
    @IBOutlet weak var lookCounter: UILabel!
    @IBOutlet weak var lookCounterLabel: UILabel!
    @IBOutlet weak var favoriteCounterLabel: UILabel!
    
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuCost: UILabel!
    
    @IBAction func likeButton(_ sender: UIButton) {

        Favorite.load()
        
        if Favorite.inFavorites("\(fileName.text!)") {
            
            Favorite.remove("\(fileName.text!)")
            print("dislike")
            favButton.setImage(star_off, for: .normal)
            var favoriteNum = Int(favoriteCounter.text!)!
            
            favoriteNum -= 1
            
            // cloud上のfavListの更新
            let tmpFav = Favorite.favorites
            user?.setObject(tmpFav, forKey: "favList")
            user?.saveInBackground({(error) in
                
                if error == nil {
                    print("cloud上に保存")
                }
                
            })
            
            // 値の更新
            var saveError: NSError? = nil
            let obj: NCMBObject = NCMBObject(className: "MemoClass")
            obj.objectId = objectID.text!
            obj.fetchInBackground({(error) in
                
                if (error == nil) {
                    
                    obj.setObject(favoriteNum, forKey: "favoriteCounter")
                    obj.save(&saveError)
                    
                }
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
                
            })
        } else {
            
            Favorite.add("\(fileName.text!)")
            print("like")
            favButton.setImage(star_on, for: .normal)
            
            var favoriteNum = Int(favoriteCounter.text!)!
            
            favoriteNum += 1
            
            // cloud上のfavListの更新
            let tmpFav = Favorite.favorites
            user?.setObject(tmpFav, forKey: "favList")
            user?.saveInBackground({(error) in
            
                if error == nil {
                    print("cloud上に保存")
                }
            
            })

            
            // 値の更新
            var saveError: NSError? = nil
            let obj: NCMBObject = NCMBObject(className: "MemoClass")
            obj.objectId = objectID.text!
            obj.fetchInBackground({(error) in
                
                if (error == nil) {
                    
                    obj.setObject(favoriteNum, forKey: "favoriteCounter")
                    obj.save(&saveError)
                    
                }
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
                
            })
        }
        
        print("端末データの確認\((userData.object(forKey: "favorites") as? [String])!)")
    }

    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
