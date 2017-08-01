//
//  S3Client.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/07.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation
import os.log
import AWSS3

class S3Client: NSObject {
    
    class func uploadBuyerPhoto(eventId: String, bandId: String, image: UIImage, onUpload: @escaping (String) -> ()) {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyyMMddHHmmss"
        let ts = fmt.string(from: Date())
        let fileName = "\(ts)_\(bandId).JPG"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("fespay").appendingPathExtension(fileName)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        do {
            try imageData!.write(to: fileURL, options: .atomic)
        } catch {
            os_log("imageData!.write Error: %@", log: .default, type: .error, error as CVarArg)
            return
        }
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "fespay-dev"
        uploadRequest?.key = "buyer_photos/\(eventId)/\(fileName)"
        uploadRequest?.body = fileURL
        uploadRequest?.acl = .publicRead
        uploadRequest?.contentType = "image/jpeg"
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task: AWSTask) -> Any? in
            if let error = task.error as NSError? {
                os_log("uploadBuyerPhoto Error: %s", log: .default, type: .error, error)
                return nil
            }
            
            let buyerPhotoUrl = "https://s3-ap-northeast-1.amazonaws.com/fespay-dev/buyer_photos/\(eventId)/\(fileName)"
            os_log("photoUrl: %@", log: .default, type: .debug, buyerPhotoUrl)
            
            onUpload(buyerPhotoUrl)
            
            return nil
        }
    }

}
