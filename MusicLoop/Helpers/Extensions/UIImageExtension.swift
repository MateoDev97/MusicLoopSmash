//
//  UIImageExtension.swift
//  MusicLoop
//
//  Created by Mateo Ortiz on 5/08/22.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
