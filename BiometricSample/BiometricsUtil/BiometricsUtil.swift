//
//  BiometricsUtil.swift
//  BiometricSample
//
//  Created by Stanley on 2020/10/29.
//  Copyright © 2020 Stanley. All rights reserved.
//

import UIKit
import LocalAuthentication

@objc enum BiometricType: Int {
    case none
    case touchID
    case faceID
}

@objc enum BiometricErrorType: Int {
    case None = 0
    
    /// Authentication was not successful, because user failed to provide valid credentials.
    case AuthenticationFailed = -1
    
    /// Authentication was canceled by user (e.g. tapped Cancel button).
    case UserCancel = -2
    
    /// Authentication was canceled, because the user tapped the fallback button (Enter Password).
    case UserFallback = -3
    
    /// Authentication was canceled by system (e.g. another application went to foreground).
    case SystemCancel = -4
    
    /// Authentication could not start, because passcode is not set on the device.
    case PasscodeNotSet = -5
    
    /// Authentication could not start, because biometry is not available on the device.
    case BiometryNotAvailable = -6
    
    /// Authentication could not start, because biometry has no enrolled identities.
    case BiometryNotEnrolled = -7
    
    /// Authentication was not successful, because there were too many failed biometry attempts and
    /// biometry is now locked. Passcode is required to unlock biometry, e.g. evaluating
    /// LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.
    case BiometryLockout = -8
    
    /// Authentication was canceled by application (e.g. invalidate was called while
    /// authentication was in progress).
    case appCancel = -9

    /// LAContext passed to this call has been previously invalidated.
    case invalidContext = -10
    
    case Others = 999
}

@objcMembers class BiometricsUtil: NSObject {
    @objc static let shared = BiometricsUtil()
    
    //MARK: - parameters
    var needBlockBackground: Bool = false
    
    var biometricType: BiometricType {
        get {
            let context = LAContext()
            if #available(iOS 11.0, *) {
                _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                switch context.biometryType {
                case .none:
                    return .none
                case .touchID:
                    return .touchID
                case .faceID:
                    return .faceID
                @unknown default:
                    fatalError()
                }
            } else {
                return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
            }
        }
    }
    
    var isUserEnableBiometrics: Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: "isEnableBiometrics") as? Bool {
                return value
            }
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isEnableBiometrics")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var bgView: UIView?
    
    //MARK: - functions
    func biometricsAuthentication(completion: @escaping (BiometricErrorType) -> Void) {
        let context = LAContext()
        context.localizedFallbackTitle = ""
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            addBlockBackground()
            
            let reason = "Authenticaticate to unlock app"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                DispatchQueue.main.async {
                    self.removeBlockground()
                    if (success) {
                        completion(.None)
                    }
                    else {
                        let errorType = self.getBiometricErrorType(error: (error as NSError?))
                        completion(errorType)
                    }
                }
            }
        }
        else {
            let errorType = getBiometricErrorType(error: error)
            if errorType == .BiometryLockout {
                authenticateWithPasscode(context: context) { (laError) in
                    DispatchQueue.main.async {
                        completion(laError)
                    }
                }
            }
            else {
                completion(errorType)
            }
        }
    }
    
    func checkErrorBySystemBiometricsGranted(completion: @escaping(BiometricErrorType) -> Void) {
        let context = LAContext()
        var error: NSError?
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let errorType = self.getBiometricErrorType(error: (error as NSError?))
            if errorType == .BiometryLockout {
                authenticateWithPasscode(context: context) { (errorType) in
                    DispatchQueue.main.async {
                        completion(errorType)
                    }
                }
            }
            else {
                completion(errorType)
            }
        }
        else {
            completion(.None)
        }
    }
    
    func clearBiometricsUserDefault() {
        UserDefaults.standard.removeObject(forKey: "isEnableBiometrics")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - private function
    private func authenticateWithPasscode(context: LAContext, completion: @escaping(BiometricErrorType) -> Void) {
        let reason: String = "Biometric Login has been locked out. Enter iPhone passcode to enable again."
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: { (success, error) in
            DispatchQueue.main.async {
                if success {
                    completion(.None)
                }
                else {
                    let errorType = self.getBiometricErrorType(error: (error as NSError?))
                    completion(errorType)
                }
            }
        })
    }
    
    private func getBiometricErrorType(error: NSError?) -> BiometricErrorType {
        var errorType: BiometricErrorType = .None
        guard error != nil else {
            return errorType
        }
        errorType = BiometricErrorType(rawValue: error!.code) ?? .Others
        return errorType
    }
    
    private func addBlockBackground() {
        guard needBlockBackground else {
            return
        }
        
        bgView = UIView(frame: UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.frame)
        bgView!.backgroundColor = .white
        
        let opaqueView = UIView(frame: UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.frame)
        opaqueView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        bgView!.addSubview(opaqueView)
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.addSubview(bgView!)
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.bringSubviewToFront(bgView!)
    }
    
    private func removeBlockground() {
        guard needBlockBackground else {
            return
        }
        
        bgView?.removeFromSuperview()
        bgView = nil
    }
    
}
