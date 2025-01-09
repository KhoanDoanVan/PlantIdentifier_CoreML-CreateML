//
//  CameraView.swift
//  PlantIdentifier
//
//  Created by Đoàn Văn Khoan on 29/11/24.
//

import SwiftUI

struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    @Binding var isShowCamera: Bool
    
    let handleAction: (_ uiImage: UIImage) -> ()
    
    var body: some View {
        ZStack {
            if let uiImage = camera.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 300, height: 300)
            } else {
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(style: .init(lineWidth: 10))
                    .foregroundStyle(.black)
                    .frame(width: 300, height: 300)
                    .background(.clear)
            }
            
            VStack {
                if camera.isTaken {
                    HStack {
                        Spacer()
                        Button {
                            camera.reTakePicture()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .foregroundStyle(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 10)
                    }
                }
                
                Spacer()
                
                HStack {
                    if camera.isTaken {
                        Button {
                            
                            if let uiImage = camera.uiImage {
                                handleAction(uiImage)
                            }
                            
                            isShowCamera = false
                        } label: {
                            Text("Finished")
                                .font(.system(size: 24))
                                .bold()
                                .foregroundStyle(Color.red)
                        }
                    } else {
                        Button {
                            camera.takePicture()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 65, height: 65)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 75, height: 75)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            camera.Check()
        }
    }
}
