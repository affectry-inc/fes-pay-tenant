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
import AWSS3
import Firebase

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
    
    func uploadPhoto() {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMddHHmmss"
        let ts = fmt.string(from: Date())
        // let ts = Int(Date().timeIntervalSince1970)
        let fileName = "\(ts)_\(self.payer!).JPG"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fespay").appendingPathExtension(fileName)
        let imageData = UIImageJPEGRepresentation(self.capturedImage!, 0.5)
        do {
            try imageData!.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "fespay-dev"
        uploadRequest?.key = "buyer_photos/\(self.fesId)/\(fileName)"
        uploadRequest?.body = fileURL
        uploadRequest?.acl = .publicRead
        uploadRequest?.contentType = "image/jpeg"
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                return nil
            }
            
            let buyerPhoto = "https://s3-ap-northeast-1.amazonaws.com/fespay-dev/buyer_photos/\(self.fesId)/\(fileName)"
            print("buyer: \(buyerPhoto)")
            
            return self.detectBuyer(photoUrl: buyerPhoto)
        }
    }
    
    func detectBuyer(photoUrl: String) {
        var request = URLRequest(url: URL(string: "https://westus.api.cognitive.microsoft.com/face/v1.0/detect")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("ba8c31c918864b969eb1601590167f93", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = "{\"url\":\"\(photoUrl)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil {
                print("detectBuyer error: \(error!)")
                return
            }
            
            let data = try! JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
            let faceId = data[0]["faceId"] as! String
            print("faceId: \(faceId)")
            
            return self.verifyPerson(faceId: faceId)
        }
        task.resume()
    }
    
    func verifyPerson(faceId: String) {
        // MARK: get personId from Firebase
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(self.payer!).observeSingleEvent(of: .value, with: { (snapshot) in
            let person = snapshot.value as? [String: Any]
            let persons = person?["persons"] as! [String: Bool]
            let personId = persons.first!.key
            let registeredPhoto = person?["photoUrl"] as! String
            print("personId: \(personId)")
            
            // MARK: verify
            var request = URLRequest(url: URL(string: "https://westus.api.cognitive.microsoft.com/face/v1.0/verify")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("ba8c31c918864b969eb1601590167f93", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.httpBody = "{\"faceId\":\"\(faceId)\",\"personGroupId\":\"\(self.payer!)\",\"personId\":\"\(personId)\"}".data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                
                if error != nil {
                    print("verify error: \(error!)")
                    return
                }
                
                let veriRes = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                print("verify: \(veriRes)")
                
                // MARK: Navigate to confirm
                let url = URL(string: registeredPhoto)!
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
            }
            task.resume()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func execVerify() {
        self.uploadPhoto()
        // MARK: Upload to S3
        /*
        let ts = Int(Date().timeIntervalSince1970)
        let fileName = "\(ts)_\(self.payer!).JPG"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fespay").appendingPathExtension(fileName)
        let imageData = UIImageJPEGRepresentation(self.capturedImage!, 0.5)
        do {
            try imageData!.write(to: fileURL, options: .atomic)
        } catch {
            print(error)
        }
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "fespay-dev"
        uploadRequest?.key = "buyer_photos/\(ts)_\(self.payer!)/\(fileName)"
        uploadRequest?.body = fileURL
        uploadRequest?.acl = .publicRead
        uploadRequest?.contentType = "image/jpeg"
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                return nil
            }
            
            return nil
        }
        
        let buyerPhoto = "https://s3-ap-northeast-1.amazonaws.com/fespay-dev/buyer_photos/\(ts)_\(self.payer!)/\(fileName)"
        
        print("buyer: \(buyerPhoto)")
        
        // MARK: Get personId of band holder from Firebase
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(self.payer!).observeSingleEvent(of: .value, with: { (snapshot) in
            let person = snapshot.value as? [String: Any]
            let persons = person?["persons"] as! [String: Bool]
            let personId = persons.first!.key 
            let registeredPhoto = person?["photoUrl"] as! String
            print("personId: \(personId)")
            
            // MARK: Verification
            // MARK: detect 1
            var request = URLRequest(url: URL(string: "https://westus.api.cognitive.microsoft.com/face/v1.0/detect")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("ba8c31c918864b969eb1601590167f93", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.httpBody = "{\"url\":\"\(buyerPhoto)\"}".data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request){
                data, response, error in
                
                if error != nil {
                    print("detect1 error: \(error!)")
                    return
                }
                
                let data1 = try! JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                let faceId1 = data1[0]["faceId"] as! String
                print("faceId1: \(faceId1)")
                
                // MARK: verify
                var request = URLRequest(url: URL(string: "https://westus.api.cognitive.microsoft.com/face/v1.0/verify")!)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("ba8c31c918864b969eb1601590167f93", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
                // request.httpBody = "{\"faceId1\":\"\(faceId1)\",\"faceId2\":\"\(faceId2)\"}".data(using: String.Encoding.utf8)
                request.httpBody = "{\"faceId\":\"\(faceId1)\",\"personGroupId\":\"\(self.payer!)\",\"personId\":\"\(personId)\"}".data(using: String.Encoding.utf8)
            
                let task = URLSession.shared.dataTask(with: request){
                    data, response, error in
                    
                    if error != nil {
                        print("verify error: \(error!)")
                        return
                    }
                    
                    let data3 = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    print("verify: \(data3)")
                    
                    // MARK: Navigate to confirm
                    let url = URL(string: registeredPhoto)!
                    let imageData = try? Data(contentsOf: url, options: .mappedIfSafe)
                    
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "FaceConfirmView") as! FaceConfirmViewController
                    
                    next.price = self.price
                    next.payer = self.payer
                    next.capImg = self.capturedImage
                    next.regImg = UIImage(data:imageData!)
                    next.conf = (data3["confidence"] as! Double) * 100
                    next.equal = data3["isIdentical"] as! Bool
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(next, animated: true)
                    }
                }
                task.resume()
            }
            task.resume()
        }) { (error) in
            print(error.localizedDescription)
        }
        */
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
