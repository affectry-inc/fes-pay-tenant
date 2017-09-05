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
    
    let i18n = I18n(tableName: "QRCaptureView")
    
    // MARK: - Properties

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    
    var payInfo: PayInfo?
    
    var captureSesssion: AVCaptureSession!
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
                    captureSesssion.startRunning()
                    // QRコードを検出した際のデリゲート設定
                    stillImageOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    // QRコードの認識を設定
                    stillImageOutput?.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                    
                    // アスペクト比、カメラの向き(縦)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    cameraView.layer.addSublayer(previewLayer!)
                }
            }
        }
        catch {
            print(error)
        }
        LoadingProxy.set(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "qrCode")
        self.captureLabel.text = i18n.localize(key: "msgCaptureQR")
        self.captureButton.isHidden = TARGET_OS_SIMULATOR != 1
        
        self.captureLabel.layer.borderColor = UIColor.red.cgColor
        self.captureLabel.layer.borderWidth = 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ビューのサイズの調整
        if let previewLayer = previewLayer {
            previewLayer.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
            previewLayer.bounds = cameraView.frame
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSesssion.stopRunning()
        
        for output in captureSesssion.outputs {
            captureSesssion.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in captureSesssion.inputs {
            captureSesssion.removeInput(input as? AVCaptureInput)
        }
        
        captureSesssion = nil
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
                let navHeight = self.navigationController?.navigationBar.bounds.height
                qrView!.frame = barCode.bounds
                qrView!.frame.origin.y = qrView!.frame.origin.y + navHeight! + 20
                
                if let str = metadata.stringValue {
                    LoadingProxy.on()
                    captureSesssion.stopRunning()
                    
                    // 検出データを取得
                    let yeahRange = str.range(of: "yeah")!
                    let yeahIndex = str.index(after: yeahRange.upperBound)
                    let bandId = str.substring(from: yeahIndex)
                    
                    FirebaseClient.isActiveBand(bandId: bandId, onActive: {
                        self.payInfo?.bandId = bandId
                        self.performSegue(withIdentifier: "FaceCaptureView", sender: nil)
                        LoadingProxy.off()
                    }, onNotActive: {
                        let alert = self.i18n.alert(titleKey: "titleNotActive", messageKey: "msgNotActive", handler: {
                            self.qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                            LoadingProxy.off()
                            self.captureSesssion.startRunning()
                        })
                        self.present(alert, animated: true)
                    }, onError: {
                        let alert = self.i18n.alert(titleKey: "titleCaptureError", messageKey: "msgCaptureError", handler: {
                            self.qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                            LoadingProxy.off()
                            self.captureSesssion.startRunning()
                        })
                        self.present(alert, animated: true)
                    })
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "FaceCaptureView" {
            guard let faceCaptureView = segue.destination as? FaceCaptureViewController else {
                os_log("The destination is not a FaceCaptureView", log: OSLog.default, type: .debug)
                return
            }
            faceCaptureView.payInfo  = self.payInfo
        }
    }

}
