//
//  URL+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 04.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation
import Photos

extension URL {
    func getThumbnailImageFromVideoUrl(completion: @escaping ((_ image: UIImage?) -> Void)) {
        DispatchQueue.global().async {
            let avAsset = AVAsset(url: self)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: avAsset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func drawPDFfromURL(completion: @escaping ((_ image: UIImage?) -> Void)) {
        guard let document = CGPDFDocument(self as CFURL) else {
            completion(nil)
            return
        }
        guard let page = document.page(at: 1) else {
            completion(nil)
            return
        }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let image = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(page)
        }
        completion(image)
    }
}
