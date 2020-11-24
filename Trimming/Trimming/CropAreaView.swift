//
//  CropAreaView.swift
//  Trimming
//
//  Created by 根岸 裕太 on 2020/11/24.
//

import UIKit

final class CropAreaView: UIView {

    // MARK: - Variables

    private var cropArea: CGRect?
    private var hollowLayer: CALayer?

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Publics

    /// Viewのセットアップ
    /// - Parameter cropArea: くり抜く位置のCGRect
    func setup(cropArea: CGRect) {
        self.cropArea = cropArea

        self.hollowLayer?.removeFromSuperlayer()

        self.hollowLayer = self.createHollowLayer(area: cropArea)
        self.layer.addSublayer(self.hollowLayer!)
    }

    // MARK: - Privates

    /// 円状の穴が空いたLayerを生成する
    ///
    /// - Parameter area: 穴を開ける位置のCGRect
    /// - Returns: Layer
    private func createHollowLayer(area: CGRect) -> CALayer {
        // 繰り抜きたいレイヤーを作成する
        let hollowTargetLayer = CALayer()
        hollowTargetLayer.bounds = self.bounds
        hollowTargetLayer.position = CGPoint(
            x: self.bounds.width / 2.0,
            y: self.bounds.height / 2.0
        )
        hollowTargetLayer.backgroundColor = #colorLiteral(red: 0.1529411765, green: 0.137254902, blue: 0.1254901961, alpha: 1)
        hollowTargetLayer.opacity = 0.6

        // 四角いマスクレイヤーを作る
        let maskLayer = CAShapeLayer()
        maskLayer.bounds = hollowTargetLayer.bounds

        let path = UIBezierPath(ovalIn: area)
        path.append(UIBezierPath(rect: maskLayer.bounds))

        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.path = path.cgPath
        maskLayer.position = CGPoint(
            x: hollowTargetLayer.bounds.width / 2.0,
            y: hollowTargetLayer.bounds.height / 2.0
        )
        // マスクのルールをeven/oddに設定する
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        hollowTargetLayer.mask = maskLayer

        return hollowTargetLayer
    }

}
