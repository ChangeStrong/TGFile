//
//  UIImageExtension.swift
//  SwiftFrameworkDemo
//
//  Created by luo luo on 2022/5/22.
//  Copyright © 2022 GL. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage{
    ///获取图片主题
    func subjectColor(_ completion: @escaping (_ topColor: UIColor?,_ midColor: UIColor?,_ bottomColor: UIColor?) -> Void){
        if self.size.width < 60 || self.size.height < 60 {
            LLog(TAG: TAG(self), "image size is less than 60.");
            return completion(nil,nil,nil)
        }
        
      DispatchQueue.global().async {
        if self.cgImage == nil {
            DispatchQueue.main.async {
                return completion(nil,nil,nil)
            }
        }
        let bitmapInfo = CGBitmapInfo(rawValue: 0).rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
          
        // 第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
          let width:CGFloat =   60 //40
          let height:CGFloat = (self.size.height/self.size.width)*width //40
        let thumbSize = CGSize(width: width , height: height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil,
                                      width: Int(thumbSize.width),
                                      height: Int(thumbSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: Int(thumbSize.width) * 4 ,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else { return completion(nil,nil,nil) }
          
        let drawRect = CGRect(x: 0, y: 0, width: thumbSize.width, height: thumbSize.height)
        context.draw(self.cgImage! , in: drawRect)
          
        // 第二步 取每个点的像素值
        if context.data == nil{ return completion(nil,nil,nil)}
//        let countedSet = NSCountedSet(capacity: Int(thumbSize.width * thumbSize.height))
//        for x in 0 ..< Int(thumbSize.width) {
//            for y in 0 ..< Int(thumbSize.height){
//                let offset = 4 * x * y
//                let red = context.data!.load(fromByteOffset: offset, as: UInt8.self)
//                let green = context.data!.load(fromByteOffset: offset + 1, as: UInt8.self)
//                let blue = context.data!.load(fromByteOffset: offset + 2, as: UInt8.self)
//                let alpha = context.data!.load(fromByteOffset: offset + 3, as: UInt8.self)
//                // 过滤透明的、基本白色、基本黑色
//                if alpha > 0 && (red < 250 && green < 250 && blue < 250) && (red > 5 && green > 5 && blue > 5) {
//                    let array = [red,green,blue,alpha]
//                    countedSet.add(array)
//                }
//            }
//        }

          //上半部分
          let topCountedSet = NSCountedSet(capacity: Int(thumbSize.width * thumbSize.height)/6)
          //中间部分占2/4
          let midCountedSet = NSCountedSet(capacity: Int(thumbSize.width * thumbSize.height)*4/6)
          //下半部分
          let bottomCountedSet = NSCountedSet(capacity: Int(thumbSize.width * thumbSize.height)/6)
          let count = Int(thumbSize.width * thumbSize.height)
          let oneOfFour:Int = Int(Float(count)/6.0)
          let threeOfFour:Int = Int(Float(count)*5/6.0)
          LLog(TAG: TAG(self), "count=\(count) onfeOfFour=\(oneOfFour) threeOfFour=\(threeOfFour)");
          for x in 0..<count {
              
              let offset = 4 * x
              let red = context.data!.load(fromByteOffset: offset, as: UInt8.self)
              let green = context.data!.load(fromByteOffset: offset + 1, as: UInt8.self)
              let blue = context.data!.load(fromByteOffset: offset + 2, as: UInt8.self)
              let alpha = context.data!.load(fromByteOffset: offset + 3, as: UInt8.self)
              
              // 过滤透明的、基本白色、基本黑色
              if alpha > 0 && (red < 250 && green < 250 && blue < 250) && (red > 5 && green > 5 && blue > 5) {
                  let array = [red,green,blue,alpha]
                  
                  if x < oneOfFour {
                    //上半部分
                      topCountedSet.add(array)
                  }else if x >= oneOfFour && x < threeOfFour {
                      //中间部分
                      midCountedSet.add(array)
                  }else{
                      //下半部分
                      bottomCountedSet.add(array)
                  }
                  
              }
          }
          
          LLog(TAG: TAG(self), "bottomCountedSet=\(bottomCountedSet.count)");
          
        //第三步 找到出现次数最多的那个颜色
          var topColor:UIColor?
          var midColor:UIColor?
          var bottomColor:UIColor?
          
          //上部分
          let topEnumerator = topCountedSet.objectEnumerator()
          var topMaxColor: [Int] = []
          var topMaxCount = 0
          while let curColor = topEnumerator.nextObject() as? [Int] , !curColor.isEmpty {
              let tmpCount = topCountedSet.count(for: curColor)
              if tmpCount < topMaxCount { continue }
              topMaxCount = tmpCount
              topMaxColor = curColor
          }
          
          if topMaxColor.count > 0 {
              LLog(TAG: TAG(self), "top: red:\(CGFloat(topMaxColor[0])) green:\(CGFloat(topMaxColor[1]))  blue:\(CGFloat(topMaxColor[2])) alpha:\(CGFloat(topMaxColor[3]))");
               topColor = UIColor(red: CGFloat(topMaxColor[0]) / 255.0, green: CGFloat(topMaxColor[1]) / 255.0, blue: CGFloat(topMaxColor[2]) / 255.0, alpha: CGFloat(topMaxColor[3]) / 255.0)
          }
          
          //中间部分
                  let midEnumerator = midCountedSet.objectEnumerator()
                  var midMaxColor: [Int] = []
                  var midMaxCount = 0
                  while let curColor = midEnumerator.nextObject() as? [Int] , !curColor.isEmpty {
                      let tmpCount = midCountedSet.count(for: curColor)
                      if tmpCount < midMaxCount { continue }
                      midMaxCount = tmpCount
                      midMaxColor = curColor
                  }
          
          if midMaxColor.count > 0 {
              LLog(TAG: TAG(self), "mid: red:\(CGFloat(midMaxColor[0])) green:\(CGFloat(midMaxColor[1]))  blue:\(CGFloat(midMaxColor[2])) alpha:\(CGFloat(midMaxColor[3]))");
              midColor = UIColor(red: CGFloat(midMaxColor[0]) / 255.0, green: CGFloat(midMaxColor[1]) / 255.0, blue: CGFloat(midMaxColor[2]) / 255.0, alpha: CGFloat(midMaxColor[3]) / 255.0)
          }
          
          
          //底部部分
          let bottomEnumerator = bottomCountedSet.objectEnumerator()
          var bottomMaxColor: [Int] = []
          var bottomMaxCount = 0
          while let curColor = bottomEnumerator.nextObject() as? [Int] , !curColor.isEmpty {
              let tmpCount = bottomCountedSet.count(for: curColor)
              if tmpCount < bottomMaxCount { continue }
              bottomMaxCount = tmpCount
              bottomMaxColor = curColor
          }
          
          if bottomMaxColor.count > 0 {
              LLog(TAG: TAG(self), "bottom: red:\(CGFloat(bottomMaxColor[0])) green:\(CGFloat(bottomMaxColor[1]))  blue:\(CGFloat(bottomMaxColor[2])) alpha:\(CGFloat(bottomMaxColor[3]))");
               bottomColor = UIColor(red: CGFloat(bottomMaxColor[0]) / 255.0, green: CGFloat(bottomMaxColor[1]) / 255.0, blue: CGFloat(bottomMaxColor[2]) / 255.0, alpha: CGFloat(bottomMaxColor[3]) / 255.0)
          }
          
          DispatchQueue.main.async {
              return completion(topColor,midColor,bottomColor)
              
          }
          
//        let enumerator = countedSet.objectEnumerator()
//        var maxColor: [Int] = []
//        var maxCount = 0
//        while let curColor = enumerator.nextObject() as? [Int] , !curColor.isEmpty {
//            let tmpCount = countedSet.count(for: curColor)
//            if tmpCount < maxCount { continue }
//            maxCount = tmpCount
//            maxColor = curColor
//        }
//        let color = UIColor(red: CGFloat(maxColor[0]) / 255.0, green: CGFloat(maxColor[1]) / 255.0, blue: CGFloat(maxColor[2]) / 255.0, alpha: CGFloat(maxColor[3]) / 255.0)
//        DispatchQueue.main.async { return completion(color) }
          
          
      }
   }
    
    //裁剪某个部位
    enum CropDirection {
    case top
    case bottom
    }
    
    class func cropByPadding(image:UIImage,padding:CGFloat) -> UIImage {
        var tempImage:UIImage = image;
        let width:CGFloat = CGFloat(tempImage.cgImage!.width)
        let height:CGFloat = CGFloat(tempImage.cgImage!.height);
        if padding > width {
            LLog(TAG: TAG(self), "padding is over width.!");
            return tempImage;
        }
        if padding > height {
            LLog(TAG: TAG(self), "padding is over height.!");
            return tempImage;
        }
        let newRect = CGRect.init(x: padding, y: padding, width: width-padding*2, height: height-padding*2)
        
        let cgImag =  tempImage.cgImage?.cropping(to: newRect)
        if cgImag != nil {
            tempImage = UIImage(cgImage: cgImag!)
        }else{
            LLog(TAG: TAG(self), "crop is failture.!!");
        }
        return tempImage;
        
    }
    ///裁剪总方法
    class func cropAndBurImage(image:UIImage,dirction:CropDirection,scale:Float,blurRadius:CGFloat,padding:CGFloat,oritation:UIImage.Orientation) -> UIImage{
        var tempImage:UIImage = image;
        if scale > 1 {
            LLog(TAG: TAG(self), " scale is more than 1 !!");
            return tempImage
        }
        if scale <= 0 {
            LLog(TAG: TAG(self), "scale is less than 0 !!");
            return tempImage;
        }
        if tempImage.cgImage == nil {
            LLog(TAG: TAG(self), "cgimage is nil !!");
            return tempImage;
        }
        var width:CGFloat = CGFloat(tempImage.cgImage!.width)
        var height:CGFloat = CGFloat(tempImage.cgImage!.height);
        let tempHeight:CGFloat = height*CGFloat(scale);
        var newRect = CGRect.init(x: 0, y: 0, width: width, height: height)
        if dirction == .top {
            newRect = CGRect.init(x: 0, y: 0, width: width, height: tempHeight)
        }else  if(dirction == .bottom){
            newRect = CGRect.init(x: 0, y: height - tempHeight, width: width, height: tempHeight)
        }
        
        guard let cgImag =  tempImage.cgImage?.cropping(to: newRect) else{
            LLog(TAG: TAG(self), "crop failture.!");
            return image
        }
        //模糊
        let context = CIContext(options: nil)
        var inputImage: CIImage? = nil
        inputImage = CIImage(cgImage: cgImag)
        
        //设置filter CIGaussianBlur CIDiscBlur
    let filter = CIFilter(name: "CIDiscBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: Float(blurRadius)), forKey: "inputRadius")
        //模糊图片
        let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage
        var outImage: CGImage? = nil
        if let result = result {
            outImage = context.createCGImage(result, from: result.extent)
        }
        if outImage == nil {
            LLog(TAG: TAG(self), "filter image failture.!!");
            return image;
        }
        //去除阴影
        width = CGFloat(outImage!.width)
        height = CGFloat(outImage!.height);
        if padding > width {
            LLog(TAG: TAG(self), "padding is over width.!");
            return tempImage;
        }
        if padding > height {
            LLog(TAG: TAG(self), "padding is over height.!");
            return tempImage;
        }
        let newRect2 = CGRect.init(x: padding, y: padding, width: width-padding*2, height: height-padding*2)
        
        guard let cgImag2 =  tempImage.cgImage?.cropping(to: newRect2) else{
            LLog(TAG: TAG(self), "shadwon failture.!");
            return image;
        }
        
        //旋转方向
//        let scal = cgImag2.width/cgImag2.height;
        let temp =  UIImage(cgImage:cgImag2,
                            scale:1.0, orientation: oritation)
        return temp;
    }
    
    class func cropSubPart(image:UIImage,dirction:CropDirection,scale:Float) ->UIImage{
        var tempImage:UIImage = image;
        if scale > 1 {
            LLog(TAG: TAG(self), " scale is more than 1 !!");
            return tempImage
        }
        if scale <= 0 {
            LLog(TAG: TAG(self), "scale is less than 0 !!");
            return tempImage;
        }
        if tempImage.cgImage == nil {
            LLog(TAG: TAG(self), "cgimage is nil !!");
            return tempImage;
        }
        let width:CGFloat = CGFloat(tempImage.cgImage!.width)
        let height:CGFloat = CGFloat(tempImage.cgImage!.height);
        let tempHeight:CGFloat = height*CGFloat(scale);
        var newRect = CGRect.init(x: 0, y: 0, width: width, height: height)
        if dirction == .top {
            newRect = CGRect.init(x: 0, y: 0, width: width, height: tempHeight)
        }else  if(dirction == .bottom){
            newRect = CGRect.init(x: 0, y: height - tempHeight, width: width, height: tempHeight)
        }
        
        let cgImag =  tempImage.cgImage?.cropping(to: newRect)
        if cgImag != nil {
            tempImage = UIImage(cgImage: cgImag!)
        }else{
            LLog(TAG: TAG(self), "crop is failture.!!");
        }
        
        return tempImage;
    }
    
   class func blurImage(_ image: UIImage, withBlurNumber blur: CGFloat) -> UIImage {
        
            let context = CIContext(options: nil)
            var inputImage: CIImage? = nil
            if let CGImage = image.cgImage {
                inputImage = CIImage(cgImage: CGImage)
            }
            //设置filter CIGaussianBlur CIDiscBlur
        let filter = CIFilter(name: "CIDiscBlur")
            filter?.setValue(inputImage, forKey: kCIInputImageKey)
            filter?.setValue(NSNumber(value: Float(blur)), forKey: "inputRadius")
            //模糊图片
            let result = filter?.value(forKey: kCIOutputImageKey) as? CIImage
            var outImage: CGImage? = nil
            if let result = result {
                outImage = context.createCGImage(result, from: result.extent)
            }
            var blurImage: UIImage? = nil
            if let outImage = outImage {
                blurImage = UIImage(cgImage: outImage)
//                CGImageRelease(outImage)
            }
            
            return blurImage ?? image
        
        }
    
    //旋转图片
    class func rotationImg( image:UIImage,oritation:UIImage.Orientation) -> UIImage {
        if image.cgImage == nil {
            LLog(TAG: TAG(self), "Not find cgImage.!!");
            return image;
        }
        let temp =  UIImage(cgImage:image.cgImage!,
                       scale:image.scale, orientation: oritation)
        return temp;
    }
    
    /**
         *  重设图片分辨率
         */
        func reSizeImage(_ reSize:CGSize)->UIImage {
            //UIGraphicsBeginImageContext(reSize);
            UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
            self.draw(in: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height))
            let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            return reSizeImage;
        }
         
        /**
         *  等比率缩放
         */
        func scaleImage(scaleSize:CGFloat)->UIImage {
            let reSize = CGSize.init(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
            return reSizeImage(reSize)
        }
    
    // MARK: 图片生成文字
    class func createimageBy(_ text:String,size:(CGFloat,CGFloat),backColor:UIColor=UIColor.clear,textColor:UIColor=UIColor.white,isCircle:Bool=true) -> UIImage?{
            // 过滤空""
            if text.isEmpty { return nil }
            // 取第一个字符(测试了,太长了的话,效果并不好)
            let letter = (text as NSString).substring(to: 1)
            let sise = CGSize(width: size.0, height: size.1)
            let rect = CGRect(origin: CGPoint.zero, size: sise)
            // 开启上下文
            UIGraphicsBeginImageContext(sise)
            // 拿到上下文
            guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
            // 取较小的边
            let minSide = min(size.0, size.1)
            // 是否圆角裁剪
            if isCircle {
                UIBezierPath(roundedRect: rect, cornerRadius: minSide*0.5).addClip()
            }
            // 设置填充颜色
            ctx.setFillColor(backColor.cgColor)
            // 填充绘制
            ctx.fill(rect)
        let attr = [ NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.font : UIFont.systemFont(ofSize: minSide*0.5)]
            // 写入文字
            (letter as NSString).draw(at: CGPoint(x: minSide*0.25, y: minSide*0.25), withAttributes: attr)
            // 得到图片
            let image = UIGraphicsGetImageFromCurrentImageContext()
            // 关闭上下文
            UIGraphicsEndImageContext()
            return image
        }
     
}
