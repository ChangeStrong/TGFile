//
//  TGGlobal.swift
//  SwiftDevelopFramework
//
//  Created by luo luo on 2020/3/29.
//  Copyright © 2020 GL. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public let GlTestKey: String = "123"
public var TGAppEnviroment:Int = 1;//0-测试环境 1-正式环境
//public let TGFileBasseAdressType = 16;//13-酵母菌海外 16-酵母菌国内

// MARK: 网络连接相关
public func websocketBaseUrlStr() -> String {
    if TGAppEnviroment == 0 {
        //测试环境
        return "ws://127.0.0.1:8888/Comic/websocket/";
    }
    return "wss://goddragon.pub/websocket/";
}

//**颜色相关
public let TGColorTheamMain = UIColor.init(hex: "FF5251")
public let TGColorBGGray = UIColor.init(hex: "F0F0F0") //灰白
public let TGColorBGWhiteGray = UIColor.init(hex: "FBFBFB") //淡白
public let TGColorBGWhiteD = UIColor.init(hex: "FDFDFD") //淡白--很接近白
public let TGColorLine = UIColor.init(hex: "EFEFEF")
//文字主颜色
public let TGColorTextMain = UIColor.black
public let TGColorTextGray6 = UIColor.init(hex: "6F6F6F")
public let TGColorTextGray8 = UIColor.init(hex: "858585")//偏白一点的灰
///系统的textfeild的placehord用的此颜色 c5c5c6
public let TGColorTextGraySystem = UIColor.init(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.3)

//默认网络加载失败占位图
public let TGDefaultImgTwoBigLine = UIImage.init(named: "default_two_big_line")
public let TGDefaultNoNetImg = UIImage.init(named: "default_no_net")
public let TGDefaultHeadImg = UIImage.init(named: "default_head")
public let TDDefaultHeadBgImg = UIImage.init(named: "default_head_bg")
//**end

//*start  frame相关
//以iphoneX模板宽高为标准
public let TGTemplateWidth:CGFloat = 375.0;
public let TGTemplateHeight:CGFloat = 812.0;

public var TGScreenHeight = UIScreen.main.bounds.size.height
public var TGScreenWidth = UIScreen.main.bounds.size.width

//是否刘海屏
public func TGIsFullScreenDevice() -> Bool {
    if #available(iOS 11, *) {
          guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
              return false
          }
          
          if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
              print(unwrapedWindow.safeAreaInsets)
              return true
          }
    }
    return false
}

public func TGNavStatusBarHeight() -> CGFloat {
//    return TGIsFullScreenDevice() ? 88 : 64
    var height: CGFloat = 0
    if #available(iOS 11.0, *) {
        height = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0.0
    }
    if height <= 0{
        height = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
    }
    if height <= 0 {
        height =  TGGlobal.getScenesDelegate()?.window??.safeAreaInsets.top ?? 0.0
    }
    if height <= 0 {
        height = TGGlobal.getScenesDelegate()?.window??.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
    }
    if height <= 0 {
        height = UIApplication.shared.statusBarFrame.size.height
    }
    if height < 20 {
        //好像存在小于20的情况
//        print("TGNavStatusBarHeight:\(NSNumber(value: Float(height)))")
        height = 20
    }
    return height
}


public func TGBottomSafeHeight() -> CGFloat {
//    return TGIsFullScreenDevice() ? 34 : 0
    var height: CGFloat = 0
    if #available(iOS 11.0, *) {
        
        height = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0
    }
    if height == 0 {
        height = TGGlobal.getScenesDelegate()?.window??.safeAreaInsets.bottom ?? 0.0
    }
//    if height < 34 {
//        //好像存在小于20的情况
//        height = 34
//    }
    return height
}

public func TGTabbarHeight() -> CGFloat {
    return TGBottomSafeHeight() + 49;
}

//宽高比例系数
public func TGWIDTHScale() -> CGFloat {
    var scaleWidth:CGFloat = 1.0;
    if TGScreenWidth > TGScreenHeight {
        //横屏状态
        scaleWidth = CGFloat(TGScreenHeight/TGTemplateWidth);
    }else{
        //竖屏状态
        scaleWidth = TGScreenWidth/TGTemplateWidth;
    }
    
    return scaleWidth;
}

