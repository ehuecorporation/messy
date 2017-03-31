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
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var unChangeButton: UIButton!
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func change(_ sender: UIButton) {
        if change_flag == 1 {
            change_flag = 0
            return
        }
        changeButton.borderColor = UIColor.black
        unChangeButton.borderColor = UIColor.gray
        change_flag = 1
    }
    
    @IBAction func unChange(_ sender: UIButton) {
        if change_flag == 0 {
            change_flag = 1
            return
        }
        changeButton.borderColor = UIColor.gray
        unChangeButton.borderColor = UIColor.black
        change_flag = 0
    }
    
    
    
    var targetShop = shop()
    var change_flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopName.text = targetShop.shopName
        openHours.text = targetShop.openHours
        restDay.text = targetShop.restDay
        
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
