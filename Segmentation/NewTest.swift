//
//  NewTest.swift
//  Segmentation
//
//  Created by Saiful Islam Sagor on 1/11/23.
//

import SwiftUI

struct NewTest: View {
    @State var location = CGPoint(x: 220, y: 300)
//    @GestureState var fingerLocation: CGPoint? = nil
    @GestureState var startLocation : CGPoint? = nil
    var body: some View {
        ZStack{
//            RoundedRectangle(cornerRadius: 10)
            Image("51")
                .resizable()
                .scaledToFit()
                .clipShape(Rectangle())
//                .foregroundColor(.pink)
                .frame(width: 400,height: 500)
                .position(location)
                .gesture(simpleDrag)
//                .gesture(simpleDrag.simultaneously(with: fingerDrag))
//            if let fingerLocation = fingerLocation {
//                Circle()
//                    .stroke(Color.green, lineWidth: 3)
//                    .frame(width: 44,height: 44 )
//                    .position(fingerLocation)
//            }
        }
    }
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
            }
            .updating($startLocation) { value, startlocation, _ in
                startlocation = startlocation ?? location
            }
    }
//    var fingerDrag: some Gesture {
//        DragGesture()
//            .updating($fingerLocation){ currentlocation,fingerlocation, _ in
//                fingerlocation = currentlocation.location
//            }
//    }
}

struct NewTest_Previews: PreviewProvider {
    static var previews: some View {
        NewTest()
    }
}