public func TGHeightScale() -> CGFloat {
    var scaleWidth:CGFloat = 1.0;
    if TGScreenHeight > TGScreenWidth {
        //竖屏屏状态
        scaleWidth = CGFloat(TGScreenHeight/TGTemplateHeight);
    }else{
        //横屏状态
        scaleWidth = TGScreenWidth/TGTemplateHeight;
    }
    
    return scaleWidth;
}

//获取控件的X、Y 宽、高
public func TGWidth(_ widget:UIView?) -> CGFloat {
    return (widget?.frame.size.width)!
}
public func TGHeight(_ widget:UIView?) -> CGFloat {
    return (widget?.frame.size.height)!
}
public func TGMinX(_ widget:UIView?) -> CGFloat {
    return (widget?.frame.origin.x)!
}
public func TGMinY(_ widget:UIView?) -> CGFloat {
    return (widget?.frame.origin.y)!
}
public func TGMaxX(_ widget:UIView?) -> CGFloat {
    return TGMinX(widget) + TGWidth(widget)
}
public func TGMaxY(_ widget:UIView?) -> CGFloat {
    return TGMinY(widget) + TGHeight(widget)
}

//将某个值按宽度值进行缩放
public func TGX(_ value:CGFloat?) -> CGFloat {
    return value!*TGWIDTHScale()
}
//将某个值按高度进行缩放
public func TGY(_ value:CGFloat?) -> CGFloat {
    return value!*TGHeightScale()
}
//角度转弧度
public func TGDegreesToRadian(_ degrees:CGFloat) -> CGFloat {
    return CGFloat(Double.pi)*degrees/180.0
}
//弧度转角度
public func TGRadianToDegrees(_ radian:CGFloat) -> CGFloat {
    return radian*180/CGFloat(Double.pi)
}

//*end

public func TGFont(_ size:CGFloat) -> UIFont {
    // 20 24
    //UIFont.systemFont(ofSize: size)
    //UIFont.init(name: "Mr Eaves XL Mod OT", size: size)
//    let scale =  CGFloat(20.0/24.0)
    //TGX(size)
    if TGGlobal.isPhone() {
        return UIFont.systemFont(ofSize:TGX(size))
    }
    var scale:CGFloat = TGWIDTHScale();
    if scale > 1.0 {
        //如果是变大 将变大部分缩小到70%
        scale = 1 + (scale - 1.0)*0.7;
    }
    return UIFont.systemFont(ofSize:size*scale)
}

public func TGFontBold(_ size:CGFloat) -> UIFont {
    //25 32-->1.28
    //20 24 -->1.2
//    let scale = CGFloat((25/32.0))
//    if size > 22 {
//        scale = CGFloat((25.0/49.0))
//    }
//    let temp = size * scale
    if TGGlobal.isPhone() {
        return UIFont.boldSystemFont(ofSize:TGX(size))
    }
    var scale:CGFloat = TGWIDTHScale();
    if scale > 1.0 {
        //如果是变大 将变大部分缩小到70%
        scale = 1 + (scale - 1.0)*0.7;
    }
    return UIFont.boldSystemFont(ofSize:size*scale)
}

public func LocalString(_ key:String) -> String {
  return  NSLocalizedString(key, tableName: "Localizable", bundle: Bundle.main, value: "", comment: "")
}

@objcMembers
public class TGGlobal:NSObject{
    
    //通过手机语言判断是否是国外
    public class func isChina() -> Bool{
        let temp = "China".localized
        if temp == "中国" {
            return true;
        }
        return false;
    }
    //设备uuid
    public class func deviceUUID() -> String{
        //不存在则生成一个新的并保存
       
    var uuidStr = TGKeychainManager.getUserPassword(server: Bundle.main.bundleIdentifier!, account: "UUID")
       if uuidStr.isEmpty {
        let uuid_ref = CFUUIDCreate(nil)
        let uuid_string_ref = CFUUIDCreateString(nil , uuid_ref)
        var uuid = uuid_string_ref! as String
        if self.isMac() {
            uuid = "Mac:\(self.modelName()):\(uuid)";
        }else{
            uuid = "iOS:\(self.modelName()):\(uuid)";
        }
       let _ = TGKeychainManager.save(server: Bundle.main.bundleIdentifier!, account: "UUID", password: uuid)
//        SAMKeychain.setPassword(uuid, forService: , account: );
        uuidStr = uuid
    }
       return uuidStr
   }
    
