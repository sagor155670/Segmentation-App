    //
    //  TestSegment.swift
    //  Segmentation
    //
    //  Created by Saiful Islam Sagor on 31/10/23.
    //

import SwiftUI

struct TestSegment: View {
//    @State var offset = CGSize.zero
    @State var finalOffset = CGSize.zero
    @GestureState var scale = 1.0
    @State var finalScale = 1.0

    @State private var location = CGPoint(x: 160, y: 225)
    @GestureState var startLocation:CGPoint? = nil
    
    @State var isInteracting: Bool = false
    @State var offset:CGSize = .zero
    @State var lastStoredOffest: CGSize = .zero
    
    @State var rect: CGRect = .zero
    
    var simpleDragging: some Gesture {
        DragGesture()
//            .updating($isInteracting) { _, value , _ in
//                value = true
//            }
            .onChanged { value in
                isInteracting = true
                let translation = value.translation
                offset = CGSize(width: translation.width + lastStoredOffest.width, height: translation.height + lastStoredOffest.height)
//                print("offsetwidth: \(translation.width) offsetheight: \(translation.height)")
            }
            .onEnded { value in
                isInteracting = false
                let translation = value.translation
                print("offsetwidth: \(translation.width) offsetheight: \(translation.height) scale: \(finalScale)")
            }
    }
    
//    var simpleDrag: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                var newLocation = startLocation ?? location
//                newLocation.x += value.translation.width
//                newLocation.y += value.translation.height
//                self.location = newLocation
//            }
//            .updating($startLocation) { value, startlocation, _ in
//                startlocation = startlocation ?? location
//            }
//    }
    
    var simpleMagnify: some Gesture {
        MagnificationGesture()
            .updating($scale) { currentState, gestureState, trans in
                isInteracting = true
                gestureState = currentState.magnitude
            }
//            .onChanged { value in
//                isInteracting = true
//            }
            .onEnded { value in
                finalScale *=  value
                if finalScale < 1 {
                    finalScale = 1.0
                }
                isInteracting = false

            }
    }

    var body: some View {
        ZStack{
            Color.gray
            VStack{
//                Text("scale effect of : \(scale * finalScale)")
                GeometryReader{
                    let size = $0.size
                    Text("width: \(size.width) height: \(size.height)")
                    Image("51")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay{
                            GeometryReader{ proxy in
                                let rect = proxy.frame(in: .named("TestSegment"))
                                
//                                Text("width: \(rect.width) height: \(rect.height)")
//                                Text("minwidth: \(rect.minX) minheight: \(rect.minY)")
                                Color.clear
                                    .onChange(of: isInteracting) { newValue in
                                        self.rect = rect
                                        print("minX: \(rect.minX) minY: \(rect.minY)")
                                        
                                        if rect.minX > 0{
                                            offset.width -= rect.minX
                                        }
                                        if rect.minY > 0 {
                                            offset.height -= rect.minY
                                        }
                                        if rect.maxX < size.width {
                                            offset.width = (rect.minX - offset.width)
                                        }
                                        if rect.maxY < size.height {
                                            offset.height = (rect.minY - offset.height)
                                        }
                                        if !newValue {
                                            lastStoredOffest = offset
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: size.width,height: size.height)
//                        .position(location)
                        .scaleEffect(scale * finalScale)
                        .offset(offset)
//                        .clipShape(Rectangle())
                        .clipped()
//                        .gesture(simpleDrag.simultaneously(with: simpleMagnify))
                        .gesture(simpleDragging.simultaneously(with: simpleMagnify))
                }
                .coordinateSpace(name: "TestSegment")

            }
//            .frame(width: UIScreen.main.bounds.width - 100,height: UIScreen.main.bounds.height/2)
            .border(Color.blue,width: 3)
            
            

            
        }
        .frame(width: UIScreen.main.bounds.width - 100,height: UIScreen.main.bounds.height/2)
        .border(Color.gray,width: 3)
    }
}

struct TestSegment_Previews: PreviewProvider {
    static var previews: some View {
        TestSegment()
    }
}
