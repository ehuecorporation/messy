//
//  ContainerViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/11/22.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    
    @IBAction func goAdd(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goAdd", sender: nil)
    }
    
    var isOpenLeft = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath)
        
        
        return cell
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
