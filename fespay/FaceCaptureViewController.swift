//
//  FaceCaptureViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/26.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

class FaceCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    // MARK: - Properties
    var payInfo: PayInfo?
    
    let tenantInfo = TenantInfo.sharedInstance
    
    @IBOutlet weak var cameraView: UIView!
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Events
    
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
                    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    
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
    
    // MARK: - Actions
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        // カメラの設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        
        // 撮影
        if (previewLayer != nil) { // TODO: 消す
            stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        } else {
            self.payInfo?.buyerImage = UIImage(named: "katosan")
            execVerify()
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            self.payInfo?.buyerImage = UIImage(data: photoData!)
            
            execVerify()
        }
    }
    
    func verify(faceId: String, personGroupId: String, personId: String) {
        AzureClient.verify(faceId: faceId, personGroupId: (payInfo?.bandId)!, personId: personId, onVerify: {
            (veriRes: [String: Any]) in
            
            self.payInfo?.confidence = (veriRes["confidence"] as! Double) * 100
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "FaceConfirmView") as! FaceConfirmViewController
            
            next.payInfo = self.payInfo
            // next.conf = (veriRes["confidence"] as! Double) * 100
            // next.equal = veriRes["isIdentical"] as! Bool
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(next, animated: true)
            }
        })
    }
    
    func onDetect(photoUrl: String, faces: [[String: Any]]) {
        if faces.count == 1 {
            // 正常処理
            let faceId = faces[0]["faceId"] as! String
            FirebaseClient.findPerson(bandId: (self.payInfo?.bandId)!, onFind: { (personId: String, personPhotoUrl: String) in
                
                let personImageData = try? Data(contentsOf: URL(string: personPhotoUrl)!, options: .mappedIfSafe)
                
                self.payInfo?.personId = personId
                self.payInfo?.personPhotoUrl = personPhotoUrl
                self.payInfo?.personImage = UIImage(data: personImageData!)
                
                self.verify(faceId: faceId, personGroupId:  (self.payInfo?.bandId)!, personId: personId)
            })
        } else if faces.count == 0 {
            // TODO: ０件ですよ
        } else {
            // TODO: 顔選択からのfaceId投げ
        }
    }
    
    func onUpload(buyerPhotoUrl: String) {
        self.payInfo?.buyerPhotoUrl = buyerPhotoUrl
        
        AzureClient.detectFace(photoUrl: buyerPhotoUrl, onDetect: self.onDetect)
    }
    
    func execVerify() {
        S3Client.uploadBuyerPhoto(fesId: self.tenantInfo.fesId, bandId: (self.payInfo?.bandId)!, image: (self.payInfo?.buyerImage)!, onUpload: self.onUpload)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}
