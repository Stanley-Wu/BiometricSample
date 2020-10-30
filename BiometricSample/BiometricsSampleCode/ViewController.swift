//
//  ViewController.swift
//  BiometricSample
//
//  Created by Stanley on 2020/10/29.
//  Copyright © 2020 Stanley. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clickCheckBiometricType() {
        let type = BiometricsUtil.shared.biometricType
        label.text = getStringByBiometricsType(type)
    }
    
    @IBAction func clickTestBiometricAuthentication() {
        BiometricsUtil.shared.checkErrorBySystemBiometricsGranted { [unowned self] (errorType) in
            if errorType == .None {
                self.startBiometricAuthentication()
            }
            else {
                self.label.text = self.getStringByBiometricErrorType(errorType)
            }
        }
    }
    
    //MARK: - private function
    private func startBiometricAuthentication() {
        BiometricsUtil.shared.biometricsAuthentication { [unowned self] (errorType) in
            if errorType == .None {
                self.label.text = "Biometrics authentication succeed"
            }
            else {
                self.label.text = self.getStringByBiometricErrorType(errorType)
            }
        }
    }
    
    private func getStringByBiometricsType(_ type: BiometricType) -> String {
        switch type {
        case .none:
            return "Device not support biometrics authentication."
        case .touchID:
            return "Device biometrics is Touch ID"
        case .faceID:
            return "Device biometrics is Face ID"
        }
    }
    
    private func getStringByBiometricErrorType(_ errorType: BiometricErrorType) -> String {
        switch errorType {
        case .None:
            return ""
        
        case .AuthenticationFailed:
            return "Authentication was not successful, because user failed to provide valid credentials."
        
        case .UserCancel:
            return "Authentication was canceled by user (e.g. tapped Cancel button)."
        
        case .UserFallback:
            return "Authentication was canceled, because the user tapped the fallback button (Enter Password)."
        
        case .SystemCancel:
            return "Authentication was canceled by system (e.g. another application went to foreground)."
        
        case .PasscodeNotSet:
            return "Authentication could not start, because passcode is not set on the device."
        
        case .BiometryNotAvailable:
            return "Authentication could not start, because biometry is not available on the device."
        
        case .BiometryNotEnrolled:
            return "Authentication could not start, because biometry has no enrolled identities."
        
        case .BiometryLockout:
            return "Authentication was not successful, because there were too many failed biometry attempts and biometry is now locked. Passcode is required to unlock biometry, e.g. evaluating LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite."
        
        case .appCancel:
            return "Authentication was canceled by application (e.g. invalidate was called while authentication was in progress)."

        case .invalidContext:
            return "LAContext passed to this call has been previously invalidated."
        
        case .Others:
            return "Ohter error."
        }
    }

}

