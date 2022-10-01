//
//  AlamofireHC.swift
//  StreamNow
//
//  Created by Ramesh P on 24/10/17.
//  Copyright © 2017 Ramesh P. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

//static let alamofireService = AlamofireHC()

class AlamofireHC: NSObject {

    // MARK: - GET METHOD
   class func requestGET(_ strMethod: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
    
    let URL = BASEURL + strMethod
    print("Success with JSON: \(URL)")

        Alamofire.request(URL).responseJSON { (responseObject) -> Void in
            
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
   
    // MARK: - POST METHOD
    class func requestPOST(_ strMethod : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
      
        let URL = BASEURL + strMethod
        print("Success with JSON: \(URL)")
        
        print("Parameter : \(params)")
        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (responseObject) -> Void in
            
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    class func requestPOSTMethod(_ strMethod : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (Data) -> Void, failure:@escaping (Error) -> Void){
        
      
        let URL = BASEURL + strMethod
        print("Success with JSON: \(URL)")

        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (responseObject) -> Void in
            
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = responseObject.data!
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    // MARK: - POST WITH IMAGE METHOD
    class func requestPOSTwithImage(_ strMethod : String,image : UIImage, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        let URL = BASEURL + strMethod
        
            
        Alamofire.upload(multipartFormData:{ multipartFormData in
            if let imageData = UIImageJPEGRepresentation(image, 1) {
                multipartFormData.append(imageData, withName: "picture", fileName: "image.jpg", mimeType: "image/jpg")
            }
             for (key, value) in params! {
                multipartFormData.append((value as AnyObject).data(using:String.Encoding.utf8.rawValue)!, withName: key)
            }},
                         usingThreshold:UInt64.init(),
                         to:URL,
                         method:.post,
                         headers:headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                             case .success(let upload, _, _):
                                upload.responseJSON { response in

                                  let json =  JSON(response.result.value!)
                                    success(json)
                                    
                                }
                            case .failure(let encodingError):
                               failure(encodingError)
                            }
        })
    
    }
    class func newRequestPOST(_ strMethod : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
      
        let URL =   strMethod
        print("Success with JSON: \(URL)")

        Alamofire.request(URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            (responseObject) -> Void in
            
            print(responseObject)
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
}
