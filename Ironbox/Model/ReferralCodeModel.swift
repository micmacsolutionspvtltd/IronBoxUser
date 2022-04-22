//
//  ReferralCodeModel.swift
//  Ironbox
//
//  Created by MAC on 19/04/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import Foundation

struct ReferralCodeModel: Codable {
    let agentCode, status, errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case agentCode = "agent_code"
        case status
        case errorMessage = "error_message"
    }
}
