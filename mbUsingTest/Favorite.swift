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
    
    public static func add(_ objectId: String?) {
        if objectId == nil || objectId == "" { return }
        if favorites.contains(objectId!) {
            remove(objectId!)
        }
        favorites.append(objectId!)
        save()
    } // add end
    
    public static func remove(_ objectId: String?) {
        if objectId == nil || objectId == "" { return }
        
        if let index = favorites.index(of: objectId!) {
            favorites.remove(at: index)
        }
        save()
    } // remove end
    
    public static func inFavorites(_ objectId: String?) -> Bool{
        if objectId == nil || objectId == ""{ return false}
        
        return favorites.contains(objectId!)
    } // inFavorites end
    
    public static func toggle(_ objectId: String?) {
        if objectId == nil { return }
        
        if inFavorites(objectId!) {
            remove(objectId!)
        } else {
            add(objectId!)
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
