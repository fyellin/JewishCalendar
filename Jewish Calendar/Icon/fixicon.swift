// Replaces the year digits in the banner of the Jewish Calendar app icon.
// Usage: swift fixicon.swift <input.png> <output.png> <newText>

import AppKit
import ImageIO
import UniformTypeIdentifiers

let input = CommandLine.arguments[1]
let output = CommandLine.arguments[2]
let newText = CommandLine.arguments[3]

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: input) as CFURL, nil),
      let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    fatalError("Cannot load \(input)")
}
let w = cgImage.width
let h = cgImage.height

// Redraw into a known RGBA8 buffer.
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
guard let context = CGContext(
    data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
    space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
    fatalError("Cannot create context")
}
context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
guard let buffer = context.data else { fatalError("No buffer") }
let pixels = buffer.bindMemory(to: UInt8.self, capacity: w * h * 4)

// Pixel access: buffer row 0 is the topmost scanline, so top-origin y maps to
// the buffer directly.  (Only CG *drawing* coordinates are bottom-origin.)
func offset(_ x: Int, _ yTop: Int) -> Int {
    (yTop * w + x) * 4
}

// 1. Find the bounding box of the white digits in the banner (top ~8%-27%).
var minX = Int.max, maxX = -1, minY = Int.max, maxY = -1
for y in (h * 8 / 100)..<(h * 27 / 100) {
    for x in (w * 12 / 100)..<(w * 88 / 100) {
        let i = offset(x, y)
        if pixels[i] > 217, pixels[i + 1] > 217, pixels[i + 2] > 217 {
            minX = Swift.min(minX, x); maxX = Swift.max(maxX, x)
            minY = Swift.min(minY, y); maxY = Swift.max(maxY, y)
        }
    }
}
guard maxX > 0 else { fatalError("No digits found in \(input)") }
let digitHeight = maxY - minY
print("digit bbox x:\(minX)-\(maxX) y:\(minY)-\(maxY) height:\(digitHeight)")

// 2. Erase the digits: fill each row of the (padded) box with colors
// interpolated between clean banner pixels sampled left and right of the text,
// preserving the banner's gradients.
let pad = max(6, h / 128)
func averageColor(_ y: Int, _ xRange: Range<Int>) -> (Double, Double, Double) {
    var r = 0.0, g = 0.0, b = 0.0
    var n = 0.0
    for x in xRange {
        let i = offset(x, y)
        r += Double(pixels[i]); g += Double(pixels[i + 1]); b += Double(pixels[i + 2])
        n += 1
    }
    return (r / n, g / n, b / n)
}
let fillMinX = minX - pad, fillMaxX = maxX + pad
for y in (minY - pad)...(maxY + pad) {
    let left = averageColor(y, (fillMinX - 40)..<(fillMinX - 20))
    let right = averageColor(y, (fillMaxX + 20)..<(fillMaxX + 40))
    for x in fillMinX...fillMaxX {
        let t = Double(x - fillMinX) / Double(fillMaxX - fillMinX)
        let i = offset(x, y)
        pixels[i] = UInt8(left.0 + (right.0 - left.0) * t)
        pixels[i + 1] = UInt8(left.1 + (right.1 - left.1) * t)
        pixels[i + 2] = UInt8(left.2 + (right.2 - left.2) * t)
        pixels[i + 3] = 255
    }
}

// 3. Draw the new text with the same digit height, centered where the old
// digits were.
let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = nsContext

let baseFont = NSFont(name: "ArialRoundedMTBold", size: 100) ?? NSFont.boldSystemFont(ofSize: 100)
let fontSize = 100 * CGFloat(digitHeight) / baseFont.capHeight
let font = NSFont(name: "ArialRoundedMTBold", size: fontSize) ?? NSFont.boldSystemFont(ofSize: fontSize)

let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
shadow.shadowOffset = NSSize(width: 0, height: -CGFloat(h) / 300)
shadow.shadowBlurRadius = CGFloat(h) / 200

let attributed = NSAttributedString(string: newText, attributes: [
    .font: font,
    .foregroundColor: NSColor.white,
    .shadow: shadow
])
let size = attributed.size()

// Vertical: match the visual center of the old digits (bottom-left origin).
let centerYTopOrigin = CGFloat(minY + maxY) / 2
let centerY = CGFloat(h) - 1 - centerYTopOrigin
let originY = centerY - (-font.descender) - font.capHeight / 2
let originX = CGFloat(w) / 2 - size.width / 2
attributed.draw(at: NSPoint(x: originX, y: originY))

NSGraphicsContext.restoreGraphicsState()

// 4. Save as PNG.
guard let result = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(
          URL(fileURLWithPath: output) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Cannot create destination")
}
CGImageDestinationAddImage(destination, result, nil)
guard CGImageDestinationFinalize(destination) else { fatalError("Cannot write PNG") }
print("Wrote \(output)")
