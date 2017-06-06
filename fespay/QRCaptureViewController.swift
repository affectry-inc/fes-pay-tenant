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

class QRCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Properties

    @IBOutlet weak var cameraView: UIView!
    
    // var payInfo: PayInfo?
    var price: Double?
    var payer: String? = "a001"
    
    var captureSesssion: AVCaptureSession!
    // var stillImageOutput: AVCapturePhotoOutput?
    var stillImageOutput: AVCaptureMetadataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var qrView: UIView!
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // QRコードをマークするビュー
        qrView = UIView()
        qrView.layer.borderWidth = 4
        qrView.layer.borderColor = UIColor.red.cgColor
        qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        view.addSubview(qrView)

        captureSesssion = AVCaptureSession()
        // stillImageOutput = AVCapturePhotoOutput()
        stillImageOutput = AVCaptureMetadataOutput()
        
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
                    
                    captureSesssion.addOutput(stillImageOutput)
                    // QRコードを検出した際のデリゲート設定
                    stillImageOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    // QRコードの認識を設定
                    stillImageOutput?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                    
                    // アスペクト比、カメラの向き(縦)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    cameraView.layer.addSublayer(previewLayer!)
                    
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                    previewLayer?.bounds = cameraView.frame
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.captureSesssion.startRunning()
                    }
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
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // 複数のメタデータを検出できる
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type == AVMetadataObjectTypeQRCode {
                // 検出位置を取得
                let barCode = previewLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                qrView!.frame = barCode.bounds
                if metadata.stringValue != nil {
                    // 検出データを取得
                    let str = metadata.stringValue!
                    self.payer = str.substring(from: str.index(str.endIndex, offsetBy: -5))
                    
                    // performSegue(withIdentifier: "PasscodeView", sender: nil)
                    performSegue(withIdentifier: "FaceCaptureView", sender: nil)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.captureSesssion.stopRunning()
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "PasscodeView" {
            guard let passcodeView = segue.destination as? PasscodeViewController else {
                os_log("The destination is not a PasscodeView", log: OSLog.default, type: .debug)
                return
            }
            passcodeView.price = self.price
            passcodeView.payer = self.payer
        }
        else if segue.identifier == "FaceCaptureView" {
            guard let faceCaptureView = segue.destination as? FaceCaptureViewController else {
                os_log("The destination is not a FaceCaptureView", log: OSLog.default, type: .debug)
                return
            }
            faceCaptureView.price = self.price
            faceCaptureView.payer = self.payer
        }
    }

}
