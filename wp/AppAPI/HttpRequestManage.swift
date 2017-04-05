//
//  HttpRequestManage.swift
//  wp
//
//  Created by J-bb on 17/4/5.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import RealmSwift
import Realm.RLMSchema

private let urlString = AppConst.Network.TttpHostUrl

typealias reseponseBlock = (_ reseponseObject:AnyObject)->Void



class HttpRequestManage: NSObject {

private static var instance = HttpRequestManage()
   
    static func shared()-> HttpRequestManage {
        return instance
    }
    private override init() {}
    
    
    func toList(listData:AnyObject?,responseClass:AnyClass,listName:String) -> [AnyObject] {
        var list = [Object]()
        let cls = responseClass as! Object.Type
        if let jsonArray = listData as? Array<Dictionary<String,AnyObject>>{
            for dict in jsonArray {
                let obj = cls.init(value: dict, schema: RLMSchema.partialShared())
                list.append(obj)
            }
        }
        
        return []
    }
    func toModel(jsonData:AnyObject,responseClass:AnyClass) -> AnyObject? {
        let cls = responseClass as! Object.Type
        if let jsonDict = jsonData as? Dictionary<String,AnyObject>{
            let obj = cls.init(value: jsonDict, schema: RLMSchema.partialShared())
            return obj
        }
        return nil
    }
    
    
    
    func postRequestModels(requestModel:HttpRequestModel,responseClass:AnyClass, listName:String = "data", reseponse:@escaping reseponseBlock) {
        postRequestJson(requestModel.requestPath, parameters: requestModel.toDictionary() as! Dictionary<String, Any>) { (responseData) in
            reseponse(self.toList(listData: responseData, responseClass: responseClass, listName: listName) as AnyObject)
        }
    }
    func postRequestModel(requestModel:HttpRequestModel,responseClass:AnyClass,reseponse:@escaping reseponseBlock) {
        postRequestJson(requestModel.requestPath, parameters: requestModel.toDictionary() as! Dictionary<String, Any>) { (responseData) in
            reseponse(self.toModel(jsonData: responseData, responseClass: responseClass)!)
        }
    }
    func postRequestModelWithJson(requestModel:HttpRequestModel,reseponse:@escaping reseponseBlock) {
        postRequestJson(requestModel.requestPath, parameters: requestModel.toDictionary() as! Dictionary<String, Any>) { (responseData) in
            reseponse(responseData as! AnyClass)
        }
    }

    
    
    func getRequestModels(path:String,responseClass:AnyClass, reseponse:@escaping reseponseBlock) {
        getRequestJson(path) { (responseData) in
            reseponse(self.toModel(jsonData: responseData, responseClass: responseClass)!)
        }
    }
    
    
    func getRequestModel(path:String,responseClass:AnyClass, listName:String = "data",reseponse:@escaping reseponseBlock) {
        getRequestJson(path) { (responseData) in
            reseponse(self.toList(listData: responseData, responseClass: responseClass, listName: listName) as AnyObject)
        }
    }
    
    
    
     func postRequestJson(_ path:String, parameters:Dictionary<String, Any>,reseponse:@escaping reseponseBlock){
        let urlPath = urlString + path
        debugPrint("startPostRequest:path\(path)")
        Alamofire.request(urlPath, method: .post, parameters: parameters).responseJSON { (responseData) in
            debugPrint("receivedPostRequest:path\(path)")
            if responseData.result.error == nil {
                let jsonDict = responseData.result.value as? Dictionary<String,AnyObject>
                if let resData = jsonDict?["data"]  {
                    reseponse(resData as AnyObject)
                } else {
                    SVProgressHUD.showErrorMessage(ErrorMessage: jsonDict?["msg"] as! String, ForDuration: 1.5, completion: nil)
                }
            } else {
                SVProgressHUD.showErrorMessage(ErrorMessage: "errorCode：\(responseData.result.error!._code)", ForDuration: 1.5, completion: nil)
            }
        }
        
    }
    
     func getRequestJson(_ path:String, reseponse:@escaping reseponseBlock){
        var urlPath = urlString + path
        urlPath = urlPath + "?sign=\(urlPath.getSignString())"
        debugPrint("startGetRequest:path\(path)")
        Alamofire.request(urlPath).responseJSON { (responseData) in
            
            debugPrint("receivedGetResponse:path\(path)")

            if responseData.result.error == nil {
                let jsonDict = responseData.result.value as? Dictionary<String,AnyObject>
                if let resData = jsonDict?["data"]  {
                    reseponse(resData as AnyObject)
                } else {
                    SVProgressHUD.showErrorMessage(ErrorMessage: jsonDict?["msg"] as! String, ForDuration: 1.5, completion: nil)
                }
            } else {
                SVProgressHUD.showErrorMessage(ErrorMessage: "errorCode：\(responseData.result.error!._code)", ForDuration: 1.5, completion: nil)
            }
            
        }
    }
    
    
    
}