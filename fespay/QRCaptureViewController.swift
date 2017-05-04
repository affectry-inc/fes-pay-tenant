//
//  QRCaptureViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/03.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

class QRCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var cameraView: UIView!
    
    var payInfo: PayInfo?
    
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        captureSesssion = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        
        // 解像度の設定
        captureSesssion.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            // 入力
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                
                // 出力
                if (captureSesssion.canAddOutput(stillImageOutput)) {
                    
                    // カメラ起動
                    captureSesssion.addOutput(stillImageOutput)
                    captureSesssion.startRunning()
                    
                    // アスペクト比、カメラの向き(縦)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    cameraView.layer.addSublayer(previewLayer!)
                    
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                    previewLayer?.bounds = cameraView.frame
                }
            }
        }
        catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
