//
//  ScheduleMyPickupScreen.swift
//  Ironbox
//
//  Created by Abul Hussain on 20/10/21.
//  Copyright © 2021 Gopalsamy A. All rights reserved.
//

import SwiftUI
import Alamofire

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
    @available(iOS 13.0.0, *)
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

@available(iOS 13.0, *)
struct ScheduleMyPickupScreen: View {
    
    //    @StateObject private var data = VMScheduleMyPickup()
    @ObservedObject var data: HomeVC
    @State private var isShowConfirmationPopup = false
    @State private var isBookWithCount = true
//    @ViewBuilder
//    private func navigationBar() -> some View {
//        ZStack {
//            Text("Shedule My Pickup")
//
//            HStack {
//                Button {
//                    data.viewClothes2.isHidden = true
//                    //                    controller.navigationController?.setNavigationBarHidden(false, animated: true)
//                    data.viewBooking.isHidden = true
//                } label: {
//                    Image("BackButton")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(height: 22)
//                }
//
//                Spacer()
//            }
//            .padding(.horizontal, 10)
//        }
//        .foregroundColor(.white)
//        .padding(.top, safeArea.top)
//        .padding(.vertical, 10)
//        .background(
//            Color(.primaryColor)
//        )
//    }
    
    @ViewBuilder
    private func button(title: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.custom(FONT_MEDIUM, size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.primaryColor))
                )
        }
    }
    
    @ViewBuilder
    private func imageView1(name: String) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(height: 30)
            .clipShape(Circle())
    }
    
    @ViewBuilder
    private func imageView2(imageName: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(imageName)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 30)
                .clipShape(Circle())
                .padding(.trailing, 20)
            Text(title)
                .font(.custom(FONT_REG, size: 16))
        }
    }
    
    
    
    private func scBooking() {
        if isBookWithCount {
            data.onConfirmBooking(UIButton())
        } else {
            data.onSkipClothesCount(UIButton())
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                //                navigationBar()
                ScrollView {
                    VStack(spacing: 18) {
                        HStack(spacing: 15) {
                            imageView1(name: "placeholder")
                            if data.selectedAddressName != "" {
                                Text(data.selectedAddressName)
                                    .font(.custom(FONT_REG, size: 14))
                            } else {
                                Text("Choose Address")
                                    .font(.custom(FONT_REG, size: 14))
                            }
                            
                            Spacer()
                            button(title: "CHANGE") {
                                data.showPopup(leftView: nil, rightView: data.viewAddress, isMoveRight: true)
                            }
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
                        HStack(spacing: 15) {
                            imageView1(name: "clock")
                            if data.dSelectedDate != "" && data.strTimeSlot != "" {
                                Text("DATE: \(data.dSelectedDate), TIME: \(data.strTimeSlot)")
                                    .font(.custom(FONT_REG, size: 14))
                            } else {
                                Text("Choose date and time")
                                    .font(.custom(FONT_REG, size: 14))
                            }
                            
                            Spacer()
                            button(title: "CHANGE") {
                                data.showPopup(leftView: nil, rightView: data.viewDate, isMoveRight: true)
                            }
                        }
                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                imageView2(imageName: "towel_hanger", title: "Count of clothes")
                                    .layoutPriority(1)
                                Spacer()
                                ZStack {
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
                                    Text("      Offer      ")
                                        .opacity(0)
                                }
                                .fixedSize(horizontal: true, vertical: true)
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
                            imageView2(imageName: "payment_type", title: "Payment Mode")
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
                            imageView2(imageName: "cycle", title: "Delivery Type")
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
                        
//                        VStack(alignment: .leading, spacing: 20) {
//                            Textfield1(coordinator: data.fieldPromoCode)
//                    
//                        }
//                        .modifier(ScheduleMyPickupBackgroundModifier())
                        
//                                                UI<UITextField> {
//                                                    let field = data.fieldInstruction.textField
//                                                    field.textAlignment = .center
//                                                    field.placeholder = "Enter instructions..."
//                                                    field.font = .init(name: FONT_REG, size: 15)
//                                                    field.keyboardType = .numberPad
//                                                    return field
//                                                }
//                                                .padding(10)
//                                                .background(
//                                                    Color(.hex("D8D8D8"))
//                                                )
//                                                .fixedSize(horizontal: false, vertical: true)
                        
                        Button {
                            isBookWithCount = false
                            scCheckAlreadyBooked()
                        } label: {
                            Text("CONTINUE WITHOUT COUNT")
                                .font(.custom(FONT_MEDIUM, size: 15))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(.primaryColor))
                                )
                        }
                        
                        Button {
                            isBookWithCount = true
                            scCheckAlreadyBooked()
                        } label: {
                            Text("CONFIRM")
                                .font(.custom(FONT_MEDIUM, size: 17))
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(.primaryColor))
                                )
                                .padding(.horizontal, 25)
                        }
                        .padding(.vertical, 10)
                    }
                    .padding(20)
                }
            }
            
            if isShowConfirmationPopup {
                BookingConfirmationAlertView {
                    scBooking()
                    isShowConfirmationPopup = false
                } onCancel: {
                    isShowConfirmationPopup = false
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func showLoader() {
        data.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (data.navigationController?.view)!, widthView: nil, message: "Loading"))
        
    }
    
    private func hideLoader() {
        UIView().hideLoader(removeFrom: (data.navigationController?.view)!)
    }
    
    struct MBookingStatus: Codable {
        let error, errorMessage: String
        
        enum CodingKeys: String, CodingKey {
            case error
            case errorMessage = "error_message"
        }
    }
    
    private func scCheckAlreadyBooked() {
        guard data.isValid(isWithCount: isBookWithCount) else { return }
        guard data.CheckNetwork() else { return }
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        showLoader()
        let defaultErrorMessage = "Something went wrong. please try again"
        SessionManager.default.request("\(BASEURL)Check_if_user_has_current_booking", method: .post, headers: header).responseJSON { res in
            hideLoader()
            guard let dataObject = res.data else {
                data.ShowAlert(msg: defaultErrorMessage)
                return
            }
            do {
                let model = try JSONDecoder().decode(MBookingStatus.self, from: dataObject)
                if model.error == "false" {
                    scBooking()
                } else {
                    isShowConfirmationPopup = true
                }
            } catch {
                data.ShowAlert(msg: defaultErrorMessage)
            }
        }
    }
}

