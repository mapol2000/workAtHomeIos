//
//  ViewController.swift
//  workAtHome
//
//  Created by 김평구 on 10/14/24.
//

import UIKit
import TouchEnAppIron
@preconcurrency import WebKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    // outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // variables
    var popupView: WKWebView?
    
    // actions
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        webViewDidClose(popupView!)
    }
    
    // MARK: - 화면 로드
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webViewInit()
        if isUpdateAvailable() {
            updateApp()
        }
        
    }
    
    // MARK: - 웹뷰 이니셜라이저
    func webViewInit() {
        
        // 웹뷰 세팅
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.configuration.dataDetectorTypes = [.all]
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // 줌 세팅
        let zoomSource: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
        let zoomScript: WKUserScript = WKUserScript(source: zoomSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(zoomScript)
        
        // 캡쳐방지
        //        NotificationCenter.default.addObserver(self, selector: #selector(didDetectScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        
        // JS 콘솔로그
        let logSource = """
            function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); }
            window.console.log = captureLog;
        """
        let logScript = WKUserScript(source: logSource, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(logScript)
        
        // 웹과의 인터페이스
        webView.configuration.userContentController.add(self, name: "forceQuitApp")
        webView.configuration.userContentController.add(self, name: "setDeviceId")
        webView.configuration.userContentController.add(self, name: "logHandler")
        webView.configuration.userContentController.add(self, name: "updateApp")
        webView.configuration.userContentController.add(self, name: "appIron")
        webView.configuration.userContentController.add(self, name: "setAppVersion")
        
        // MARK: - URL 띄우기
        guard let myURL = URL(string: "http://dpis.mnd.go.kr:8090") else { return exitApp() } // 운영
        //        //        let myURL = URL(string: "https://m.naver.com") // naver
        //        let myRequest = URLRequest(url: myURL!)
        //        webView.load(myRequest)
        
        // 로컬파일 띄우기
        let file = Bundle.main.url(forResource: "test", withExtension: "html")!
        webView.loadFileURL(file, allowingReadAccessTo: file)
        let request = URLRequest(url: file)
        webView.load(request)
        
        // 앱 위변조 방지
        appIronInit(myURL: file)
        
    }
    
    //    // 캡쳐 방지
    //    @objc func didDetectScreenshot() {
    //        let alert = UIAlertController(title: "캡쳐 방지", message: "캡쳐가 불가능합니다.", preferredStyle: .alert)
    //        let okAction = UIAlertAction(title: "확인", style: .default)
    //        alert.addAction(okAction)
    //        present(alert, animated: true, completion: nil)
    //    }
    
    // MARK: - 앱 위변조 방지
    func appIronInit(myURL: URL) {
        let appIron = TouchEnAppIron(serverDomain: myURL, userValue: "Joseph Cha")
        appIron.remove { deviceData, error, errorMessage in
            let data = cryptoUtils.decryt(deviceData as Data)
            let dic: NSDictionary? = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? NSDictionary
            guard let dictionary = dic as? [String: String] else { return }
            
            if error.code == 0 {
                if dictionary["dfgkdfg1"] == "true" && dictionary["dfgkdfg2"] == "true" && dictionary["dfgkdfg3"] == "true"{
                    self.showToast_in(message: "앱위변조, OS 위변조, 디버깅탐지")
                    return
                }
                if dictionary["dfgkdfg1"] == "true" && dictionary["dfgkdfg2"] == "true" {
                    self.showToast_in(message: "앱위변조, OS 위변조")
                    return
                }
                if dictionary["dfgkdfg1"] == "true" && dictionary["dfgkdfg3"] == "true" {
                    self.showToast_in(message: "앱위변조, 디버깅탐지")
                    return
                }
                if dictionary["dfgkdfg2"] == "true" && dictionary["dfgkdfg3"] == "true" {
                    self.showToast_in(message: "OS 위변조, 디버깅탐지")
                    return
                }
                if dictionary["dfgkdfg1"] == "true" {
                    self.showToast_in(message: "앱위변조")
                    return
                }
                if dictionary["dfgkdfg2"] == "true" {
                    self.showToast_in(message: "OS 위변조")
                    return
                }
                if dictionary["dfgkdfg3"] == "true" {
                    self.showToast_in(message: "디버깅탐지")
                    return
                }
                if dictionary["dfgkdfg1"] == "false" && dictionary["dfgkdfg2"] == "false" && dictionary["dfgkdfg3"] == "false"{
                    self.showToast_in(message: "정상동작")
                    return
                }
            } else {
                self.showToast_in(message: "검증 실패\n에러코드: \(error.code) \n에러메시지:\(errorMessage).", isError: true)
            }
        }
    }
    
    // Toast
    func showToast_in(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0), isDetecting: Bool = false, isError: Bool = false) {
        var width: CGFloat = 150
        var height: CGFloat = 35
        
        if isError {
            width = 400
            height = 70
            
        }
        DispatchQueue.main.async {
            var toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2 - 75, y: self.view.frame.size.height - 100, width: width, height: height))
            if isError {
                toastLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 100, width: UIScreen.main.bounds.width, height: height))
            }
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.numberOfLines = 3
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds = true
            toastLabel.minimumScaleFactor = 0.2
            self.view.addSubview(toastLabel)
            if isDetecting {
                toastLabel.frame = CGRect(x: self.view.frame.size.width / 2 - 75, y: self.view.frame.size.height - 50, width: width, height: height)
                UIView.animate(withDuration: 1.0, delay: 1, options: .curveEaseOut,
                               animations: {
                    toastLabel.alpha = 0.0
                },completion: {(isCompleted) in
                    toastLabel.removeFromSuperview()
                })
            } else {
                UIView.animate(withDuration: 2.0, delay: 1, options: .curveEaseOut,
                               animations: {
                    toastLabel.alpha = 0.0
                },completion: {(isCompleted) in
                    toastLabel.removeFromSuperview()
                })
            }
        }
    }
    
    // MARK: - 팝업 처리
    // 팝업 열기
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        toolbar.isHidden = false
        
        popupView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        popupView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView?.uiDelegate = self
        popupView?.navigationDelegate = self
        popupView?.scrollView.isScrollEnabled = false
        popupView?.scrollView.bounces = false
        popupView?.scrollView.showsVerticalScrollIndicator = false
        popupView?.scrollView.showsHorizontalScrollIndicator = false
        webView.addSubview(popupView!)
        
        return popupView
    }
    
    // 팝업 닫기
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupView {
            popupView?.removeFromSuperview()
            popupView = nil
        }
        toolbar.isHidden = true
    }
    
    // MARK: - app버전 확인
    func isUpdateAvailable() -> Bool {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let latestVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        guard let currentVersion, let latestVersion else { return false }
        
        return currentVersion != latestVersion
    }
    
    func setAppVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        webView.evaluateJavaScript("NativeInterface.setAppVersion(\(currentVersion ?? "없음"));")
    }
    
    func updateApp() {
        let appID = "12345";
        let updateAlert = UIAlertController(title: "업데이트 확인", message: "새로운 버전의 앱이 있습니다. 업데이트 하시겠습니까?", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            // TODO: appID 교체하고 주석해제
            //            UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/id\(appID)")!, options: [:], completionHandler: nil)
            UIApplication.shared.open(URL(string: "https://m.naver.com")!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        updateAlert.addAction(updateAction)
        updateAlert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(updateAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - 네트워크 확인
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard Reachability.networkConnected() else {
            let alert = UIAlertController(title: "네트워크 연결 확인", message: "인터넷 연결을 확인해주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "종료", style: .default) { _ in
                self.exitApp()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    // 앱 강제종료
    func exitApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    // MARK: - 단말기 고유정보
    func getUUID() -> String? {
        
        let keychain = KeychainAccess()
        let uuidKey = "com.myorg.myappid.unique_uuid"
        
        if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey), uuid != nil {
            return uuid
        }
        
        guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        
        try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
        
        return newId
    }
    
    func setDeviceId(deviceId: String) {
        
        let deviceInfo = DeviceIds(deviceId: deviceId ?? "Error fetching Device Id")
        
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(deviceInfo)
            if let deviceIds = String(data: jsonData, encoding: .utf8) {
                webView.evaluateJavaScript("NativeInterface.setDeviceId(\(deviceIds));")
            }
        } catch {
            print(error)
        }
    }
    
}

// MARK: - Extensions
extension ViewController: WKUIDelegate, WKNavigationDelegate, WKDownloadDelegate {
    
    // Download
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping @MainActor @Sendable (URL?) -> Void) {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(suggestedFilename)
        
        let documentInteractionController = UIDocumentInteractionController(url: destinationURL)
        documentInteractionController.delegate = self
        documentInteractionController.presentPreview(animated: true)
        
        completionHandler(destinationURL)
        
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    // WKDownloadDelegate 콜백함수
    func downloadDidFinish(_ download: WKDownload) {
        
        let alert = UIAlertController(title: "", message: "다운로드 완료", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // WKDownloadDelegate 콜백함수
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        
        let alert = UIAlertController(title: "", message: "다운로드 실패", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 다운로드 기능
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if navigationAction.shouldPerformDownload {
            decisionHandler(.download, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    // 다운로드 기능
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            decisionHandler(.download)
        }
    }
    
    // alert 설정
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // confirm 설정
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (Bool) -> Void) {
        let confirm = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        confirm.addAction(okAction)
        confirm.addAction(cancelAction)
        self.present(confirm, animated: true, completion: nil)
    }
    
    // prompt 설정
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (String?) -> Void) {
        let input = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        input.addTextField { textField in
            textField.text = defaultText
        }
        let okaction = UIAlertAction(title: "확인", style: .default) { _ in
            if let text = input.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(nil)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(nil)
        }
        
        
        input.addAction(okaction)
        input.addAction(cancelAction)
        self.present(input, animated: true, completion: nil)
    }
}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
        case "logHandler":
            print("console log: \(message.body)")
        case "forceQuitApp":
            exitApp()
        case "setDeviceId":
            setDeviceId(deviceId: getUUID()!)
        case "setAppVersion":
            setAppVersion()
        case "updateApp":
            updateApp()
        case "appIron":
            appIronInit(myURL: URL(string: "http://dpis.mnd.go.kr:8090")!)
        default:
            break
        }
    }
}



