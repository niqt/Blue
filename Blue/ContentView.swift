//
//  ContentView.swift
//  Blue
//
//  Created by nicola on 16/11/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    @State private var scan = false
    @State private var adv = false
    
    var body: some View {
        VStack (spacing: 10) {
            Text("STATUS")
                .font(.headline)
            
            if bleManager.isSwitchedOn {
                Text("ON")
                    .foregroundColor(.green)
            }
            else {
                Text("OFF")
                    .foregroundColor(.red)
            }
            HStack {
                Spacer()
                Toggle("Scan", isOn: $scan)
                    .toggleStyle(SwitchToggleStyle(tint: .red))
                    .onChange(of: scan) { value in
                        // action...
                        self.bleManager.startScanning()
                    }
                
            }
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            List(bleManager.peripherals) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Spacer()
                    Text(String(peripheral.rssi))
                }
            }.frame(height: 300)
            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
