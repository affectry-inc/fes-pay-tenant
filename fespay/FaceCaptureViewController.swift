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
// import AWSS3
// import Firebase

class FaceCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    // MARK: - Properties
    // var payInfo: PayInfo?
    var price: Double?
    var payer: String?
    var capturedImage: UIImage?
    var registeredImage: UIImage?
    let fesId: String = "FES_A"
    
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
            self.capturedImage = UIImage(named: "katosan")
            execVerify()
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            self.capturedImage = UIImage(data: photoData!)
            
            execVerify()
        }
    }
    
    func verify(faceId: String, personGroupId: String, personId: String, photoUrl: String) {
        AzureClient.verify(faceId: faceId, personGroupId: self.payer!, personId: personId, onVerify: {
            (veriRes: [String: Any]) in
            
            let url = URL(string: photoUrl)!
            let imageData = try? Data(contentsOf: url, options: .mappedIfSafe)
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "FaceConfirmView") as! FaceConfirmViewController
            
            next.price = self.price
            next.payer = self.payer
            next.capImg = self.capturedImage
            next.regImg = UIImage(data:imageData!)
            next.conf = (veriRes["confidence"] as! Double) * 100
            next.equal = veriRes["isIdentical"] as! Bool
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(next, animated: true)
            }
        })
    }
    
    func onDetect(photoUrl: String, faces: [[String: Any]]) {
        if faces.count == 1 {
            // 正常処理
            let faceId = faces[0]["faceId"] as! String
            FirebaseClient.findPerson(bandId: self.payer!, onFind: { (personId: String, photoUrl: String) in
                self.verify(faceId: faceId, personGroupId:  self.payer!, personId: personId, photoUrl: photoUrl)
            })
        } else if faces.count == 0 {
            // TODO: ０件ですよ
        } else {
            // TODO: 顔選択からのfaceId投げ
        }
    }
    
    func detect(photoUrl: String) {
        AzureClient.detectFace(photoUrl: photoUrl, onDetect: self.onDetect)
    }
    
    func execVerify() {
        S3Client.uploadBuyerPhoto(fesId: self.fesId, bandId: self.payer!, image: self.capturedImage!, onUpload: self.detect)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "FaceConfirmView" {
            guard let faceConfirmView = segue.destination as? FaceConfirmViewController else {
                os_log("The destination is not a FaceConfirmView", log: OSLog.default, type: .debug)
                return
            }
            faceConfirmView.price = self.price
            faceConfirmView.payer = self.payer
            faceConfirmView.capImg = self.capturedImage
        }
    }

}
