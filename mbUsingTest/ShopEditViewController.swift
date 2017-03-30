//
//  ShopEditViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2017/03/30.
//  Copyright © 2017年 蕭　喬仁. All rights reserved.
//

import UIKit

class ShopEditViewController: UIViewController {

    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var openHours: UITextView!
    @IBOutlet weak var restDay: UITextField!
    
    var targetShop = shop()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
