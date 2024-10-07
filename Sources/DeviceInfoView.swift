//
//  DeviceInfoView.swift
//  DeviceTest
//
//  Created by Ben Ku on 3/29/24.
//

#if canImport(SwiftUI)
import SwiftUI
import Color

public extension CGFloat {
    static let devicePanelRadius: Double = 15
}

/// Technincally a function but present like a View struct.
@available(iOS 13, tvOS 13, watchOS 6, *)
@MainActor
public func CapabilitiesTextView(capabilities: Capabilities) -> Text {
    var output = Text("")
    for capability in capabilities.sorted {
        // don't show screen icon since not really helpful
        if case .screen = capability {}
        // don't show mac form either since redundant
        else if case .macForm = capability {}
        // and cellular doesn't really make sense either unless we want to indicate the type
        else if case .cellular = capability {}
        // and cameras don't really make sense either
        else if case .cameras = capability {}
        // and we don't really want to flag battery here
        else if case .battery = capability {}
        // and watches don't need watch size
        else if case .watchSize = capability {}
        else {
            if #available(watchOS 7.0, *) {
                // Fallback on earlier versions
                if #available(iOS 14, macOS 11.0, tvOS 14, *) {
                    if #available(iOS 15, macOS 12.0, watchOS 8.0, tvOS 15.0, *) {
                        output = output + Text(Image(symbolName: capability.symbolName).symbolRenderingMode(.hierarchical)
                        ) + Text(" ")
                    } else { // symbolRenderingMode not available
                        output = output + Text(Image(capability)
                        ) + Text(" ")
                    }
                } else {
                    // Fallback on earlier versions
                    output = output + Text(capability.caseName)
                    + Text(" ")
                }
            } else {
                // Fallback on earlier versions
                output = output + Text("\(capability.symbolName)") + Text(" ")
            }
        }
    }
    return output
}

/// Technincally a function but present like a View struct.
@available(iOS 13, tvOS 13, watchOS 6, *)
@MainActor
public func ColorsTextView(symbol: SymbolRepresentable, colors: [MaterialColor]) -> Text {
    var output = Text("")
    for color in colors {
        // Fallback on earlier versions
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, *) {
            output = output
            + Text(Image(symbol))
                .foregroundColor(Color(string: color.rawValue))
            //                        + Text(" ")
        } else {
            // Fallback on earlier versions
            output = output + Text("\(symbol.symbolName.first ?? "x")")
                .foregroundColor(Color(string: color.rawValue))
            + Text(" ")
        }
    }
    return output
}

@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
public struct DeviceInfoView: View {
    public var device: DeviceType
    
    var includeScreen: Bool
    var includeAttributes: Bool
    
    public init(device: any DeviceType, includeScreen: Bool = false, includeAttributes: Bool = false) {
        self.device = device
        self.includeScreen = includeScreen
        self.includeAttributes = includeAttributes
    }
    
    public var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(device.officialName)
                    .font(.headline)
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        ColorsTextView(symbol: device.idiomatic, colors: device.colors)
                            .shadow(color: .gray, radius: 0.5)
                        CapabilitiesTextView(capabilities: device.capabilities)
                            .font(.caption)   
                    }
                    Spacer(minLength: 0)
                    // Don't squish - need to wrap colors above if necessary.  Accompished by creating ColorsTextView creator.
                    VStack(alignment: .trailing) {
                        Text("\(device.supportedOSInfo)").font(.caption).foregroundStyle(.gray)
                        if #available(iOS 14.0, *) {
                            Text("\(device.cpu.caseName) ").font(.footnote.smallCaps())+Text(
                                Image(symbolName: "cpu"))
                        } else {
                            // Fallback on earlier versions
                            Text("\(device.cpu.caseName) ").font(.footnote.smallCaps())+Text("cpu")
                        }
                    }
                }
            }
            Spacer()
            if let image = device.image {
                if #available(iOS 15.0, macOS 12, macCatalyst 15, tvOS 15, watchOS 8, *) {
                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                } else {
                    // Fallback on earlier versions
                    // Don't show the image on devices less than iOS 15
                }
            }
        }
        if includeScreen {
            HStack {
                Spacer()
                Link(device.identifiers.joined(separator: ", "), destination: device.supportURL)
                //                    Text(device.identifiers.joined(separator: ", "))
                    .font(.caption)
                Spacer()
            }
        }
        if device.screen != nil && includeScreen {
            ScreenInfoView(device: device)
        }
        if includeAttributes {
            AttributeListView(device: device, header: "Capabilities", attributes: Capability.allCases)
        }
    }
}

@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview("DeviceInfoView") {
    List {
        DeviceInfoView(device: Device(identifier: "AudioAccessory5,1"))
    }
}

@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct DeviceDetailView: View {
    var device: DeviceType
    public init(device: DeviceType) {
        self.device = device
    }
    public var body: some View {
        List {
            DeviceInfoView(device: device, includeScreen: true, includeAttributes: true)
        }
        .navigationWrapper()
    }
}

@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview("DeviceDetailView") {
    DeviceDetailView(device: Device.current)
}


@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct DeviceListView<Destination: View>: View {
    public var devices: [DeviceType]
    
    @State var searchText = ""
    
    private let destination: (DeviceType) -> Destination
    public init(devices: [any DeviceType], @ViewBuilder destination: @escaping (DeviceType) -> Destination) {
        self.devices = devices
        self.destination = destination
    }
    
    // TODO: extract this out into KuditFrameworks as a way to section content with a callback for determining the header to group under.
    var sectioned: [(String,[DeviceType])] {
        var sections = [(String,[DeviceType])]()
        var lastIdiom: Device.Idiom?
        var sectionDevices = [DeviceType]()
        for device in devices {
            if device.idiom != lastIdiom {
                if let lastIdiom, sectionDevices.count > 0 {
                    sections.append((lastIdiom.label, sectionDevices))
                    sectionDevices = []
                }
                lastIdiom = device.idiom
            }
            if searchText == "" || "\(device.safeOfficialName) \(device.cpu.caseName) \(device.identifiers.joined(separator: " "))".lowercased().contains(searchText.lowercased()) {
                sectionDevices.append(device)
            }
        }
        if let lastIdiom, sectionDevices.count > 0 {
            sections.append((lastIdiom.label, sectionDevices))
        }
        return sections
    }
    public var body: some View {
        List {
            ForEach(sectioned, id: \.0) { section in
                Section {
                    ForEach(section.1, id: \.device) { device in
                        NavigationLink {
                            destination(device)
                        } label: {
                            DeviceInfoView(device: device, includeScreen: false)
                        }
                    }
                } header: {
                    Text(section.0)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Devices")
    }
}
@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension DeviceListView where Destination == DeviceDetailView {
    init(devices: [any DeviceType]) {
        self.init(devices: devices) { device in
            DeviceDetailView(device: device)
        }
    }
}

@available(iOS 15, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview("All Devices") {
    NavigationView {
        DeviceListView(devices: Device.all) { device in
            List {
                DeviceInfoView(device: device, includeScreen: true, includeAttributes: true)
            }
            .padding()
        }
    }
}
#endif