    public class func modelName() -> String {

            var systemInfo = utsname()

            uname(&systemInfo)

            let machineMirror = Mirror(reflecting: systemInfo.machine)

            let identifier = machineMirror.children.reduce("") { identifier, element in

                guard let value = element.value as? Int8, value != 0 else { return identifier }

                return identifier + String(UnicodeScalar(UInt8(value)))

            }
        return identifier;
    }
    
    public class func getScenesDelegate() -> UIWindowSceneDelegate?{
        let arry = UIApplication.shared.connectedScenes;
        for item in arry {
            if item.activationState == .foregroundActive {
                let windowScene = item;
                return windowScene.delegate as? UIWindowSceneDelegate;
            }
        }

      let scene =   Array(UIApplication.shared.openSessions).last?.scene
        return scene?.delegate as? UIWindowSceneDelegate;
        
    }
    
    public  class func getAppVersion() -> String{
     let appVersion =   String(describing: Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString"));
        return appVersion
    }
    
    /// 比较版本大小，返回是否需要更新
    ///
    /// - Parameters:
    ///   - v1: 版本1- 新版本
    ///   - v2: 版本2- 当前版本
    /// - Returns: true：v1>v2    false:v1<=v2
    public class func compareVersions(v1:String,v2:String) -> Bool {
        if v1.isEmpty && v2.isEmpty || v1.isEmpty{
            return false
        }
        
        if v2.isEmpty {
            return true
        }
        
        let arry1 = v1.components(separatedBy: ".")
        let arry2 = v2.components(separatedBy: ".")
        //取count少的
        let minCount = arry1.count > arry2.count ? arry2.count : arry1.count
        
        var value1:Int = 0
        var value2:Int = 0
        
        for i in 0..<minCount {
            if !isPurnInt(string: arry1[i]) || !isPurnInt(string: arry2[i]){
                return false
            }
           
            value1 = Int(arry1[i])!
            value2 = Int(arry2[i])!
          
            // v1版本字段大于v2版本字段
            if value1 > value2 {
               // v1版本字段大于v2版本字段
               return true
            }else if value1 < value2{
               // v1版本字段小于v2版本字段
               return false
            }
            // v1版本=v2版本字段  继续循环
            
        }
        
        //字段多的版本高于字段少的版本
        if arry1.count > arry2.count {
            return true
        }else if arry1.count <= arry2.count {
            return false
        }
        
        return false
    }

    /// 判断是否是数字
    ///
    /// - Parameter string:
    /// - Returns:
    public class func isPurnInt(string: String) -> Bool {
        let scan: Scanner = Scanner(string: string)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    //是手机
    
    public class func isPhone() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        }
        return false
    }
    
    public class func isIpad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
    
