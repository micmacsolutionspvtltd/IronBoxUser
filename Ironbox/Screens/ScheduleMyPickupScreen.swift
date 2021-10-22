//
//  ScheduleMyPickupScreen.swift
//  Ironbox
//
//  Created by Abul Hussain on 20/10/21.
//  Copyright © 2021 Gopalsamy A. All rights reserved.
//

import SwiftUI

//class VMScheduleMyPickup: ObservableObject {
//    let fieldCount = TextFieldCoordinator()
//    let fieldPromoCode = TextFieldCoordinator()
//    let fieldVoucherCode = TextFieldCoordinator()
//    
//    init() {
//        fieldPromoCode.textField.placeholder = "Enter promo code"
//        fieldVoucherCode.textField.placeholder = "Enter voucher code"
//    }
//}

struct ToggleButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Text(text)
            .font(.custom(FONT_REG, size: 13))
            .foregroundColor(Color(isSelected ? .white : .primaryColor))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? AnyView( Color(.hex("89D6EF")).cornerRadius(5)) : AnyView(RoundedRectangle(cornerRadius: 5).stroke(Color(.primaryColor), lineWidth: 1))
            )
            .onTapGesture {
                action()
            }
    }
}

struct ScheduleMyPickupScreen: View {
    
//    @StateObject private var data = VMScheduleMyPickup()
    @ObservedObject var data: HomeVC
    @ViewBuilder
    private func navigationBar() -> some View {
        ZStack {
            Text("Shedule My Pickup")
                
            HStack {
                Button {
                    data.viewClothes2.isHidden = true
//                    controller.navigationController?.setNavigationBarHidden(false, animated: true)
                    data.viewBooking.isHidden = true
                } label: {
                    Image("BackButton")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                }
                
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .foregroundColor(.white)
        .padding(.top, safeArea.top)
        .padding(.vertical, 10)
        .background(
            Color(.primaryColor)
        )
    }
    
    @ViewBuilder
    private func button(title: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.custom(FONT_REG, size: 12))
                .foregroundColor(.white)
                .padding(10)
                .background(
                    Color(.primaryColor)
                )
        }
    }
    
    @ViewBuilder
    private func imageView1(name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 30)
    }
    
    @ViewBuilder
    private func imageView2(imageName: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 30)
                .padding(.trailing, 20)
            Text(title)
                .font(.custom(FONT_REG, size: 16))
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
//                navigationBar()
                ScrollView {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            imageView1(name: "OnGoing Orders")
                            Text(data.selectedAddressName)
                                .font(.custom(FONT_REG, size: 13))
                            Spacer()
                            button(title: "CHANGE") {
                                data.showPopup(leftView: nil, rightView: data.viewAddress, isMoveRight: true)
                            }
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
                        HStack(spacing: 10) {
                            imageView1(name: "OnGoing Orders")
                            Text("DATE: \(data.dSelectedDate), TIME: \(data.strTimeSlot)")
                                .font(.custom(FONT_REG, size: 13))
                            Spacer()
                            button(title: "CHANGE") {
                                data.showPopup(leftView: nil, rightView: data.viewDate, isMoveRight: true)
                            }
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
                        VStack(alignment: .leading) {
                            HStack {
                                imageView2(imageName: "OnGoing Orders", title: "Count of clothes")
                                Spacer()
                                UI<UITextField> {
                                    let field = data.fieldCount.textField
                                    field.textAlignment = .center
                                    field.font = .init(name: FONT_REG, size: 15)
                                    field.keyboardType = .numberPad
                                    return field
                                }
                                .padding(8)
                                .background(
                                    Color(.hex("D8D8D8"))
                                )
                                .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            HStack(spacing: 10) {
                                Textfield1(coordinator: data.fieldPromoCode)
                                Spacer()
                                button(title: "OFFERS") {
                                    data.onOffers(data.btnOffers)
                                }
                            }
                            .padding(.leading, 60)
                            
                            HStack {
                                Textfield1(coordinator: data.fieldVoucherCode)
                                    .padding(.leading, 60)
                                Text("     Offer     ")
                                    .opacity(0)
                            }
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
                        VStack(alignment: .leading, spacing: 20) {
                            imageView2(imageName: "OnGoing Orders", title: "Payment Mode")
                            HStack(spacing: 10) {
                                ToggleButton(text: "Cash", isSelected: data.isCash) {
                                    data.isCash = true
                                }
                                ToggleButton(text: "Wallet", isSelected: !data.isCash) {
                                    data.isCash = false
                                }
                            }
                            .padding(.leading, 60)
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
                        VStack(alignment: .leading, spacing: 20) {
                            imageView2(imageName: "OnGoing Orders", title: "Delivery Type")
                            HStack(spacing: 10) {
                                ToggleButton(text: "Normal", isSelected: data.isNormalDeliveryType) {
                                    data.isNormalDeliveryType = true
                                }
                                ToggleButton(text: "Fast delivery", isSelected: !data.isNormalDeliveryType) {
                                    data.isNormalDeliveryType = false
                                }
                            }
                            .padding(.leading, 60)
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
//                        UI<UITextField> {
//                            let field = data.fieldInstruction.textField
//                            field.textAlignment = .center
//                            field.placeholder = "Enter instructions..."
//                            field.font = .init(name: FONT_REG, size: 15)
//                            field.keyboardType = .numberPad
//                            return field
//                        }
//                        .padding(10)
//                        .background(
//                            Color(.hex("D8D8D8"))
//                        )
//                        .fixedSize(horizontal: false, vertical: true)
                        
                        Button {
                            
                        } label: {
                            Text("CONTINUE WITHOUT COUNT")
                                .foregroundColor(.white)
                                .padding(5)
                                .background(
                                    Color(.primaryColor)
                                )
                        }
                        
                        Button {
                            
                        } label: {
                            Text("CONFIRM")
                                .foregroundColor(.white)
                                .padding(5)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Color(.primaryColor)
                                )
                                .padding(.horizontal, 25)
                        }
                    }
                    .padding(10)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct ScheduleMyPickupBackgroundModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(
                Color(.appGray)
            )
    }
}

struct ScheduleMyPickupScreen_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleMyPickupScreen(data: HomeVC())
    }
}
