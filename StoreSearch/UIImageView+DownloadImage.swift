//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Thanh Pham on 10/6/20.
//  Copyright © 2020 Thanh Pham. All rights reserved.
//

import UIKit
extension UIImageView {
func loadImage(url: URL) -> URLSessionDownloadTask {
let session = URLSession.shared
// 1
let downloadTask = session.downloadTask(with: url,
        completionHandler: { [weak self] url, response, error in
      // 2
      if error == nil, let url = url,
         let data = try? Data(contentsOf: url),
         let image = UIImage(data: data) {
// 4
DispatchQueue.main.async { if let weakSelf = self {
weakSelf.image = image }
} }
})
// 5
downloadTask.resume()
    return downloadTask
  }
}
