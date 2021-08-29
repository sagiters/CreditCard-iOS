//
//  DeviceIdiomView.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/29.
//

import SwiftUI

struct DeviceIdiomView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            Color.red
        } else {
            if horizontalSizeClass == .compact {
                Color.blue
            } else {
                Color.green
            }
        }
    }
}

struct DeviceIdiomView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceIdiomView()

        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .environment(\.horizontalSizeClass, .regular)
//            .previewInterfaceOrientation(.landscapeLeft)

        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .environment(\.horizontalSizeClass, .compact)
    }
}
