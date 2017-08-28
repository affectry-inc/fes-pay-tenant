//
//  LoadingProxy.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/08/28.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

struct LoadingProxy{
    
    static var myActivityIndicator: UIActivityIndicatorView!
    
    static func set(_ v: UIViewController){
        self.myActivityIndicator = UIActivityIndicatorView()
        self.myActivityIndicator.frame = CGRect(x:0, y:0, width:200, height:100)
        self.myActivityIndicator.center = v.view.center
        self.myActivityIndicator.hidesWhenStopped = true
        self.myActivityIndicator.activityIndicatorViewStyle = .white
        self.myActivityIndicator.backgroundColor = .gray;
        self.myActivityIndicator.layer.masksToBounds = true
        self.myActivityIndicator.layer.cornerRadius = 5.0;
        self.myActivityIndicator.layer.opacity = 0.8;
        v.view.addSubview(self.myActivityIndicator);
        
        self.off();
    }
    static func on(){
        myActivityIndicator.startAnimating();
    }
    static func off(){
        myActivityIndicator.stopAnimating();
    }
    
}
