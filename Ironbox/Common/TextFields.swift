//
//  TextFields.swift
//  Ironbox
//
//  Created by Abul Hussain on 21/10/21.
//  Copyright © 2021 Gopalsamy A. All rights reserved.
//

import SwiftUI

struct Textfield1: View {
    let coordinator: TextFieldCoordinator
    var body: some View {
        VStack {
            UI<UITextField> {
                let field = coordinator.textField
                field.textAlignment = .left
                field.font = .init(name: FONT_REG, size: 15)
                field.keyboardType = .default
                return field
            }
            
            Color.black.opacity(0.7)
                .frame(height: 1)
        }
    }
}
