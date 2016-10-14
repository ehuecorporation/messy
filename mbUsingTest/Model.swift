//
//  Model.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/09/11.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import Foundation
import NCMB

@objc(Model)
class  Model: NCMBObject, NCMBSubclassing{
    var column: Int {
        get {
            return object(forKey: "column") as! Int
        }
        set {
            setObject(newValue, forKey: "column")
        }
    }
    
    override init!(className: String!) {
        super.init(className: className)
    }
    
    static func ncmbClassName() -> String! {
        return "Model"
    }
}