struct BookingConfirmationAlertView: View {
    
    let onOkay: () -> Void
    let onCancel: () -> Void
    
    @available(iOS 13.0.0, *)
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("Confirmation")
                        .font(.custom(FONT_MEDIUM, size: 16))
                        .foregroundColor(Color(.black))
                        .padding(.vertical, 10)
                    Color.black
                        .frame(height: 1)
                }
                VStack {
                    Text("You have made booking already which is inprogress. do you want to make another booking?")
                        .font(.custom(FONT_REG, size: 14))
                        .foregroundColor(Color(.black))
                    
                    HStack {
                        Spacer()
                        Button {
                            onCancel()
                        } label: {
                            Text("CANCEL")
                                .font(.custom(FONT_MEDIUM, size: 14))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(.systemRed))
                                )
                        }
                        Spacer()
                        Button {
                            onOkay()
                        } label: {
                            Text("BOOK")
                                .font(.custom(FONT_MEDIUM, size: 14))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color(.systemGreen))
                                )
                        }
                        Spacer()
                    }
                    .padding(.vertical, 25)
                }
                .padding([.horizontal, .top])
            }
            .fixedSize(horizontal: false, vertical: true)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white)
            )
            .padding(.horizontal, 20)
        }
        .fixedSize(horizontal: false, vertical: false)
    }
}

struct ScheduleMyPickupBackgroundModifier: ViewModifier {
    
    @available(iOS 13.0.0, *)
    func body(content: Content) -> some View {
        content
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.appGray))
                    .shadow(color: .black.opacity(0.01), radius: 1, x: 0, y: 0.2)
            )
    }
}

struct ScheduleMyPickupScreen_Previews: PreviewProvider {
    @available(iOS 13.0.0, *)
    static var previews: some View {
        ScheduleMyPickupScreen(data: HomeVC())
    }
}
