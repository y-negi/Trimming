//
//  TrimmingPresenter.swift
//  Trimming
//
//  Created by 根岸 裕太 on 2020/11/24.
//

import Foundation

protocol TrimmingPresenterOutput {
    func dismiss()
    func setTargetImage(data: Data)
}

final class TrimmingPresenter {

    // MARK: - Variables

    private let output: TrimmingPresenterOutput
    private let imageData: Data?

    // MARK: - Initialize

    init(output: TrimmingPresenterOutput,
         imageData: Data) {
        self.output = output
        self.imageData = imageData
    }

    // MARK: - Publics

    /// viewDidLoad時処理
    func viewDidLoad() {
        guard let unwrapImageData = self.imageData else { return }
        self.output.setTargetImage(data: unwrapImageData)
    }

    /// キャンセルボタンタップ時処理
    func tapCancelButton() {
        self.output.dismiss()
    }

    /// OKボタンタップ時処理
    /// - Parameter croppedImageData: 切り抜き済み画像データ
    func tapOkButton(croppedImageData: Data) {
        self.output.dismiss()
    }
}
