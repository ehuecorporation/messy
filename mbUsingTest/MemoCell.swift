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

    let star_on = UIImage(named: "myMenu_on")
    let star_off = UIImage(named: "myMenu_off")
    
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopGeo: UILabel!
    @IBOutlet weak var shopGeoLabel: UIImageView!
    @IBOutlet weak var updateDate: UILabel!
    
    @IBOutlet weak var hoursIcon: UIImageView!
    // 隠し
    @IBOutlet weak var objectID: UILabel!
    @IBOutlet weak var fileName: UILabel!
    
    @IBOutlet weak var favoriteCounter: UILabel!
    @IBOutlet weak var lookCounter: UILabel!

    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var lookCounterLabel: UILabel!
    @IBOutlet weak var favoriteCounterLabel: UILabel!
    @IBOutlet weak var likeCounterLabel: UILabel!
    
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuCost: UILabel!
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        
        Favorite.load()
        
        if Favorite.inFavorites("\(fileName.text!)") {
            
            Favorite.remove("\(fileName.text!)")
            favoriteButton.setImage(star_off, for: .normal)
            
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
            favoriteButton.setImage(star_on, for: .normal)
            
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
        
        print("端末データの確認\((userData.object(forKey: "likes") as? [String])!)")
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        Like.load()
        
        if Like.inLikes("\(fileName.text!)") {
            
            Like.remove("\(fileName.text!)")
            likeButton.setImage(star_off, for: .normal)
            
            var likeNum = Int(likeCounter.text!)!
            likeNum -= 1
            
            // cloud上のfavListの更新
            let tmpLike = Like.likes
            user?.setObject(tmpLike, forKey: "likeList")
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
                    obj.setObject(likeNum, forKey: "likeCounter")
                    obj.save(&saveError)
                }
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
            })
            
        } else {
            
            Like.add("\(fileName.text!)")
            likeButton.setImage(star_on, for: .normal)
            
            var likeNum = Int(likeCounter.text!)!
            likeNum += 1
            
            // cloud上のfavListの更新
            let tmpLike = Like.likes
            user?.setObject(tmpLike, forKey: "likeList")
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
                    obj.setObject(likeNum, forKey: "likeCounter")
                    obj.save(&saveError)
                }
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
            })
        }
        
        print("端末データの確認\((userData.object(forKey: "likes") as? [String])!)")
    }
    
    func menuImageSetter(_ image: UIImage?) {
        
        menuImage.image = image
        
        let constraint = NSLayoutConstraint(
            item: menuImage,
            attribute:NSLayoutAttribute.height,
            relatedBy:NSLayoutRelation.equal,
            toItem: menuImage,
            attribute: NSLayoutAttribute.width,
            multiplier: (image?.size.height)! / (image?.size.width)!,
            constant:0)
        
        NSLayoutConstraint.activate([constraint])
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
