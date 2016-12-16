//
//  NCMBSearch.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/03.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import Foundation
import  NCMB

public struct shop {
    
    public var shopName: String = ""
    public var shopNumber: Int = 0
    public var shopLat: Double = 0
    public var shopLon: Double = 0
    public var shopGeo: NCMBGeoPoint = NCMBGeoPoint()
    public var openHours: String = ""
    public var restDay: String = ""
    
}

public struct memo {
    
    public var objectID: String = ""
    public var filename: String = ""
    public var shopName: String = ""
    public var shopNumber: Int = 0
    public var menuMoney: String = ""
    public var menuName: String = ""
    public var menuImage: UIImage? = nil
    public var menuHours: Int = 0
    public var lookCounter: Int = 0
    public var favoriteCounter: Int = 0
    public var postUserIcon: UIImage? = nil
    public var postUser: String = ""
    public var updateDate: String = ""
    
    public var description: String {
        get {
            var string = "\nshopTitle:\(shopName)"
            string += "\nmenuMoney:\(menuMoney)"
            string += "\nmenuName:\(menuName)"
            return string
        }
    }
    
}

public class NCMBSearch {
    
    //近隣店舗のリスト
    public var memos = [memo]()
    
    //お気に入りリスト
    public var favList = [memo]()
    
    //ShopMenu
    public var shopMenu = [memo]()
    
    //PostMenu
    public var postMenu = [memo]()
    
    //店舗データ
    public var shopData = shop()
    
    //近隣店舗のリスト
    public var restaurants = [shop]()
    
    // 全何件か
    public var total = 0
    
    //読込開始のNotification
    open let NCMBLoadStartNotification = "NCMBLoadStartNotification"
    //読込完了のNotification
    open let NCMBLoadCompleteNotification = "NCMBLoadCompleteNotification"
    //画像読込開始のNotification
    open let NCMBImageLoadStartNotification = "NCMBImageLoadStartNotification"
    //画像読込完了のNotification
    open let NCMBImageLoadCompleteNotification = "NCMBImageLoadCompleteNotification"
    //店舗読込開始のNotification
    open let NCMBShopLoadStartNotification = "NCMBShopLoadStartNotification"
    //店舗読込完了のNotification
    open let NCMBShopLoadCompleteNotification = "NCMBShopLoadCompleteNotification"
    
    
    //trueなら読込中
    var loading_flag = false
    
    // 画像を取得
    func getImage(_ targetNum : Int, _ targetList : [memo]) {
        let targetMemoData = targetList[targetNum]
        
        let filename: String = targetMemoData.filename
        let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
        fileData.getDataInBackground {
            (imageData, error) -> Void in
            
            if error != nil {
                print("写真の取得失敗: \(error)")
            } else {
                self.memos[targetNum].menuImage = UIImage(data: imageData!)
            }
        }

    } // getImage end
    
    // 店舗の詳細ページを表示する時に使用
    func getShopData (_ shopNumber: Int) {
        var shopData: shop = shop()
        
        self.shopData = shop()
        
        //API実行
        let query: NCMBQuery = NCMBQuery(className: "test")
        // 与えられた店番号のデータを取ってくる
        query.whereKey("numbaer", equalTo: shopNumber)
        
        //店舗検索を通知
        NotificationCenter.default.post(name: Notification.Name(rawValue: NCMBShopLoadStartNotification), object: nil)
        
        query.findObjectsInBackground({
            (objects, error) in
            
            if error == nil {
                if let response = objects {
                    let targetMemoData: AnyObject = response[0] as AnyObject
                    shopData.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                    shopData.shopNumber = (targetMemoData.object(forKey: "numbaer") as? Int)!
                    shopData.openHours = (targetMemoData.object(forKey: "openHours") as? String)!
                    shopData.restDay = (targetMemoData.object(forKey: "restDay") as? String)!
                    shopData.shopGeo = (targetMemoData.object(forKey: "geoPoint") as? NCMBGeoPoint)!
                    shopData.shopLon = shopData.shopGeo.longitude
                    shopData.shopLat = shopData.shopGeo.latitude
                    print("店舗データの取得に成功しました")
                    self.shopData = shopData
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBShopLoadCompleteNotification), object: nil)
                }
            } else {
                print("店舗データの取得に失敗しました")
                var message = "Unknown error."
                if let description = error?.localizedDescription {
                    message = description
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBShopLoadCompleteNotification), object: nil, userInfo: ["error":message])
                return
            }
            
