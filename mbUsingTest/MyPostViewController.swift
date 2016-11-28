//
//  MyPostViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/11/28.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import SWRevealViewController

class MyPostViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func goAdd(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goAdd", sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

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
