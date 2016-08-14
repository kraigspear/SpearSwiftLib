
import UIKit
import ImageIO

public final class GifExtractor {
	private let imageData: NSData
	
	private let imageSource: CGImageSource
	
	public init(imageData: NSData) {
		self.imageData = imageData
		let options: CFDictionary = [String(kCGImageSourceShouldCache) : kCFBooleanFalse]
		self.imageSource = CGImageSourceCreateWithData(imageData, options)!
	}
	
	public func extracted() -> [UIImage] {
		let numberOfFrames = Int(CGImageSourceGetCount(imageSource))
		
		var images: [UIImage] = []
		
		for i in 0..<numberOfFrames {
			if let image = loadFrame(atIndex: i) {
				images.append(image)
			}
		}
		
		return images
	}
	
	private func loadFrame(atIndex: Int) -> UIImage? {
		 guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, atIndex, nil) else { return nil }
 		 return UIImage(cgImage: imageRef)
	}
}

