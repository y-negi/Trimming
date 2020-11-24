//
//  TrimmingViewController.swift
//  Trimming
//
//  Created by 根岸 裕太 on 2020/11/09.
//

import Foundation
import UIKit
import AVFoundation

protocol TrimmingViewDelegateProtocol: AnyObject {
    func didCompleteTrimmingImageData(data imageData: Data)
}

final class TrimmingViewController: UIViewController {

    // MARK: - Variables

    private var presenter: TrimmingPresenter?
    weak var delegate: TrimmingViewDelegateProtocol?

    private let maxImageSize = CGSize(width: 300, height: 300)
    private var cropAreaWidth: CGFloat {
        return self.view.bounds.width * 0.9
    }
    private var cropAreaHeight: CGFloat {
        return self.cropAreaWidth
    }
    // 切り抜くFrame
    private lazy var cropArea = CGRect(x: self.backgroundScrollView.center.x - self.cropAreaWidth / 2,
                                       y: self.backgroundScrollView.center.y - self.cropAreaHeight / 2,
                                       width: self.cropAreaWidth,
                                       height: self.cropAreaHeight)
    // addSubViewするView
    private var targetImageView: UIImageView?
    private var cropAreaView: CropAreaView?

    // MARK: - Instantiate

    static func instantiate(imageData: Data) -> TrimmingViewController {
        let view = TrimmingViewController()
        let presenter = TrimmingPresenter(output: view, imageData: imageData)
        view.presenter = presenter
        return view
    }

    // MARK: - Outlets

    @IBOutlet private weak var backgroundScrollView: UIScrollView!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var okButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true

        self.targetImageView = UIImageView()
        self.backgroundScrollView.addSubview(self.targetImageView!)

        // CropAreaView配置
        self.cropAreaView = CropAreaView(frame: self.view.frame)
        self.cropAreaView?.isUserInteractionEnabled = false
        self.view.addSubview(self.cropAreaView!)
        self.cropAreaView?.translatesAutoresizingMaskIntoConstraints = false
        self.cropAreaView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.cropAreaView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.cropAreaView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.cropAreaView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        // パーツを最前面に持ってくる
        self.view.bringSubviewToFront(self.buttonsStackView)

        self.presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let size = self.targetImageView?.image?.size,
           let unwrapTargetImageView = self.targetImageView {
            // ImageViewのサイズがScrollView内に収まるように調整
            let widthRate = self.backgroundScrollView.frame.width / size.width
            let heightRate = self.backgroundScrollView.frame.height / size.height
            let rate = min(widthRate, heightRate, 1)
            let imageViewWidth = size.width * rate
            let imageViewHeight = size.height * rate
            let imageViewRate = self.cropArea.width / min(imageViewWidth, imageViewHeight)
            unwrapTargetImageView.frame.size = CGSize(width: imageViewWidth * imageViewRate,
                                                      height: imageViewHeight * imageViewRate)

            // ImageViewのサイズに合わせて縮小率を調整
            self.backgroundScrollView.minimumZoomScale = ceil(self.cropAreaWidth / min(unwrapTargetImageView.frame.width, unwrapTargetImageView.frame.height) * self.cropAreaHeight / 2) / self.cropAreaHeight / 2
            self.backgroundScrollView.minimumZoomScale = 1

            // ScrollViewのcontentSizeを画像サイズに設定
            self.backgroundScrollView?.contentSize = unwrapTargetImageView.frame.size

            // 初期表示位置を調整
            self.adjustContentPositionToCenter()

            // 初期表示のためcontentInsetを更新
            self.updateScrollInset()
        }

