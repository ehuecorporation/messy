//
//  UpdateViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2016/10/03.
//  Copyright © 2016年 蕭　喬仁. All rights reserved.
//

import UIKit
import  NCMB


class UpdateViewController: UIViewController,UITextFieldDelegate {
    
    var userName : String = ""
    
    @IBOutlet weak var userNewName: UITextField!
    @IBOutlet weak var mailAdress: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    
    @IBAction func Update(_ sender: UIButton) {
        
        
        // ログイン中のユーザーを取得
        let user = NCMBUser.current()
        let targetNewName = self.userNewName.text!
        let targetNewMailAdress = self.mailAdress.text!
        let targetNewpassWord = self.passWord.text!
        
        if (targetNewName.isEmpty || targetNewMailAdress.isEmpty || targetNewpassWord.isEmpty) {
            
            //エラーアラートを表示してOKで戻る
            let errorAlert = UIAlertController(title: "エラー", message:"入力に不備があります", preferredStyle: UIAlertControllerStyle.alert)
            
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil
                )
            )
            present(errorAlert, animated: true, completion: nil)
            
        } else {
            // ユーザー情報を設定
            user?.setObject(targetNewName, forKey: "userName")
            user?.setObject(targetNewMailAdress, forKey: "mailAddress")
            // user情報の更新
            
            user?.saveInBackground({
                (error) -> Void in
                if error != nil {
                    // 更新失敗時の処理
                    let errorAlert = UIAlertController(
                        title: "エラー",
                        message: "更新処理を中止します\(error)",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    errorAlert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: UIAlertActionStyle.default,
                            handler: nil
                        )
                    )
                    print("エラー内容\(error)")
                    self.present(errorAlert, animated: true, completion: nil)
                    
                } else {
                    // 更新成功時の処理
                    let errorAlert = UIAlertController(
                        title: "完了",
                        message: "会員情報を更新しました",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    errorAlert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: UIAlertActionStyle.default,
                            handler: self.saveComplete
                        )
                    )
                    
                    let login: LoginViewController = LoginViewController()
                    
                    login.userData.set(true, forKey: "useCount")
                    
                    self.present(errorAlert, animated: true, completion: nil)
                    

                }
            })
        }
        
    }
    
    func saveComplete(_ ac: UIAlertAction) -> Void {
        performSegue(withIdentifier: "PushMemoList", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation
    //segueを呼び出したときに呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //コメント表示画面へ行く前に詳細データを渡す
        if segue.identifier == "PushMemoList" {
            
            let ViewController = segue.destination as! ViewController
            
            ViewController.userName = self.userName
            
        }
    }


}
