//
//  ContentView.swift
//  Instafilter
//
//  Created by Amit Shrivastava on 01/01/22.
//
//create UIImage from Swift Image
//import SwiftUI
//import CoreImage
//import CoreImage.CIFilterBuiltins
//
//struct Instafilter: View {
//
//    @State private var image: Image?
//    var body: some View {
//        VStack {
//            image?
//                .resizable()
//                .scaledToFit()
//        }
//        .onAppear {
//            loadImage()
//        }
//    }
//
//    func loadImage() {
//        guard let inputImageData = UIImage(named: "Example") else { return }
//        let beginImage = CIImage(image: inputImageData)
//
//        let context = CIContext()
//     //   let currentFilter = CIFilter.sepiaTone()
//     //   let currentFilter = CIFilter.pixellate()
//        let currentFilter = CIFilter.twirlDistortion()
//        currentFilter.inputImage = beginImage
//    //    currentFilter.intensity = 1
//    //    currentFilter.scale = 100
//        let amount = 1.0
//
//        let inputKeys = currentFilter.inputKeys
//
//        if inputKeys.contains(kCIInputIntensityKey) {
//            currentFilter.setValue(amount, forKey: kCIInputIntensityKey) }
//        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey) }
//        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey) }
//
//
//
//        guard let outputImage = currentFilter.outputImage else { return }
//
//        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
//            let uiImage = UIImage(cgImage: cgimg)
//            image = Image(uiImage: uiImage)
//        }
//    }
//}
//
//struct Instafilter_Previews: PreviewProvider {
//    static var previews: some View {
//        Instafilter()
//    }
//}


//import SwiftUI
//import CoreImage
//import CoreImage.CIFilterBuiltins
//
//struct Instafilter: View {
//
//    @State private var image: Image?
//    @State private var showingImagePicker = false
//    @State private var inputImage: UIImage?
//    var body: some View {
//        VStack {
//            VStack {
//                image?
//                    .resizable()
//                    .scaledToFit()
//
//                Button("Select Image") {
//                    showingImagePicker = true
//                }
//            }
//            .sheet(isPresented: $showingImagePicker) {
//                ImagePicker(image: $inputImage)
//            }
//            .onChange(of: inputImage) { _ in loadImage() }
//
//            Button("Save Image") {
//                guard let inputImage = inputImage else { return }
//
//                let imageSaver = ImageSaver()
//                imageSaver.writeToPhotoAlbum(image: inputImage)
//            }
//        }
//
//    }
//
//    func loadImage() {
//        guard let inputImage = inputImage else { return }
//        image = Image(uiImage: inputImage)
//        UIImageWriteToSavedPhotosAlbum(inputImage, nil, nil, nil)
//    }
//
//
//}
//
//struct Instafilter_Previews: PreviewProvider {
//    static var previews: some View {
//        Instafilter()
//    }
//}

import Photos
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct Instafilter: View {
    @State private var processedImage: UIImage?
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilterSheet = false
    //---radius
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    @State private var showPrivacyAlert = false
    //----end radius data
    let context = CIContext()
    var body: some View {
        
        VStack {
            ZStack {
                Rectangle()
                    .fill(.secondary)
                Text("Tap to select a picture")
                    .foregroundColor(.white)
                    .font(.headline)
                image?
                    .resizable()
                    .scaledToFit()
            }
            .onTapGesture {
                showingImagePicker = true
            }
            
            HStack {
                Text("Intensity")
                Slider(value: $filterIntensity)
                    .onChange(of: filterIntensity) { _ in
                        applyProcessing()
                    }
            }
            
            HStack {
                            Text("radius")
                            Slider(value: $filterRadius)
                                .onChange(of: filterRadius) { _ in
                                    applyProcessing()
                                }
                        }
            HStack {
                            Text("scale")
                            Slider(value: $filterScale)
                                .onChange(of: filterScale) { _ in
                                    applyProcessing()
                                }
                        }
            
            
            
            
            
            HStack {
                Button("Change Fiilter") {
                    showingFilterSheet = true
                }
                
                
                Spacer()
                Button("Save", action: save)
                    .disabled(inputImage == nil)
                
            }
            .alert("Privacy Access Alert, Change Settings of App to allow Image Save Process", isPresented: $showPrivacyAlert) {
                Button("OK", role: .cancel) { }
              
            }
        }
        .padding([.horizontal, .bottom])
        .navigationTitle("Instafilter")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .confirmationDialog("Select a filter effect", isPresented: $showingFilterSheet, actions: {
            Button("Crystallize") { setFilter(CIFilter.crystallize()) }
            Button("Edges") { setFilter(CIFilter.edges()) }
            Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
            Button("Pixellate") { setFilter(CIFilter.pixellate()) }
            Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
            Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
            Button("Vignette") { setFilter(CIFilter.vignette()) }
            Button("Cancel", role: .cancel) { }
            
        })
        .onChange(of: inputImage) { _ in
            loadImage()
        }
        
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
     
        imageSaver.successHandler = {
            print("Success!")
        }

        imageSaver.errorHandler = {
            showPrivacyAlert = true
            print("Oops: \($0.localizedDescription)")
        }
        
       
        
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        //image = Image(uiImage: inputImage)
        let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
    }
    
    func applyProcessing() {
       // currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey) }
        
        //----
      
        //----
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct Instafilter_Previews: PreviewProvider {
    static var previews: some View {
        Instafilter()
    }
}
