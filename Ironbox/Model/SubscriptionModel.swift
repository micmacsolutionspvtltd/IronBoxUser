//
//  SubscriptionModel.swift
//  Ironbox
//
//  Created by MAC on 20/05/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import Foundation

struct SubscriptionModel: Codable {
    let packs: [Pack]?
    let status, errorMessage: String?
   
    enum CodingKeys: String, CodingKey {
        case packs, status
        case errorMessage = "error_message"
    }
}

// MARK: - Pack
struct Pack: Codable {
    let id: Int?
    let packageName, amount, freePoints, expiryDays , description: String?
  //  let minimumOrderQuantity: Int?
  //  let activeStatus: String?
   // let createdAt : String?

    enum CodingKeys: String, CodingKey {
        case id
        case packageName = "package_name"
        case amount
        case freePoints = "free_points"
        case expiryDays = "expiry_days"
        case description = "desc"
      //  case minimumOrderQuantity = "minimum_order_quantity"
     //   case createdAt = "created_at"
     //   case activeStatus = "active_status"
    }
}
// MARK: - Booking
struct BookHistory: Codable {
    let userID , quantity : Int?
    let status , bookingDate , bookingId , subPoints:  String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case status = "Status"
        case subPoints = "sub_points"
        case quantity , bookingDate  , bookingId
    }
}
// MARK: - SubscriptionDetailModel

struct SubscriptionDetailModel: Codable {
    let subscribtionname: String?
    let subscribers: Subscribers?
    let amount, remainingPoints, totalPoints, status: String?
    let errorMessage: String?
    let bookHistory : [BookHistory]?
    //let history : [BookHistory]?
    enum CodingKeys: String, CodingKey {
        case subscribtionname, subscribers, amount
        case remainingPoints = "remaining_points"
        case totalPoints = "total_points"
        case status
        case errorMessage = "error_message"
        case bookHistory = "Bookings"
    }
}

// MARK: - Subscribers
struct Subscribers: Codable {
    let id: Int?
    let userID, packageID, amount, paymentMode , description: String?
    let paymentdate, activeStatus, packageName, freePoints: String?
    let expiryDays, minimumOrderQuantity , expiryDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case packageID = "package_id"
        case amount
        case paymentMode = "payment_mode"
        case paymentdate
        case activeStatus = "active_status"
        case packageName = "package_name"
        case freePoints = "free_points"
        case expiryDays = "expiry_days"
        case minimumOrderQuantity = "minimum_order_quantity"
        case expiryDate = "expiry date"
        case description = "description"
    }
}
