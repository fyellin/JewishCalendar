// flatten_alpha.swift
// Removes the alpha channel from a PNG by compositing it onto white, in place.
// The App Store requires the iOS 1024px icon to be fully opaque; the Mac icons
// keep their transparent rounded corners.
//
//   Usage:  swift flatten_alpha.swift <file.png>

import AppKit

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: swift flatten_alpha.swift <file.png>\n", stderr)
    exit(1)
}
let url = URL(fileURLWithPath: CommandLine.arguments[1])

guard let image = NSImage(contentsOf: url),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fputs("Could not read \(url.path)\n", stderr)
    exit(1)
}

let context = CGContext(
    data: nil, width: cgImage.width, height: cgImage.height,
    bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
let rect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
context.fill(rect)
context.draw(cgImage, in: rect)

let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
try! bitmap.representation(using: .png, properties: [:])!.write(to: url)
print("Flattened \(url.lastPathComponent) onto white (\(cgImage.width)x\(cgImage.height))")
