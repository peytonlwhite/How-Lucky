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
    @State private var hasResolved = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { resolve(false) }
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(title).font(.title2.bold())
                            Spacer()
                            Button { resolve(false) } label: { Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.secondary) }
                                .accessibilityLabel("Close")
                        }
                        Text(message).font(.body).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 12) {
                            Button(noButtonTitle) { resolve(false) }.buttonStyle(.bordered)
                                .frame(maxWidth: .infinity, minHeight: 44)
                            Button(yesButtonTitle) { resolve(true) }.buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }.disabled(hasResolved)
                    }.padding(24)
                }
                .frame(maxWidth: 440, maxHeight: min(360, max(0, geometry.size.height - 32)))
                .background(GamePalette.surface, in: RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 20)
            }
        }
    }

    func resolve(_ choice: Bool) {
        guard !hasResolved else { return }
        hasResolved = true
        isActive = false
        action(choice)
    }
}

#Preview {
    CustomDialogYesOrNo(isActive: .constant(true), title: "Free Continue", message: "Watch an Ad to continue?", yesButtonTitle: "Yes", noButtonTitle: "No", action: {isYes in })
}
