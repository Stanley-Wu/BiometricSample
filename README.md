# BiometricSample
Swift biometrics utility and sample code
#### 將原生生物辨識 api 包裝為工具使用
- BiometricsUtil
- BiometricsSampleCode
***
## How to use
>- 需先在 project 中加入 __`LocalAuthentication.framework`__
>- 若有使用 Face ID 則需加入 __`Privacy - Face ID Usage Description`__ 描述
>- 將 __`BiometricsUtil.swift`__ 檔案引進 project 中  
##  
### 參數使用  
```swift 
var needBlockBackground: Bool
```  
__`true`__： 生物辨識時將原背景畫面覆蓋  
__`false`__： 生物辨識時不覆蓋原背景畫面  
  
```swift
var biometricType: BiometricType
```  
回傳支援生物辨識類型 __`touchID, faceID`__，__`none`__ 表示不支援生物辨識  
  
```swift
var  isUserEnableBiometrics: Bool
```  
記錄 user 在 app 中啟用生物辨識開關狀態  
__`true`__： 開啟生物辨識功能  
__`false`__： 關閉生物辨識功能  
  
##  
### function 使用  
```swift
func biometricsAuthentication(completion: @escaping (BiometricErrorType) -> Void)
```  
呼叫生物辨識功能，若先前失敗次數達系統上線，則會要求 user 使用 passcode 解鎖  
回傳 __`BiometricErrorType`__  
  
```swift
func checkErrorBySystemBiometricsGranted(completion: @escaping(BiometricErrorType) -> Void)
```  
檢查 user 是否允許使用生物辨識，若先前失敗次數達系統上線，則會要求 user 使用 passcode 解鎖  
回傳 __`BiometricErrorType`__  

```swift
func clearBiometricsUserDefault()
```  
清除記錄在 app 內的生物辨識開關狀態  
  
##  
### enum  
```swift
@objc enum BiometricType: Int {
    case none
    case touchID
    case faceID
}
```  
```swift
@objc enum BiometricErrorType: Int {
    case None = 0
    ///  Authentication was not successful, because user failed to provide valid credentials.
    case AuthenticationFailed = -1
    ///  Authentication was canceled by user (e.g. tapped Cancel button).
    case UserCancel = -2
    ///  Authentication was canceled, because the user tapped the fallback button (Enter Password).
    case UserFallback = -3
    ///  Authentication was canceled by system (e.g. another application went to foreground).
    case SystemCancel = -4
    ///  Authentication could not start, because passcode is not set on the device.
    case PasscodeNotSet = -5
    ///  Authentication could not start, because biometry is not available on the device.
    case BiometryNotAvailable = -6
    ///  Authentication could not start, because biometry has no enrolled identities.
    case BiometryNotEnrolled = -7
    ///  Authentication was not successful, because there were too many failed biometry attempts and
    ///  biometry is now locked. Passcode is required to unlock biometry, e.g. evaluating
    ///  LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.
    case BiometryLockout = -8
    ///  Authentication was canceled by application (e.g. invalidate was called while
    ///  authentication was in progress).
    case appCancel = -9
    ///  LAContext passed to this call has been previously invalidated.
    case invalidContext = -10
    case Others = 999
}
```
