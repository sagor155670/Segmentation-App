//
//  ContentView.swift
//  Segmentation
//
//  Created by Saiful Islam Sagor on 30/10/23.
//

import SwiftUI

struct ContentView: View {

    @State var isShowingPicker = false
    @State var selectedImage:UIImage?
    @State var ImageToShow:UIImage? = nil
    @State var outputImage:UIImage? = nil
    @State var outputImageUrl:String? = nil
    @State var showProgress: Bool = false
    @State var showAlert:Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""

//    @GestureState private var scale = CGFloat(1.0)
//    @State private var finalScale = CGFloat(1.0)
//    @State var dragOffset = CGSize.zero
//    @State var finalDragAmount = CGSize.zero
//    @State var isDragging:Bool = false
    
    
    @GestureState var scale = 1.0
    @State var finalScale = 1.0

    @State private var location = CGPoint(x: 158, y: 225)//CGPoint(x: 160, y: 225)
    @GestureState var startLocation:CGPoint? = nil
    
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
    
    var simpleMagnify: some Gesture {
        MagnificationGesture()
            .updating($scale) { currentState, gestureState, trans in
                gestureState = currentState.magnitude
            }
            .onEnded { value in
                finalScale *=  value
                if finalScale < 1 {
                    finalScale = 1.0
                }

            }
    }
    
    var body: some View {
        VStack{
            HStack{
                Button {
                    downloadButtonAction()
                } label: {
                    Text("Download ")
                        .font(.callout)
                        .fontWeight(.heavy)
                }
                Button {
                    processButtonAction()
                } label: {
                    Text("Process")
                        .font(.callout)
                        .fontWeight(.heavy)
                }
            }
            VStack{
                MediaPreviewer
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
            .frame(height: UIScreen.main.bounds.height/2)
            
            .padding(.bottom,20)
            Spacer(minLength: 30)
            
            InputPreviewer
        }
        .frame(height: 200)
        .padding(50)
        
            // Showing Picker For input image
        .sheet(isPresented: $isShowingPicker){
            mediaPicker(selectedMedia: .constant(nil), selectedImage: $selectedImage, isShowingPicker: $isShowingPicker, mediaTypes: ["public.image"])
        }
        
            //Loading OutputImage from Response Url using loadImage function
        .onChange(of: outputImageUrl ?? "") { url in
            loadImage(for: url)
        }
        .onChange(of: selectedImage){_ in
            ImageToShow = nil
            outputImageUrl = nil
            outputImage = nil
            location = CGPoint(x: 158, y: 225)
//            isDragging = false
//            dragOffset = .zero
//            finalDragAmount = .zero
//            finalScale = 1.0
            
        }

    }
    

        //ViewBuilder Computed property for Main Previewer
    @ViewBuilder
    var MediaPreviewer: some View {
        ZStack{
            Rectangle()
                .strokeBorder(style: .init(lineWidth: 2))
                .foregroundColor(Color.gray)
            
            VStack {
                if showProgress {
                    ProgressView()
                }
                else{
                    if outputImage != nil {
                        Image(uiImage: outputImage!)
                            .resizable()
                            .scaledToFit()
                            .frame(height: UIScreen.main.bounds.height/2)
                            .border(Color.red, width: 3)
                            .clipShape(Rectangle())
                            .position(location)
                            .scaleEffect(scale * finalScale)
                            .clipShape(Rectangle())
                    }
                    else{
                        if ImageToShow != nil {
                            Image(uiImage: ImageToShow!)
                                .resizable()
                                .scaledToFit()
                                .frame(height: UIScreen.main.bounds.height/2)
                                .border(Color.red, width: 3)
                                .position(location)
                                .scaleEffect(scale * finalScale)
                                .clipShape(Rectangle())
                            
                        }
                        else{
                            Text("Tap image to show")
                                .font(.callout)
                                .fontWeight(.heavy)
                        }
                    }
                }
            }
            .border(Color.blue, width: 2)
            .gesture(simpleDrag.simultaneously(with: simpleMagnify))

        }

        
    }
    
        //ViewBuilder Computed property for Input Previewer
    @ViewBuilder
    var InputPreviewer: some View {
        HStack{
            ZStack{
                Rectangle()
                    .foregroundColor(.clear)
                
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio( contentMode: .fit)
                        .frame(width: 150,height: 175)
                        .foregroundColor(.gray)
                    
                }else{
                    Image(systemName: "photo.tv")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                }
                
                
            }
            .onTapGesture(count: 2) {
                isShowingPicker.toggle()
            }
            .onTapGesture {
                ImageToShow = selectedImage
            }
            Spacer(minLength: 20)
        }
    }
    
        //func downloadButton Action
    func downloadButtonAction(){
        if let outputImageUrl = outputImageUrl {
            downloadAndSaveImage(url: outputImageUrl)
            
            outputImage = nil
            self.outputImageUrl = nil
        }
        else{
            self.alertTitle = "Error!"
            self.alertMessage = "That's not a Output image!"
            showAlert = true
            print("media did not saved")
        }
    }
    
        // process button action
    func processButtonAction(){
        if selectedImage != nil {
            showProgress = true
            sendAPIPostRequest(Image: selectedImage!){ url in
                outputImageUrl = url
                showProgress = false
            }
        }

    }
    
        //load the image from url
    func loadImage(for urlString: String) {
        print("Loading Image ...")
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.outputImage = UIImage(data: data) ?? UIImage()
            }
        }
        task.resume()
    }
        
        //download and save the image
    func downloadAndSaveImage(url: String){
        guard let URL = URL(string:url)  else { return }
        
        let task = URLSession.shared.dataTask(with: URL){ (data, response,error) in
            if let data = data , let image = UIImage(data: data){
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.alertTitle = "Success"
                self.alertMessage = "Image saved Successfully!"
                showAlert = true
            }
            else{
                self.alertTitle = "Error!"
                self.alertMessage = "Could not save image!"
                showAlert = true
            }
            
        }
        
        task.resume()
    }
    
    func sendAPIPostRequest(Image: UIImage, completion: @escaping (String?) -> Void) {
        
        guard let url = URL(string: "http://103.4.146.174:8222/api/segmentation/") else{
            print("Url not found")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data  = Data()
        

        
        // Add Image Data
        if let imageData = Image.jpegData(compressionQuality: 0.8) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpeg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)
        }

        
            // Ending of body
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = data
            
            

        
        let task = URLSession.shared.dataTask(with: request){(data,response,error) in
            
            if let error = error{
                print("Error Sending Data: \(error)")
                completion(nil)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                
                print("Response status code: \(response.statusCode)")
                                if response.statusCode != 200{
                                print("Server error!")
                                    self.alertTitle = "Server Error!"
                                    self.alertMessage = "Please try again....!"
                                    showAlert = true
                                    completion(nil)
                                }
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    if let error = json["Error"]{
                        return
                    }
                    let downloadLink = json["mask_url"] as! String
                    print(json["mask_url"] as! String)
                    completion(downloadLink)
                }catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
