//
//  Share+View.swift
//  NotchDrop
//
//  Created by 秋星桥 on 2024/7/8.
//  Last Modified by 冷月 on 2025/5/5.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShareView: View {
    enum ShareType {
        case airdrop
        case generic
        
        var imageName: String {
            switch self {
            case .airdrop: return "airplayaudio"
            case .generic: return "arrow.up.circle"
            }
        }
        
        var title: String {
            switch self {
            case .airdrop: return NSLocalizedString("AirDrop", comment: "AirDrop sharing title")
            case .generic: return NSLocalizedString("Share", comment: "Generic sharing title")
            }
        }
        
        var service: ( [URL] ) -> Share {
            switch self {
            case .airdrop:
                return { urls in Share(files: urls, serviceName: .sendViaAirDrop) }
            case .generic:
                return { urls in Share(files: urls) }
            }
        }
    }
    
    @StateObject var vm: NotchViewModel
    let type: ShareType
    
    @State var isTargeting = false
    
    var body: some View {
        dropArea
            .onDrop(of: [.data], isTargeted: $isTargeting) { providers in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    vm.notchClose()
                }
                DispatchQueue.global().async {
                    beginDrop(providers)
                }
                return true
            }
    }
    
    var dropArea: some View {
        RoundedRectangle(cornerRadius: vm.cornerRadius)
            .fill(type == .airdrop ? AnyShapeStyle(.blue.opacity(0.9)) : AnyShapeStyle(Material.regular))
            .opacity(isTargeting ? 0.7 : 1)
            .overlay {
                dropLabel
            }
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vm.notchClose()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    let picker = NSOpenPanel()
                    picker.allowsMultipleSelection = true
                    picker.canChooseDirectories = true
                    picker.canChooseFiles = true
                    picker.begin { response in
                        if response == .OK {
                            let drop = type.service(picker.urls)
                            drop.begin()
                        }
                    }
                }
            }
            .animation(vm.animation, value: isTargeting)
    }
    
    var dropLabel: some View {
        VStack(spacing: 8) {
            Image(systemName: type.imageName)
                .font(.system(size: 18))
            Text(type.title)
                .font(.system(size: 13))
        }
        .fontWeight(.medium)
        .contentShape(Rectangle())
    }
    
    func beginDrop(_ providers: [NSItemProvider]) {
        assert(!Thread.isMainThread)
        guard let urls = providers.interfaceConvert() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let drop = type.service(urls)
            drop.begin()
        }
    }
}
