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

    let i18n = I18n(tableName: "FaceCaptureView")
    
    // MARK: - Properties
    var payInfo: PayInfo?
    
    let tenantInfo = TenantInfo.sharedInstance
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    
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
                    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                    previewLayer?.bounds = cameraView.frame
                    
                    cameraView.layer.addSublayer(previewLayer!)
                }
            }
        }
        catch {
            print(error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "captureFace")
        self.captureButton.setTitle(i18n.localize(key: "capture"), for: .normal)
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
    
    // MARK: - Actions
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        // カメラの設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        
        // 撮影
        if (captureSesssion.isRunning) {// TODO: 消す
            stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        } else {
            self.payInfo?.buyerImage = UIImage(named: "katosan")
            execVerify()
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        captureSesssion.stopRunning()
        
        if let photoSampleBuffer = photoSampleBuffer {
            
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            
            self.payInfo?.buyerImage = UIImage(data: photoData!)
            
            execVerify()
        }
    }
    
    func verify(faceId: String, personId: String) {
        AzureClient.verify(faceId: faceId, personGroupId: (self.payInfo?.bandId)!, personId: personId, onVerify: {
            (veriRes: [String: Any]) in
            
            self.payInfo?.confidence = (veriRes["confidence"] as! Double) * 100
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "FaceConfirmView") as! FaceConfirmViewController
            
            next.payInfo = self.payInfo
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(next, animated: true)
            }
        })
    }
    
    func onDetect(photoUrl: String, faces: [[String: Any]]) {
        if faces.count == 1 {
            // 正常処理
            let faceId = faces[0]["faceId"] as! String
            FirebaseClient.findPerson(bandId: (self.payInfo?.bandId)!, onFind: { personId, personPhotoUrl, uid, cardCustomerId, cardLastDigits in
                
                let personImageData = try? Data(contentsOf: URL(string: personPhotoUrl)!, options: .mappedIfSafe)
                
                self.payInfo?.bandUid = uid
                self.payInfo?.personImage = UIImage(data: personImageData!)
                self.payInfo?.personId = personId
                self.payInfo?.personPhotoUrl = personPhotoUrl
                self.payInfo?.cardCustomerId = cardCustomerId
                self.payInfo?.cardLastDigits = cardLastDigits
                
                self.verify(faceId: faceId, personId: personId)
            })
        } else if faces.count == 0 {
            let msgNoFaceDetected = i18n.localize(key: "noFaceDetected")
            let msgReCapture = i18n.localize(key: "reCapture")

            let alert: UIAlertController = UIAlertController(title: msgNoFaceDetected, message: msgReCapture, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { action -> Void in /* Do nothing */})
            alert.addAction(okAction)
            present(alert, animated: true, completion: { self.captureSesssion.startRunning() })
        } else {
            // TODO: 顔選択からのfaceId投げ
            let msgMultipleFacesDetected = i18n.localize(key: "multipleFacesDetected")
            let msgSelectBuyer = i18n.localize(key: "reCapture")
            
            let alert: UIAlertController = UIAlertController(title: msgMultipleFacesDetected, message: msgSelectBuyer, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { action -> Void in /* Do nothing */})
            alert.addAction(okAction)
            present(alert, animated: true, completion: { self.captureSesssion.startRunning() })
        }
    }
    
    func onUpload(buyerPhotoUrl: String) {
        self.payInfo?.buyerPhotoUrl = buyerPhotoUrl
        AzureClient.detectFace(photoUrl: buyerPhotoUrl, onDetect: self.onDetect)
    }
    
    func execVerify() {
        S3Client.uploadBuyerPhoto(eventId: self.tenantInfo.eventId, bandId: (self.payInfo?.bandId)!, image: (self.payInfo?.buyerImage)!, onUpload: self.onUpload)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}
