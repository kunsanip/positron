//
//  WebViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 3/9/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit
import WebKit
class WebViewController: UIViewController,WKNavigationDelegate {
    var webView : WKWebView!

    override func loadView() {
   
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = WKWebView()
        webView.navigationDelegate = self
        let url =  URL(string: "https://www.aquasarmedia.com/monkeymindapp/privacypolicy.html")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        view = webView

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
