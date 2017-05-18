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
    let heart_on = UIImage(named: "like_on")
    let heart_off = UIImage(named: "like_off")
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopGeo: UILabel!
    @IBOutlet weak var shopGeoLabel: UIImageView!
    @IBOutlet weak var updateDate: UILabel!
        @IBOutlet weak var favoriteCounter: UILabel!
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var menuCost: UILabel!
    @IBOutlet weak var hoursColor: UIView!
    
    // 隠し
    @IBOutlet weak var objectID: UILabel!
    @IBOutlet weak var fileName: UILabel!
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        
//        checkUserLogin()
        if userData.object(forKey: "userMail") == nil {
            return
        }
        
        Favorite.load()
        var byAmount = 0
        
        if Favorite.inFavorites("\(fileName.text!)") {
            
            Favorite.remove("\(fileName.text!)")
            favoriteButton.setImage(star_off, for: .normal)
            byAmount = -1
            
        } else {
            
            Favorite.add("\(fileName.text!)")
            favoriteButton.setImage(star_on, for: .normal)
            byAmount = 1
            
        }
        
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
                obj.incrementKey("favoriteCounter", byAmount: byAmount as NSNumber)
                obj.save(&saveError)
            }
            if saveError == nil {
                print("success save data.")
            } else {
                print("failure save data. \(String(describing: saveError))")
            }
        })

        print("端末データの確認\((userData.object(forKey: "likes") as? [String])!)")
    }
    
    @IBAction func likeButton(_ sender: UIButton) {
        
//        checkUserLogin()
        if userData.object(forKey: "userMail") == nil {
            return
        }
        
        Like.load()
        var byAmount = 0
        
        if Like.inLikes("\(fileName.text!)") {
            
            Like.remove("\(fileName.text!)")
            likeButton.setImage(heart_off, for: .normal)
            byAmount = -1
            
        } else {
            
            Like.add("\(fileName.text!)")
            likeButton.setImage(heart_on, for: .normal)
            byAmount = 1
            
        }
        
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
                obj.incrementKey("likeCounter", byAmount: byAmount as NSNumber)
                obj.save(&saveError)
            }
            if saveError == nil {
                print("success save data.")
            } else {
                print("failure save data. \(String(describing: saveError))")
            }
        })
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

    func checkUserLogin(){
        if userData.object(forKey: "userMail") == nil {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main",bundle:nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "SignInView") as UIViewController
            
            window?.rootViewController = nextView
        }
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