        // addSubViewしたViewのFrame更新
        self.cropAreaView?.setup(cropArea: self.cropArea)
    }

    // MARK: - Actions

    /// OKボタンタップ時
    ///
    /// - Parameter sender: UIButton
    @IBAction private func tapOkButton(_ sender: UIButton) {
        guard let image = self.targetImageView?.image,
              let croppedImage = self.cropImage(image),
              let resizedImage = croppedImage.resizedTo750KB(maxSize: self.maxImageSize),
              let pngData = resizedImage.pngData() else { return }
        self.delegate?.didCompleteTrimmingImageData(data: pngData)
        self.presenter?.tapOkButton(croppedImageData: pngData)
    }

    /// キャンセルボタン押下時処理
    ///
    /// - Parameter sender: UIBarButtonItem
    @IBAction private func tapCancelButton(_ sender: UIBarButtonItem) {
        self.presenter?.tapCancelButton()
    }

    // MARK: - Privates

    /// スクロールに応じてコンテンツの位置を中心に調整する
    private func adjustContentPositionToCenter() {
        guard let scrollView = self.backgroundScrollView,
              let imageView = self.targetImageView,
              let image = imageView.image else { return }

        let imageViewSize = imageView.frame.size
        let imageSize = image.size

        // コンテンツ（画像）の実サイズを取得する
        let realImageSize: CGSize
        if (imageSize.width / imageSize.height) > (imageViewSize.width / imageViewSize.height) {
            realImageSize = CGSize(width: imageViewSize.width, height: imageViewSize.width / imageSize.width * imageSize.height)
        } else {
            realImageSize = CGSize(width: imageViewSize.height / imageSize.height * imageSize.width, height: imageViewSize.height)
        }

        let screenSize  = scrollView.frame.size
        let offsetX = screenSize.width > realImageSize.width ? (screenSize.width - realImageSize.width) / 2 : 0
        let offsetY = screenSize.height > realImageSize.height ? (screenSize.height - realImageSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: offsetY,
                                               left: offsetX,
                                               bottom: offsetY,
                                               right: offsetX)
    }

    /// ScrollViewのInsetを調整する
    private func updateScrollInset() {
        // ImageViewの大きさから、切り抜きエリアからはみ出さないようにInsetを調整
        self.backgroundScrollView.contentInset = UIEdgeInsets(
            top: self.cropArea.minY - self.backgroundScrollView.frame.minY,
            left: self.cropArea.minX - self.backgroundScrollView.frame.minX,
            bottom: self.cropArea.maxY - self.cropArea.height - self.backgroundScrollView.frame.minY,
            right: self.cropArea.maxX - self.cropArea.width
        )
    }

    /// 画像を切り抜く
    ///
    /// - Parameter image: 切り抜き元画像
    /// - Returns: 切り抜いた画像
    private func cropImage(_ image: UIImage) -> UIImage? {
        guard let unwrapCropAreaView = self.cropAreaView,
              let unwrapTargetImageView = self.targetImageView else { return nil }

        let cropAreaRect = unwrapCropAreaView.convert(self.cropArea, to: self.backgroundScrollView)

        let imageViewScale = max(
            image.size.width / unwrapTargetImageView.frame.width,
            image.size.height / unwrapTargetImageView.frame.height)

        let imageOriginInImageView = AVMakeRect(aspectRatio: image.size, insideRect: unwrapTargetImageView.frame).origin

        let cropZone = CGRect(
            x: (cropAreaRect.origin.x - imageOriginInImageView.x) * imageViewScale,
            y: (cropAreaRect.origin.y - imageOriginInImageView.y) * imageViewScale,
            width: cropAreaRect.width * imageViewScale,
            height: cropAreaRect.height * imageViewScale)

        return image.cropped(to: cropZone)
    }
}

// MARK: - UIScrollViewDelegate

extension TrimmingViewController: UIScrollViewDelegate {

    /// ズームするViewを指定する
    ///
    /// - Parameter scrollView: UIScrollView
    /// - Returns: ズームするView
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.targetImageView
    }

    /// ScrollViewがズームされた時
    ///
    /// - Parameter scrollView: UIScrollView
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Insetの調整をする
        self.updateScrollInset()
    }

}

// MARK: - TrimmingPresenterOutput

extension TrimmingViewController: TrimmingPresenterOutput {
    func setTargetImage(data: Data) {
        self.targetImageView?.image = UIImage(data: data)
    }

    func dismiss() {
        self.dismiss(animated: true)
    }
}
