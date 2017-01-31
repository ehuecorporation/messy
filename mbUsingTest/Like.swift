//
//  Likes.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2017/01/30.
//  Copyright © 2017年 蕭　喬仁. All rights reserved.
//

import Foundation

public struct Like {
    
    public static var likes = [String]()
    
    public static func load() {
        let ud = UserDefaults.standard
        ud.register(defaults: ["likes": [String]()])
        likes = ud.object(forKey: "likes") as! [String]
    } // load end
    
    public static func save() {
        let ud = UserDefaults.standard
        ud.set(likes, forKey: "likes")
        ud.synchronize()
    } // save end
    
    public static func add(_ shopName: String?) {
        if shopName == nil || shopName == "" { return }
        if likes.contains(shopName!) {
            remove(shopName!)
        }
        likes.append(shopName!)
        save()
    } // add end
    
    public static func remove(_ shopName: String?) {
        if shopName == nil || shopName == "" { return }
        
        if let index = likes.index(of: shopName!) {
            likes.remove(at: index)
        }
        save()
    } // remove end
    
    public static func inLikes(_ shopName: String?) -> Bool{
        if shopName == nil || shopName == ""{ return false}
        
        return likes.contains(shopName!)
    } // inLikes end
    
    public static func toggle(_ shopName: String?) {
        if shopName == nil { return }
        
        if inLikes(shopName!) {
            remove(shopName!)
        } else {
            add(shopName!)
        }
    } // toggle end
    
    public static func move(_ sourceIndex: Int, _ destinationIndex: Int) {
        if sourceIndex >= likes.count || destinationIndex >= likes.count { return }
        
        let srcGid = likes[sourceIndex]
        likes.remove(at: sourceIndex)
        likes.insert(srcGid, at: destinationIndex)
        
        save()
        
    } // move end
    
} // struct end
