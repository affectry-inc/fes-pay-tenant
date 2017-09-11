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
    @IBOutlet weak var captureLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingProxy.set(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                }
            }
        }
        catch {
            print(error)
        }
        
        self.navigationItem.title = i18n.localize(key: "captureFace")
        self.captureLabel.text = i18n.localize(key: "msgCaptureFace")
        self.captureButton.setTitle(i18n.localize(key: "capture"), for: .normal)
        
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
    
    // MARK: - Actions
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        // カメラの設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        
        // 撮影
        if (captureSesssion.isRunning) {
            stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
            
            startLoading()
        } else {
            //  エミュレータの場合
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
            
            DispatchQueue.main.async {
                self.stopLoading()
                self.performSegue(withIdentifier: "FaceConfirmView", sender: nil)
            }
        })
    }
    
    func onDetect(photoUrl: String, faces: [[String: Any]]) {
        if faces.count == 1 {
            // 顔検出
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
            
            // トリム
            let faceRectangle = faces[0]["faceRectangle"] as! [String: Int]
            
            let w: Int = faceRectangle["width"]!
            let h: Int = faceRectangle["height"]!
            let l: Int = faceRectangle["left"]!
            let t: Int = faceRectangle["top"]!
            let nw = w * 2
            let nh = nw * 150 / 130
            let nl = l - (nw - w) / 2
            let nt = t - (nh - h) / 2
            
            let rect = CGRect.init(x: nl, y: nt, width: nw, height: nh)
            let orgImage = self.payInfo?.buyerImage
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, (orgImage?.scale)!)
            orgImage?.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            S3Client.uploadBuyerPhoto(eventId: self.tenantInfo.eventId, bandId: (self.payInfo?.bandId)!, image: image!, onUpload: { buyerPhotoUrl in
                self.payInfo?.buyerImage = image
                self.payInfo?.buyerPhotoUrl = buyerPhotoUrl
            })
        } else if faces.count == 0 {
            present(i18n.alert(titleKey: "noFaceDetected", messageKey: "reCapture"), animated: true, completion: {
                self.stopLoading()
                
                self.captureSesssion.startRunning()
            })
        } else {
            // TODO: 顔選択からのfaceId投げにしたい
            present(i18n.alert(titleKey: "multipleFacesDetected", messageKey: "reCapture"), animated: true, completion: {
                self.stopLoading()
                
                self.captureSesssion.startRunning()
            })
        }
    }
    
    func onUpload(buyerPhotoUrl: String) {
        AzureClient.detectFace(photoUrl: buyerPhotoUrl, onDetect: self.onDetect)
    }
    
    func execVerify() {
        S3Client.uploadBuyerPhoto(eventId: self.tenantInfo.eventId, bandId: (self.payInfo?.bandId)!, image: (self.payInfo?.buyerImage)!, onUpload: self.onUpload)
    }

    private func startLoading() {
        LoadingProxy.on()
        self.captureButton.isEnabled = false
        self.captureButton.alpha = 0.8
    }
    
    private func stopLoading() {
        LoadingProxy.off()
        self.captureButton.isEnabled = true
        self.captureButton.alpha = 1
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "FaceConfirmView" {
            guard let faceConfirmView = segue.destination as? FaceConfirmViewController else {
                os_log("The destination is not a FaceConfirmView", log: OSLog.default, type: .debug)
                return
            }
            faceConfirmView.payInfo  = self.payInfo
        }
    }
    
    @IBAction func unwindToCaptureFace(sender: UIStoryboardSegue) {
        if sender.source is FaceConfirmViewController {
        }
    }

}
