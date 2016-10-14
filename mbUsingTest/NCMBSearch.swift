//
//  NCMBSearch.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/03.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import Foundation
import  NCMB

public struct memo {
    
    public var objectID: String = ""
    public var filename: String = ""
    public var memoTitle: String = ""
    public var memoMoney: String = ""
    public var memoComment: String = ""
    public var memoImage: UIImage? = nil
    
    public var description: String {
        get {
            var string = "\nmemoTitle:\(memoTitle)"
            string += "\nmemoMoney:\(memoMoney)"
            string += "\nmemoComment:\(memoComment)"
            return string
        }
    }
    
}

public class NCMBSearch {
    //メモの保管
    public var memos = [memo]()
    
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
                            tmp.memoTitle = (targetMemoData.object(forKey: "title") as? String)!
                            tmp.memoComment = (targetMemoData.object(forKey: "comment") as? String)!
                            tmp.memoMoney = (targetMemoData.object(forKey: "money") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            self.memos.append(tmp)
                        }
                        
                        self.total = (response.count)
                        
                        //読込終了を反映
                        self.loading_flag = false
                        
                        print("データ読込完了。データ件数は\(self.memos.count)です。")
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
    
    func getImage(_ targetNum : Int, _ targetList : [memo]) {
        let targetMemoData = targetList[targetNum]
        
        let filename: String = targetMemoData.filename
        let fileData = NCMBFile.file(withName: filename, data: nil) as! NCMBFile
            
        fileData.getDataInBackground {
            (imageData, error) -> Void in
            
            if error != nil {
                print("写真の取得失敗: \(error)")
            } else {
                self.memos[targetNum].memoImage = UIImage(data: imageData!)
            }
        }

    }
    
    func reLoadData() {
        
        var loadingMemos = [memo]()
        
        //読込中なら何もしない
        if loading_flag {
            return
        }
        
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
                            tmp.memoTitle = (targetMemoData.object(forKey: "title") as? String)!
                            tmp.memoComment = (targetMemoData.object(forKey: "comment") as? String)!
                            tmp.memoMoney = (targetMemoData.object(forKey: "money") as? String)!
                            tmp.filename = (targetMemoData.object(forKey: "filename") as? String)!
                            loadingMemos.append(tmp)
                        }
                        
                        if response.count != self.total {
                            self.total = (response.count)
                            self.memos.removeAll()
                            self.memos = loadingMemos
                        }
                        
                        //読込終了を反映
                        self.loading_flag = false
                        
                        print("データ読込完了。データ件数は\(self.memos.count)です。")
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
        
        
    }
    
}
