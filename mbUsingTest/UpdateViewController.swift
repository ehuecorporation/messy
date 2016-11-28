//
//  UpdateViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/03.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB
import SWRevealViewController


class UpdateViewController: UIViewController,UITextFieldDelegate, UINavigationControllerDelegate {
    
    var userData = UserDefaults.standard
    var userName : String = ""
    var loginFlag: Bool = Bool()
    let user = NCMBUser.current()
    var loading_flag = false
    

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var userNewName: UITextField!
    @IBOutlet weak var mailAdress: UITextField!
    
    @IBAction func hydeKeybord(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func Update(_ sender: UIButton) {
        
        if loading_flag {
            return
        }
        
        // textFieldの値を取得
        let targetNewName = self.userNewName.text!
        let targetNewMailAdress = self.mailAdress.text!
        
        if (targetNewName.isEmpty || targetNewMailAdress.isEmpty) {
            
            presentError("エラー", "入力に不備があります")
            
            
        } else {
            
            loading_flag = true

            // ユーザー情報を設定
            user?.setObject(targetNewName, forKey: "userName")
            user?.setObject(targetNewMailAdress, forKey: "mailAddress")
            // user情報の更新
            
            user?.saveInBackground({
                (error) -> Void in
                if let updateerror = error {
                    // 更新失敗時の処理
                    print("エラー内容\(error)")
                    self.presentError("更新エラー", "\(updateerror.localizedDescription)")
                    self.loading_flag = false
                    
                } else {
                    
                    self.userData.register(defaults: ["useCount" : Bool()])
                    self.userData.register(defaults: ["userID" : String()])
                    self.userData.register(defaults: ["userMail" : String()])
                    self.userData.set(true, forKey: "useCount")
                    self.userData.set(self.user?.objectId, forKey: "userID")
                    self.userData.set(self.user?.mailAddress, forKey: "userMail")
                    self.userData.synchronize()
                    
                    let errorAlert = UIAlertController(
                        title: "完了",
                        message: "会員情報が更新されました",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    errorAlert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: UIAlertActionStyle.default,
                            handler: self.saveComplete
                        )
                    )
                    
                    self.loading_flag = false
                    
                    self.present(errorAlert, animated: true, completion: nil)
                    
                }
            })
        }
        
    }
    
    // キーボードの確定を押した後の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if (textField == userNewName) {
            // password欄へフォーカスする
            mailAdress.becomeFirstResponder()
        } else {
            // キーボードを閉じる
            textField.resignFirstResponder()
            
            Update(UIButton.init())
            
        }
        return true
    }
    
    // エラーメッセージを出す関数を定義
    func presentError (_ title: String, _ message: String) {
        let errorAlert = UIAlertController(
            title: "\(title)",
            message: "\(message)",
            preferredStyle: UIAlertControllerStyle.alert
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: nil
            )
        )
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func saveComplete(_ ac: UIAlertAction) -> Void {
        performSegue(withIdentifier: "pushMain", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userNewName.delegate = self
        mailAdress.delegate = self
        
        if let name = userData.object(forKey: "userName") {
            userNewName.text = name as? String
        }
        
        if let mail = userData.object(forKey: "userMail") {
            mailAdress.text = mail as? String
        }
        
        //ドロワーメニュー
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