            return
        
        })
        
    } // getShopData end
    
    //該当店舗のメニューを全て取得する
    func getShopMenu(_ shopNumber: Int) {
        
        //読込中なら何もしない
        if loading_flag {
            return
        }
        
        var tmpMenu = [memo]()
        
        //読込中であることを反映する
        loading_flag = true
        
        //API実行開始を通知
        NotificationCenter.default.post(name: Notification.Name(rawValue: NCMBLoadStartNotification), object: nil)
        
        //API実行
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
        
        query.whereKey("shopNumber" , equalTo: shopNumber as Int)
        
        //作成日順にする
        query.order(byDescending: "createDate")
        
        query.findObjectsInBackground({(objects,  error) in
            
            if error == nil {
                if let response = objects {
                    if (response.count) > 0 {
                        
                        for i in 0 ..< response.count {
                            let targetMemoData: AnyObject = response[i] as AnyObject
                            var tmp : memo = memo()
                            tmp.objectID = (targetMemoData.object(forKey: "objectId") as? String)!
                            // shopNameがなければ飛ばす
                            if targetMemoData.object(forKey: "shopName") == nil {
                                continue
                            }
                            tmp.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                            tmp.menuName = (targetMemoData.object(forKey: "menuName") as? String)!
                            tmp.menuMoney = (targetMemoData.object(forKey: "menuPrice") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            // shopNumberがなければ飛ばす
                            if targetMemoData.object(forKey: "shopNumber") == nil {
                                continue
                            }
                            tmp.shopNumber = (targetMemoData.object(forKey: "shopNumber") as? Int)!
                            tmp.lookCounter = (targetMemoData.object(forKey: "lookCounter") as? Int)!
                            tmp.favoriteCounter = (targetMemoData.object(forKey: "favoriteCounter") as? Int)!
                            tmp.menuHours = (targetMemoData.object(forKey: "menuHours") as? Int)!
                            tmp.postUser = (targetMemoData.object(forKey: "postUser") as? String)!
                            let updateDate = (targetMemoData.object(forKey: "updateDate") as? String)!
                            tmp.updateDate = updateDate.substring(to: updateDate.index(updateDate.startIndex, offsetBy: 10))
                            tmpMenu.append(tmp)
                        }
                        
                        if self.shopMenu.count != tmpMenu.count {
                            self.shopMenu = tmpMenu
                        }

                        //読込終了を反映
                        self.loading_flag = false
                        
                        //API終了通知
                        NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil)
                        
                    } // response.count end
                } // opt bind objects
            } else {
                var message = "Unknown error."
                if let description = error?.localizedDescription {
                    message = description
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error":message])
                return
            } // errors end
            
        }) // findObjects end
        
        print(self.shopMenu)
        
    } // getShopMenu end
    
    func getFavList (_ myMenuList: [String]) {
        
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
        
        //仮保管場所
        var tmpFavList = [memo]()
        
        // 何回forを回すか
        let myMenuItem = myMenuList.count
        
        var counter = 0
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NCMBLoadStartNotification), object: nil)

