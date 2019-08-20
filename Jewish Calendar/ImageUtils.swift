//
//  ImageUtils.swift
//  Jewish Calendar
//
//  Created by Frank Yellin on 8/20/19.
//  Copyright © 2019 Frank Yellin. All rights reserved.
//

import Cocoa

extension NSImage {
    func flipped(flipHorizontally: Bool = false, flipVertically: Bool = false) -> NSImage {
        let flippedImage = NSImage(size: size)
        
        flippedImage.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        
        let transform = NSAffineTransform()
        transform.translateX(by: flipHorizontally ? size.width : 0, yBy: flipVertically ? size.height : 0)
        transform.scaleX(by: flipHorizontally ? -1 : 1, yBy: flipVertically ? -1 : 1)
        transform.concat()
        
        draw(at: .zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1)
        
        flippedImage.unlockFocus()
        
        return flippedImage
    }
}