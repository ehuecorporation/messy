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
    //ポストの保管
    public var memos = [memo]()
    
    //お気に入りリスト
    public var favList = [memo]()
    
    //ShopMenu
    public var shopMenu = [memo]()
    
    //店舗データ
    public var shopData = shop()
    
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
    
    
    //APIからデータを読み込む
    // reset = true ならデータを捨てて再度読み込む
    func loadMemoData(_ reset: Bool = false) {
        
        //読込中なら何もしない
        if loading_flag {
            return
        }
        
        //reset = true なら今までの結果を捨てる
        if reset {
            memos = []
            total = 0
        }
        
        var tmpArray = [memo]()
        
        //読込中であることを反映する
        loading_flag = true
        
        //API実行開始を通知
        NotificationCenter.default.post(name: Notification.Name(rawValue: NCMBLoadStartNotification), object: nil)
        
        //API実行
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
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
                            tmpArray.append(tmp)
                        }
                        
                        if tmpArray.count != self.memos.count {
                            self.memos = tmpArray
                        }
                        
                        self.total = (self.memos.count)
                        
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
        
    } // loadMemoData end
    
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
                    shopData.shopLon = (targetMemoData.object(forKey: "longtitude") as? Double)!
                    shopData.shopLat = (targetMemoData.object(forKey: "latitude") as? Double)!
                    shopData.openHours = (targetMemoData.object(forKey: "openHours") as? String)!
                    shopData.restDay = (targetMemoData.object(forKey: "restDay") as? String)!
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
    
    func geoSearch(_ latitude: Double , _ longtitude: Double) {
        
        let query: NCMBQuery = NCMBQuery(className: "MemoClass")
        let geoPoint: NCMBGeoPoint = NCMBGeoPoint()
        geoPoint.latitude = latitude
        geoPoint.longitude = longtitude
        query.whereKey("geoPoint", nearGeoPoint: geoPoint, withinKilometers: 0.5)
        
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
    
    
}