    public class func isMac() -> Bool {
        if #available(iOS 14.0, *) {
            if UIDevice.current.userInterfaceIdiom == .mac {
                return true
            }
        } else {
            // Fallback on earlier versions
        }
        return false
    }
    
    public class func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    public class func deviceType() -> String{
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iOS_phone";
        case .pad:
            return "iOS_pad";
        case .mac:
            return "iOS_mac";
        default:
          return  "ios"
        }
    }
    
    //转16进制字符显示
    public class func coventToHex<T:CVarArg> (_ data:[T]) -> String {
        var string = ""
        for item in data {
            string.append(" ")
            string.append(String(format: "%02x", item).uppercased())
        }
        return string
    }
    //根据秒数 转为时分秒
    public class func getTimeBy(timeStamp:Int) -> (s:Int,m:Int,h:Int) {
        //秒
        let s = timeStamp % 60
        //分
        let m = (timeStamp - s) / 60 % 60
        //时
        let h = ((timeStamp - s) / 60 - m) / 60 % 24;
        return (s,m,h)
    }
    
    //json字符串转字典
    public class func getDictionaryFromJSONString(jsonString:String) ->Dictionary<String, Any>?{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict == nil {
            LLog(TAG: TAG(self), "get dict failture.!");
        }
        return dict as? Dictionary<String, Any>
    }
    //json转数组
    public  class func getArrayFromJSONString(jsonString:String) ->[Any]?{
        //此方法json字符串包含很多转义\也可以解出来
//       let  tempJsonStr = jsonString.replacingOccurrences(of: "\\", with: "")
            let jsonData:Data = jsonString.data(using: .utf8)!
        //.allowFragments .mutableContainers
            let array = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            if array != nil {
                return array as? [Any]
            }
        return array as? [Any]
        }
    //字典转json
    public class func getJSONStringFrom(obj:Any) -> String {
            if (!JSONSerialization.isValidJSONObject(obj)) {
                LLog(TAG: TAG(self), "can't get JSONString!");
                return ""
            }
       let data : NSData! = try? JSONSerialization.data(withJSONObject: obj, options: []) as NSData?
            let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
            return JSONString! as String
     
        }
    
    //
    public class func removeEmptyValue(_ dict:[String:Any],_ nonKeys:[String]) -> Dictionary<String, Any> {
        var dict2 = dict;
        //移除不需要的key
            for key in nonKeys {
                dict2.removeValue(forKey: key)
            }
        
        
        
        return dict2
    }
    
    
    //获取视频的尺寸
    public  class func getVideoSize(by url: URL?) -> CGSize {
        var asset: AVAsset? = nil
        if let url = url {
            asset = AVAsset(url: url)
        }
        let tracks = asset?.tracks(withMediaType: .video)
        if tracks == nil {
            return CGSize.zero
        }
        if tracks?.count == 0 {
            return CGSize.zero
        }
        let videoTrack = tracks?[0]
        var videoSize: CGSize? = nil
        if let preferredTransform = videoTrack?.preferredTransform {
            videoSize = videoTrack?.naturalSize.applying(preferredTransform)
        }
        videoSize = CGSize(width: CGFloat(abs(Float(videoSize?.width ?? 0.0))), height: CGFloat(abs(Float(videoSize?.height ?? 0.0))))
        return videoSize ?? CGSize.zero
    }
    
    // 获取视频第一帧
public class func getVideoFirstViewImage(_ path: URL?) -> UIImage? {
    
        var asset: AVURLAsset? = nil
        if let path = path {
            asset = AVURLAsset(url: path, options: nil)
        }
        var assetGen: AVAssetImageGenerator? = nil
        if let asset = asset {
            assetGen = AVAssetImageGenerator(asset: asset)
        }
    
        let durationTime:CMTime = asset!.duration
        let duration:CGFloat = CGFloat(durationTime.value) / CGFloat(durationTime.timescale)
        let mediasArray = asset?.tracks(withMediaType: .video)
        var fps: Float = 60
        if mediasArray != nil && (mediasArray?.count ?? 0) > 0 {
            fps = mediasArray?[0].nominalFrameRate ?? 0.0
        }
        var tempTime = duration * 0.016 //取时长的1.6%  60秒时长的视频约第一秒的画面 0.723
        if tempTime < 1 {
            tempTime = 1;//保证至少取第一帧的位置
        }
        assetGen?.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(tempTime), preferredTimescale: Int32(fps)) //0 600
//        LLog(TAG: TAG(self), "time=\(time) seconds=\(tempTime) timescale=\(fps)");
//        var error: Error? = nil
        var actualTime: CMTime = CMTimeMake(value: 0, timescale: 0)
        var image: CGImage? = nil
        do {
            image = try assetGen?.copyCGImage(at: time, actualTime: &actualTime)
        } catch {
        }
        var videoImage: UIImage? = nil
        if let image = image {
            videoImage = UIImage(cgImage: image)
        }
        if videoImage == nil {
            LLog(TAG: TAG(self), "未抽取到封面!!");
        }
//        CGImageRelease(image!)
        return videoImage
    
    }
    
    
}

public class TGGloabalUI{
    public  enum TGButtonImageDirection {
        case Left
        case Top
        case Right
        case Bottom
    }
    /*
     contentInset 内容和大背景间的padding
     interval 图片和标题间的间隙
     */
    public static func addContentForButton(button:UIButton,fatherView:UIView,bgImageStr:String?,imageStr:String,title:String,imgDirection:TGButtonImageDirection,imageSize:CGSize,interval:CGFloat,contentInset:UIEdgeInsets) -> (bgView:UIImageView, titleLabel:UILabel,imageView:UIImageView){
        //背景阴影为0
        return addContentForButton(button: button, fatherView: fatherView, bgImageStr: bgImageStr, imageStr: imageStr, title: title, imgDirection: imgDirection, imageSize: imageSize, interval: interval, contentInset: contentInset, bgShadowExdInset: UIEdgeInsets.zero)
    }
    