/*      実装不可能
        query.whereKey("filename", containedIn: myMenuList)
        
        query.findObjectsInBackground({
            (objects, error) in
            
            if error == nil {
                if let response = objects {
                    if response.count > 0 {
                        for i in 0 ..< response.count {
                            let targetMemoData: AnyObject = response[i] as AnyObject
                            var tmp = memo()
                            
                            tmp.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                            tmp.menuName = (targetMemoData.object(forKey: "menuName") as? String)!
                            tmp.menuMoney = (targetMemoData.object(forKey: "menuPrice") as? String)!
                            tmp.objectID = (targetMemoData.object(forKey: "objectId") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            tmp.shopNumber = (targetMemoData.object(forKey: "shopNumber") as? Int)!

                            tmpFavList.append(tmp)
                        }
                        if tmpFavList.count != self.favList.count {
                            self.favList = tmpFavList
                        }
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil)
                    }
                } // optional binding end
            } else {
                var message = "Unknown error."
                if let description = error?.localizedDescription {
                    message = description
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error":message])
                return
            }// errorcheck end
        }) // findObjects end
        
*/

        for i in 0 ..< myMenuItem {
            
            query.whereKey("filename", equalTo: myMenuList[i])
            
            query.findObjectsInBackground({
                (objects, error) in
                
                if error == nil {
                    if let response = objects {
                        if response.count > 0 {
                            let targetMemoData: AnyObject = response[0] as AnyObject
                            var tmp = memo()
                            
                            tmp.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                            tmp.menuName = (targetMemoData.object(forKey: "menuName") as? String)!
                            tmp.menuMoney = (targetMemoData.object(forKey: "menuPrice") as? String)!
                            tmp.objectID = (targetMemoData.object(forKey: "objectId") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            tmp.shopNumber = (targetMemoData.object(forKey: "shopNumber") as? Int)!
                            tmp.lookCounter = (targetMemoData.object(forKey: "lookCounter") as? Int)!
                            tmp.favoriteCounter = (targetMemoData.object(forKey: "favoriteCounter") as? Int)!
                            tmp.menuHours = (targetMemoData.object(forKey: "menuHours") as? Int)!
                            tmp.postUser = (targetMemoData.object(forKey: "postUser") as? String)!
                            let updateDate = (targetMemoData.object(forKey: "updateDate") as? String)!
                            tmp.updateDate = updateDate.substring(to: updateDate.index(updateDate.startIndex, offsetBy: 10))
                            
                            tmpFavList.append(tmp)
                            counter += 1
                            if counter == myMenuItem {
                                if tmpFavList.count != self.favList.count {
                                    self.favList = tmpFavList
                                }
                                //API終了通知
                                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil)
                            }
                        }
                    } // optional binding end
                } else {
                    var message = "Unknown error."
                    if let description = error?.localizedDescription {
                        message = description
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error":message])
                    return
                }// errorcheck end
            }) // findObjects end
            
        } // for end
        
    } // getFavList end
    
    func getUserPost(_ userID: String) {
        
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
        query.order(byDescending: "createDate")
        query.whereKey("postUser", equalTo: userID)
        
        var tmpArray = [memo]()
        
        query.findObjectsInBackground({(objects, error) in
            
            if error == nil {
                if let response = objects {
                    if (response.count) > 0 {
                        
                        for i in 0 ..< response.count {
                            let targetMemoData: AnyObject = response[i] as AnyObject
                            var tmp : memo = memo()
                            tmp.objectID = (targetMemoData.object(forKey: "objectId") as? String)!
                            // shopNameがなければ飛ばす
                            if targetMemoData.object(forKey: "shopName") == nil {
                                continue
                            }
                            tmp.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                            tmp.menuName = (targetMemoData.object(forKey: "menuName") as? String)!
                            tmp.menuMoney = (targetMemoData.object(forKey: "menuPrice") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            // shopNumberがなければ飛ばす
                            if targetMemoData.object(forKey: "shopNumber") == nil {
                                continue
                            }
                            tmp.shopNumber = (targetMemoData.object(forKey: "shopNumber") as? Int)!
                            
                            tmp.lookCounter = (targetMemoData.object(forKey: "lookCounter") as? Int)!
                            tmp.favoriteCounter = (targetMemoData.object(forKey: "favoriteCounter") as? Int)!
                            tmp.menuHours = (targetMemoData.object(forKey: "menuHours") as? Int)!
                            tmp.postUser = (targetMemoData.object(forKey: "postUser") as? String)!
                            let updateDate = (targetMemoData.object(forKey: "updateDate") as? String)!
                            tmp.updateDate = updateDate.substring(to: updateDate.index(updateDate.startIndex, offsetBy: 10))
                            tmpArray.append(tmp)
                        }
                        
                        if tmpArray.count != self.postMenu.count {
                            self.postMenu = tmpArray
                        }
                        //API終了通知
                        NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil)
                        
                    } else {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error": ""])
                    }// response.count end
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error": "通信エラーが発生しました。"])
                }// opt bind objects
            } else {
                var message = "Unknown error."
                if let description = error?.localizedDescription {
                    message = description
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error":message])
                print(message)
                return
            } // errors end
            
        }) // findObjects end
        
    }
    
    func geoSearch(_ latitude: Double , _ longtitude: Double) {
        
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
        let geoPoint: NCMBGeoPoint = NCMBGeoPoint()
        geoPoint.latitude = latitude
        geoPoint.longitude = longtitude
        query.whereKey("geoPoint", nearGeoPoint: geoPoint, withinKilometers: 0.8)
        
        var tmpArray = [memo]()
        
        query.findObjectsInBackground({(objects,  error) in
            
            
            if error == nil {
                if let response = objects {
                    if (response.count) > 0 {
                        
                        for i in 0 ..< response.count {
                            let targetMemoData: AnyObject = response[i] as AnyObject
                            var tmp : memo = memo()
                            tmp.objectID = (targetMemoData.object(forKey: "objectId") as? String)!
                            // shopNameがなければ飛ばす
                            if targetMemoData.object(forKey: "shopName") == nil {
                                continue
                            }
                            tmp.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                            tmp.menuName = (targetMemoData.object(forKey: "menuName") as? String)!
                            tmp.menuMoney = (targetMemoData.object(forKey: "menuPrice") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            // shopNumberがなければ飛ばす
                            if targetMemoData.object(forKey: "shopNumber") == nil {
                                continue
                            }
                            tmp.shopNumber = (targetMemoData.object(forKey: "shopNumber") as? Int)!
                            tmp.lookCounter = (targetMemoData.object(forKey: "lookCounter") as? Int)!
                            tmp.favoriteCounter = (targetMemoData.object(forKey: "favoriteCounter") as? Int)!
                            tmp.menuHours = (targetMemoData.object(forKey: "menuHours") as? Int)!
                            tmp.postUser = (targetMemoData.object(forKey: "postUser") as? String)!
                            let updateDate = (targetMemoData.object(forKey: "updateDate") as? String)!
                            tmp.updateDate = updateDate.substring(to: updateDate.index(updateDate.startIndex, offsetBy: 10))
                            tmpArray.append(tmp)
                        }
                        
                        if tmpArray.count != self.memos.count {
                            self.memos = tmpArray
                        }
                        //API終了通知
                        NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil)
                        
                    } else {
                         NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error": "近くに掲載店舗がないようです。"])
                    }// response.count end
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error": "通信エラーが発生しました。"])
                }// opt bind objects
            } else {
                var message = "Unknown error."
                if let description = error?.localizedDescription {
                    message = description
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBLoadCompleteNotification), object: nil, userInfo: ["error":message])
                print(message)
                return
            } // errors end
            
        }) // findObjects end
        
    }// geoSearch End
    
    func getShopList(_ latitude : Double, _ longtitude : Double) {

        var tmpArray = [shop]()
        
        //API実行
        let query: NCMBQuery = NCMBQuery(className: "test")
        let geoPoint: NCMBGeoPoint = NCMBGeoPoint()
        geoPoint.latitude = latitude
        geoPoint.longitude = longtitude
        query.whereKey("geoPoint", nearGeoPoint: geoPoint, withinKilometers: 0.4)
        
        //店舗検索を通知
        NotificationCenter.default.post(name: Notification.Name(rawValue: NCMBShopLoadStartNotification), object: nil)
        
        query.findObjectsInBackground({
            (objects, error) in
            
            if error == nil {
                if let response = objects {
                    if response.count > 0 {
                    for  i in 0 ..< response.count {
                        let targetMemoData: AnyObject = response[i] as AnyObject
                        var tmpData = shop()
                        tmpData.shopName = (targetMemoData.object(forKey: "shopName") as? String)!
                        tmpData.shopNumber = (targetMemoData.object(forKey: "numbaer") as? Int)!
                        tmpData.openHours = (targetMemoData.object(forKey: "openHours") as? String)!
                        tmpData.restDay = (targetMemoData.object(forKey: "restDay") as? String)!
                        tmpData.shopGeo = (targetMemoData.object(forKey: "geoPoint") as? NCMBGeoPoint)!
                        tmpData.shopLon = tmpData.shopGeo.longitude
                        tmpData.shopLat = tmpData.shopGeo.latitude
                        tmpArray.append(tmpData)
                    }
                    if self.restaurants.count != tmpArray.count {
                        self.restaurants = tmpArray
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBShopLoadCompleteNotification), object: nil)
                    return
                    
                    } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBShopLoadCompleteNotification), object: nil, userInfo: ["error": "近くの店舗はまだ掲載されてないようです。"])
                    return
                    } // response.count end
                }
            } else {
                print("店舗データの取得に失敗しました")
                var message = "Unknown error."
                if let description = error?.localizedDescription {
                    message = description
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NCMBShopLoadCompleteNotification), object: nil, userInfo: ["error":message])
                return
            } // error check
            
            return
        
        }) // findObjects end
    } // getShopListend
    
    // アイコンアップロード時に前のデータを削除
    func deleteIcon (_ iconFileName : String) {
        
        var fileData: NCMBFile = NCMBFile.file(withName: iconFileName, data: nil) as! NCMBFile
        
        fileData.getDataInBackground({(data, error) in
        
            if error == nil {
                if data != nil {
                    fileData.deleteInBackground({(error) in
                        if error == nil {
                            print("消しました")
                        } else {
                            print("削除時\(error!.localizedDescription)")
                        }
                    })
                } else {
                    print("そんなデータは無い")
                }
            } else {
                print("検索時\(error!.localizedDescription)")
            }
        })
    }
    
    func loadIcon() {
        var userData = UserDefaults.standard
        if userData.object(forKey: "userIconFileName") as! String == "" {
            return
        }
        let iconFileName = userData.object(forKey: "userIconFileName") as! String
        var fileData: NCMBFile = NCMBFile.file(withName: iconFileName, data: nil) as! NCMBFile
        
        fileData.getDataInBackground({(data, error) in
            if error == nil {
                if data != nil {
                    if let userIcon = UIImagePNGRepresentation(UIImage(data: data!)!) {
                        userData.set(userIcon, forKey: "userIcon")
                    }
                }
            } else {
                print("検索時\(error!.localizedDescription)")
            }
        
        })
        
    }
    
    
}
