//
//  ViewController.swift
//  Swifty companion
//
//  Created by Viktoriia LIKHOTKINA on 1/28/19.
//  Copyright © 2019 Viktoriia LIKHOTKINA. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var studentInfo : Student?
    let downloadGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButtonOutlet.layer.cornerRadius = 7
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
        activityIndicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchField = textField
    }
    
    @objc func keyboardWillShow(sender: NSNotification,_ textField : UITextField) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if searchButtonOutlet.frame.origin.y > keyboardSize.origin.y {
                self.view.frame.origin.y = keyboardSize.origin.y - searchButtonOutlet.center.y - 20
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    /*@objc func keyboardWillShow(notification: NSNotification) {
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = (targetFrame.origin.y - curFrame.origin.y) / 2
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.searchField.frame.origin.y += deltaY
            self.searchButtonOutlet.frame.origin.y += deltaY
        },completion: nil)
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        searchField.text = ""
        studentInfo = nil
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        tryToMakeRequestStudentInfo() {
            self.checkAPIResponse()
        }
    }
    
    func tryToMakeRequestStudentInfo(
        withCompletion completion: @escaping () -> Void?) {
        let searchLogin = self.searchField.text
        guard token != nil && searchLogin != nil && searchLogin != "" else {
            if token == nil {
                self.displayAlert(message: Errors.authorizationProblem)
                activityIndicator.isHidden = true
            }
            else {
                self.displayAlert(message: Errors.emptyField)
                activityIndicator.isHidden = true
            }
            searchField.text = ""
            studentInfo = nil
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.downloadGroup.enter()
            StudentAPI.getUserData(login : searchLogin!, completionHandler: self.handleGetStudentInfo(studentInfo:error:))
            self.downloadGroup.notify(queue:.main) {
                completion()
            }
        }
    }
    
    func handleGetStudentInfo(studentInfo: Student?, error: Error?) {
        guard studentInfo != nil else {
            displayAlert(message: Errors.incorrectLogin)
            activityIndicator.isHidden = true
            searchField.text = ""
            downloadGroup.leave()   
            return
        }
        activityIndicator.isHidden = true
        self.studentInfo = studentInfo
        StudentAPI.fillValidateProjects(studentInfo: &self.studentInfo!)
        downloadGroup.leave()
    }
    
    func checkAPIResponse() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "studentInfo") as! StudentInfoViewController
            controller.userData = self.studentInfo
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func displayAlert(message: Errors) {
        let alert = UIAlertController(title: "Search error", message: message.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.view.tintColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
        self.present(alert, animated: true, completion: nil)
    }
    
}

