//
//  ViewController.swift
//  TouchID-Demo
//
//  Created by Roman Voglhuber on 16/07/15.
//  Copyright (c) 2015 Voglhuber. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController, UIAlertViewDelegate {

    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var authorizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func touchIDPressed(sender: AnyObject) {
        checkTouchID()
    }

    func checkTouchID(){
        let context = LAContext()
        
        var error: NSError?
        
        let reason = "Authenticate to use this app"
        
        //Check if the device has Touch ID and it is enabled
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error){
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, evalPolicyError) -> Void in
                if success{
                    //Successfully authenticated
                    NSLog("User authenticated by Touch ID")
                    
                    //Update UI in main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        self.authorizeLabel.text = "Authenticated by Touch ID"
                    }
                }
                else{
                    NSLog("Touch ID authentication failed: %@", evalPolicyError.localizedDescription)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.authorizeLabel.text = "Authentication failed by Touch ID"
                    }
                    
                    switch evalPolicyError!.code{
                        
                    case LAError.SystemCancel.rawValue:
                        NSLog("Touch ID canceld by system")
                        
                    case LAError.UserCancel.rawValue:
                        NSLog("Touch ID canceld by user")
                        
                    //Fallback "Password" is shown if Touch ID doesn't recognize the first fingerprint
                    case LAError.UserFallback.rawValue:
                        NSLog("Password selected")
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showPasswordInput()
                        }
                    
                    default:
                        NSLog("Authentication failed")
                        dispatch_async(dispatch_get_main_queue()) {
                            self.showPasswordInput()
                        }
                    }
                }
            })
        }
        else{
            NSLog("Touch ID not available")
            self.showPasswordInput()
        }
    }
    
    func showPasswordInput(){
        var passwordAlert : UIAlertView = UIAlertView(title: "Password input", message: "Please enter your password: \"password\"", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        passwordAlert.alertViewStyle = UIAlertViewStyle.SecureTextInput
        passwordAlert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 && alertView.textFieldAtIndex(0)?.text == "password"{
            NSLog("User authenticated by password")
            authorizeLabel.text = "Authenticated by password"
        }
        else{
            NSLog("Authentication failed by password")
            authorizeLabel.text = "Authentication failed by password"
        }
    }
}

