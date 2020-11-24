//
//  UIImage+Trimming.swift
//  Trimming
//
//  Created by 根岸 裕太 on 2020/11/24.
//

import UIKit

extension UIImage {

    /// UIImageの指定箇所を切り取り、返すメソッド
    ///
    /// - Parameter cropRect: 切り取る箇所
    /// - Returns: 切り取った画像
    func cropped(to cropRect: CGRect) -> UIImage? {
        var opaque = false
        if let unwrappedCGImage = cgImage {
            switch unwrappedCGImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }

        UIGraphicsBeginImageContextWithOptions(cropRect.size, opaque, scale)
        draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }

}
