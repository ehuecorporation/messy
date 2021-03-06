//
//  ReportViewController.swift
//  mbUsingTest
//
//  Created by 蕭　喬仁 on 2017/02/04.
//  Copyright © 2017年 蕭　喬仁. All rights reserved.
//

import UIKit
import NCMB

class ReportViewController: UIViewController, UITextViewDelegate {
    

    @IBOutlet weak var reportButton1: UIButton!
    @IBOutlet weak var reportButton2: UIButton!
    @IBOutlet weak var reportButton3: UIButton!
    @IBOutlet weak var reportReason: PlaceHolderTextView!
    
    @IBAction func hydeKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func report1(_ sender: UIButton) {
        reportNum = 0;
        reportContent = "写真が不適切である"
        reportCheck()
    }
    
    @IBAction func report2(_ sender: Any) {
        reportNum = 1;
        reportContent = "写真に盗用の疑いがある"
        reportCheck()
    }
    
    @IBAction func report3(_ sender: UIButton) {
        reportNum = 2;
        reportContent = "情報が間違っている"
        reportCheck()
    }
    
    @IBAction func report4(_ sender: UIButton) {
        reportNum = 3;
        OperationQueue.main.addOperation({
            self.reportReason.becomeFirstResponder()
        });
    }
    
    @IBOutlet weak var underSpaceHeight: NSLayoutConstraint!
    
    @IBAction func sendReport(_ sender: UIBarButtonItem) {
        reportCheck()
    }
    
    var reportNum:Int? = nil
    var reportContent = ""
    var targetMemo: memo = memo()
    
    //ユーザー情報
    var userData = UserDefaults.standard

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,selector: #selector(LoginViewController.keyboardWillBeShown(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportReason.delegate = self
        reportReason.placeHolder = "内容を記入してください(その他の場合)"

    }
    
    func keyboardWillBeShown(_ notification: Notification) {
        self.view.setNeedsUpdateConstraints()
        underSpaceHeight.constant = CGFloat(210.0)
        //誤タップ防止のため一時的に無効化
        reportButton1.isEnabled = false
        reportButton2.isEnabled = false
        reportButton3.isEnabled = false
        // アニメーションによる移動
        UIView.animate(withDuration: 0.3, animations: self.view.layoutIfNeeded)
    }
    
    func keyboardWillBeHidden(_ notification : Notification) {
        self.view.setNeedsUpdateConstraints()
        underSpaceHeight.constant = CGFloat(20.0)
        reportContent = reportReason.text
        //最有効化
        reportButton1.isEnabled = true
        reportButton2.isEnabled = true
        reportButton3.isEnabled = true
        // アニメーションによる移動
        UIView.animate(withDuration: 0.3, animations: self.view.layoutIfNeeded)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //登録が完了した際のアクション
    func saveComplete(_ ac: UIAlertAction) -> Void {
        //UItextFieldを空にする
        self.reportReason.text = ""
        _ = navigationController?.popViewController(animated: true)
    }
    
    func reportCheck() {
        let errorAlert = UIAlertController(
            title: "確認",
            message: "この内容で送信しますか？\n\(reportContent)",
            preferredStyle: UIAlertControllerStyle.alert
        )
        errorAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.default,
                handler: self.checked
        ))
        errorAlert.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertActionStyle.cancel,
                handler: nil
            )
        )
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    func checked(_ ac: UIAlertAction) -> Void {
        let targetNum  = reportNum
        let targetContent = reportContent
        
        let obj: NCMBObject = NCMBObject(className: "report")
        
        if (targetNum == nil || targetContent == "") {
            presentError("エラー", "入力内容にエラーがあります")
        } else {
            var saveError: NSError? = nil
            obj.setObject(reportNum, forKey: "reportCategory")
            obj.setObject(reportContent, forKey: "reportReason")
            obj.setObject(userData.object(forKey: "userID"), forKey: "reportUser")
            obj.setObject(targetMemo.shopName, forKey: "targetShop")
            obj.setObject(targetMemo.menuName, forKey: "targetMenu")
            obj.setObject(targetMemo.postUser, forKey: "targetUser")
            obj.save(&saveError)
            
            if saveError == nil {
                print("success save data.")
            } else {
                print("failure save data.\(String(describing: saveError))")
            }
            
            let errorAlert = UIAlertController(
                title: "送信完了",
                message: nil,
                preferredStyle: UIAlertControllerStyle.alert
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: self.saveComplete
                )
            )
            self.present(errorAlert, animated: true, completion: nil)
        } // if else end
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
        ))
        self.present(errorAlert, animated: true, completion: nil)
    
    }

}