    public static func addContentForButton(button:UIButton,fatherView:UIView,bgImageStr:String?,imageStr:String,title:String,imgDirection:TGButtonImageDirection,imageSize:CGSize,interval:CGFloat,contentInset:UIEdgeInsets,bgShadowExdInset:UIEdgeInsets) -> (bgView:UIImageView, titleLabel:UILabel,imageView:UIImageView) {
        //添加背景
        let bgImageView = self.addBgImageViewFor(view: button, fatherView: fatherView, imageStr: bgImageStr,edgInset: bgShadowExdInset)
        
        //内容
        let contentView = UIView()
        fatherView.addSubview(contentView)
        
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: imageStr)
        imageView.backgroundColor = UIColor.clear
        contentView.addSubview(imageView)
        
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.init(hex: "474747")
        label.font = TGFontBold(14)
        label.textAlignment = .left
        contentView.addSubview(label)
        
        switch imgDirection {
        case .Left:
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo(contentView).offset(contentInset.top)
                make.left.equalTo(contentView).offset(contentInset.left)
                make.size.equalTo(CGSize.init(width: imageSize.width, height: imageSize.height))
            }
            
            label.snp.makeConstraints { (make) in
                make.centerY.equalTo(imageView)
                make.left.equalTo(imageView.snp.right).offset(interval)
            }
            contentView.snp.makeConstraints { (make) in
                make.centerY.equalTo(button)
                make.centerX.equalTo(button)
                make.left.equalTo(imageView)
                make.right.equalTo(label)
                make.height.equalTo(imageView).offset(4)
            }
        case .Top:
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo(contentView).offset(contentInset.top)
                make.centerX.equalTo(contentView)
                make.size.equalTo(CGSize.init(width: imageSize.width, height: imageSize.height))
            }
            label.snp.makeConstraints { (make) in
                make.centerX.equalTo(imageView)
                make.top.equalTo(imageView.snp.bottom).offset(interval)
            }
            contentView.snp.makeConstraints { (make) in
                make.centerY.equalTo(button)
                make.centerX.equalTo(button)
                //                make.top.equalTo(imageView)
                make.bottom.equalTo(label)
                //保证宽度取到最大值
                make.left.equalTo(label).priority(.low)
                make.right.equalTo(label).priority(.low)
                make.width.greaterThanOrEqualTo(imageView)
            }
        default:
            break
        }
        fatherView.bringSubviewToFront(button)
        return (bgImageView,label,imageView)
    }
    
    public  static func addBgImageViewFor(view:UIView,fatherView:UIView,imageStr:String?,edgInset:UIEdgeInsets) -> UIImageView {
        let bgView = UIImageView()
        bgView.isUserInteractionEnabled = true
        if imageStr != nil {
            bgView.image = UIImage.init(named: imageStr!)
        }
        bgView.backgroundColor = UIColor.clear
        fatherView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(-edgInset.top)
            make.left.equalTo(view).offset(-edgInset.left)
            make.right.equalTo(view).offset(edgInset.right)
            make.bottom.equalTo(view).offset(edgInset.bottom)
        }
        //背景放下面
        fatherView.insertSubview(bgView, belowSubview: view)
        return bgView
    }
    
    //获取当前屏幕显示的viewcontroller
public class func getCurrentVC() -> UIViewController? {
        var result: UIViewController? = nil
        // 获取默认的window
    
        var window = TGGlobal.getScenesDelegate()?.window//UIApplication.shared.keyWindow
       if window??.windowLevel != .normal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == .normal {
                    window = tmpWin
                    break
                }
            }
        }
        // 获取window的rootViewController
       result = window??.rootViewController
        while ((result?.presentedViewController) != nil) {
            result = result?.presentedViewController
        }
        if result is UITabBarController {
            result = (result as? UITabBarController)?.selectedViewController
        }
        if result is UINavigationController {
            result = (result as? UINavigationController)?.visibleViewController
        }
        return result
    }
}



