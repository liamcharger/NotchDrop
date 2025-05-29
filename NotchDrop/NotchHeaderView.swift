//
//  NotchHeaderView.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/7.
//

import ColorfulX
import SwiftUI

struct NotchHeaderView: View {
    @StateObject var vm: NotchViewModel

    var body: some View {
        HStack {
            Text("Notch Drop")
            Spacer()
            Image(systemName: vm.contentType == .settings ? "arrow.uturn.backward" : "gear")
        }
        .animation(vm.animation, value: vm.contentType)
        .font(.system(.headline))
    }
}

#Preview {
    NotchHeaderView(vm: .init())
}
