//
//  UIImage+Resize.swift
//  Trimming
//
//  Created by 根岸 裕太 on 2020/11/24.
//

import UIKit

extension UIImage {

    /// リサイズした画像を返す
    ///
    /// - Parameter percentage: リサイズ率
    /// - Returns: リサイズした画像
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// リサイズした画像を返す
    /// - Parameter maxSize: 最大サイズ
    /// - Returns: リサイズした画像
    func resized(withMaxSize maxSize: CGSize) -> UIImage? {
        guard self.size.width > maxSize.width || self.size.height > maxSize.height else { return self }

        let toSize: CGSize
        if self.size.width > maxSize.width {
            toSize = CGSize(width: maxSize.width,
                            height: maxSize.width / self.size.width * self.size.height)
        } else {
            toSize = CGSize(width: maxSize.height / self.size.height * self.size.width,
                            height: maxSize.height)
        }

        UIGraphicsBeginImageContextWithOptions(toSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: toSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    /// 750KBを目安にリサイズする
    /// - Parameter maxSize: 最大サイズ
    /// - Returns: リサイズした画像
    func resizedTo750KB(maxSize: CGSize) -> UIImage? {
        guard let imageData = self.pngData() else { return nil }

        var resizingImage = self.resized(withMaxSize: maxSize)
        var imageSizeKB = Double(imageData.count) / 750.0

        while imageSizeKB > 750 {
            guard let resizedImage = resizingImage?.resized(withPercentage: 0.9),
                let imageData = resizedImage.pngData()
                else { return nil }

            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / 750.0
        }

        return resizingImage
    }

}
