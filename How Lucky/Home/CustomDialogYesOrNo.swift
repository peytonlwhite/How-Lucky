//
//  CustomDialog.swift
//  How Lucky
//
//  Created by Peyton White on 11/15/24.
//

import SwiftUI

struct CustomDialogYesOrNo: View {
    @Binding var isActive: Bool

    let title: String
    let message: String
    let yesButtonTitle: String
    let noButtonTitle: String
    let action: (_ isYes:Bool) -> ()
    @State private var offset: CGFloat = 1000

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.3)
                .cornerRadius(8)
                .onTapGesture {
                    close()
                }

            VStack {
                Text(title)
                    .font(.title2)
                    .bold()
                    .padding()
                    .foregroundStyle(.black)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center) // Center-align text

                HStack {
                    Button {
                        action(true)
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.red)

                            Text(yesButtonTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }
                    
                    Button {
                        action(false)
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.red)

                            Text(noButtonTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                        }
                        .padding()
                    }
                }
                
             
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .fontWeight(.medium)
                }
                .tint(.black)
                .padding()
            }
            .shadow(radius: 20)
            .padding(30)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
        .ignoresSafeArea()
    }

    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isActive = false
        }
    }
}

#Preview {
    CustomDialogYesOrNo(isActive: .constant(true), title: "Free Continue", message: "Watch an Ad to continue?", yesButtonTitle: "Yes", noButtonTitle: "No", action: {isYes in })
}
