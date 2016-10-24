//
//  Favorite.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/24.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import Foundation

public struct Favorite {
    public static var favorites = [String]()
    
    public static func load() {
        let ud = UserDefaults.standard
        ud.register(defaults: ["favorites": [String]()])
        favorites = ud.object(forKey: "favorites") as! [String]
    } // load end
    
    public static func save() {
        let ud = UserDefaults.standard
        ud.set(favorites, forKey: "favorites")
        ud.synchronize()
    } // save end
    
    public static func add(_ shopName: String?) {
        if shopName == nil || shopName == "" { return }
        if favorites.contains(shopName!) {
            remove(shopName!)
        }
        favorites.append(shopName!)
        save()
    } // add end
    
    public static func remove(_ shopName: String?) {
        if shopName == nil || shopName == "" { return }
        
        if let index = favorites.index(of: shopName!) {
            favorites.remove(at: index)
        }
        save()
    } // remove end
    
    public static func inFavorites(_ shopName: String?) -> Bool{
        if shopName == nil || shopName == ""{ return false}
        
        return favorites.contains(shopName!)
    } // inFavorites end
    
    public static func toggle(_ shopName: String?) {
        if shopName == nil { return }
        
        if inFavorites(shopName!) {
            remove(shopName!)
        } else {
            add(shopName!)
        }
    } // toggle end
    
    public static func move(_ sourceIndex: Int, _ destinationIndex: Int) {
        if sourceIndex >= favorites.count || destinationIndex >= favorites.count { return }
        
        let srcGid = favorites[sourceIndex]
        favorites.remove(at: sourceIndex)
        favorites.insert(srcGid, at: destinationIndex)
        
        save()
        
    } // move end
    
} // struct end
