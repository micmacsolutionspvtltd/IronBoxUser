//
//  VersionCheckClass.swift
//  Ironbox
//
//  Created by MAC on 11/05/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class VersionCheck {
    public static let shared = VersionCheck()
    var newVersionAvailable: Bool?
    var appStoreVersion: String?
    func checkAppStore(callback: ((_ versionAvailable: Bool?, _ version: String?)->Void)? = nil) {
        let ourBundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        Alamofire.request("https://itunes.apple.com/lookup?bundleId=\(ourBundleId)").responseJSON { response in
            var isNew: Bool?
            var versionStr: String?
            if let json = response.result.value as? NSDictionary,
               let results = json["results"] as? NSArray,
               let entry = results.firstObject as? NSDictionary,
               let appVersion = entry["version"] as? String,
               let ourVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            {
                isNew = ourVersion != appVersion
                versionStr = appVersion
            }
            self.appStoreVersion = versionStr
            self.newVersionAvailable = isNew
            callback?(isNew, versionStr)
        }
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
    print(currentVersion)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
}

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}
struct ErrorConstants {
    static let genericErrorMessage = "Error Occurred. Please try again in sometime."
    static let serverError = "Server failed to process your request"
    static let badRequest = "Unable to process your request. Please try again."
    static let resourceNotFound = "Please try again later (Resource Not Found)."
}


enum NetworkError: Error {
    case noInternetAccess
    case unAuthorised
    case requestTimedOut
    case badRequest
    case serverError (reason: String)
    case unknown(reason: String)
}

extension NetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case .noInternetAccess: return "Please check your internet connection and try again"
        case .unAuthorised: return "Session Expired. Please sign in again"
        case .requestTimedOut: return "Request timed out"
        case .badRequest: return ErrorConstants.badRequest
        case .serverError (let reason): return "\(ErrorConstants.serverError) (\(reason)). Please try again."
        case .unknown(let reason): return reason
        }
    }

    var localizedDescription: String {
        return self.description
    }

}
