//
//  ContentView.swift
//  Music ++
//
//  Created by Yaseen Mallick on 06/05/20.
//  Copyright © 2020 Yaseen Mallick. All rights reserved.
//

import SwiftUI
import AVKit
import MediaPlayer
import UIKit


struct ContentView: View {
    var body: some View {
        NavigationView{
            ZStack {
                
                Color.offWhite
                
               // LinearGradient(Color.darkStart, Color.darkEnd)
                
                MusicPlayer()
            }
            .edgesIgnoringSafeArea(.all)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct MusicPlayer : View {
    
    @State var data : Data = .init(count: 0)
    @State var title = ""
    @State var player : AVAudioPlayer!
    @State var playing = false
    @State var width : CGFloat = 0
    @State var songs = ["Juice_WRLD_-_Righteous_(Official_Video)","YNW_Melly_feat._Juice_WRLD_-_Suicidal_Remix_[Official_Audio]", "Ty_Dolla_$ign_-_Or_Nah_ft._The_Weeknd__Wiz_Khalifa_&_DJ_Mustard", "Future__Juice_WRLD_-_Fine_China_(Audio)", "JuiceWRLD_Cigarettes_(Official_Music_Audio)", "Big_Sean_-_Single_Again_(Official_Audio)", "Juice_WRLD_-_Fast"]
    @State var current = 0
    @State var finish = false
    @State var del = AVdelegate()
    @State var volume : Double = 0.80
    
    
    
    var body : some View{
        
        VStack(spacing: 20){
            
            Image(uiImage: self.data.count == 0 ? UIImage(named: "itunes")! : UIImage(data: self.data)!)
                .resizable()
                .frame(width: 300.0, height: 300.0, alignment: .center)
                .scaledToFit()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                
                .rotationEffect(.degrees(self.playing ? 360.0 : 0.0))
                .animation(Animation.linear(duration: 10)
                    .repeatCount( self.playing ? 50 : 0 , autoreverses: false))
                
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 8, y: 8)
                .shadow(color: Color.white.opacity(1.0), radius: 10, x: -10, y: -10)
            
            
            
            
            Text(self.title).font(.title).padding(.top)
            
            ZStack(alignment: .leading) {
                
                Capsule().fill(Color.black.opacity(0.08)).frame(height: 8)
                
                Capsule().fill(Color.red.opacity(0.5)).frame(width: self.width, height: 8)
                    .gesture(DragGesture()
                        .onChanged({ (value) in
                            
                            let x = value.location.x
                            
                            self.width = x
                            
                        }).onEnded({ (value) in
                            
                            let x = value.location.x
                            
                            let screen = UIScreen.main.bounds.width - 30
                            
                            let percent = x / screen
                            
                            self.player.currentTime = Double(percent) * self.player.duration
                        }))
            }
            .padding(.top)
            
            HStack(spacing: UIScreen.main.bounds.width / 5 - 55){
                
                Button(action: {
                    
                    if self.current > 0{
                        
                        self.current -= 1
                        
                        self.ChangeSongs()
                    }
                    
                }) {
                    Image(systemName: "backward.fill").font(.title)
                }
                .buttonStyle(SimpleButtonStyle())
                
                Button(action: {
                    
                    self.player.currentTime -= 15
                    
                }) {
                    Image(systemName: "gobackward.15").font(.title)
                }
                .buttonStyle(SimpleButtonStyle())
                
                Button(action: {
                    if self.player.isPlaying{
                        
                        self.player.pause()
                        self.playing = false
                        
                    }
                    else{
                        if self.finish{
                            
                            self.player.currentTime = 0
                            self.width = 0
                            self.finish = false
                            
                        }
                        self.player.play()
                        self.playing = true
                    }
                    
                }) {
                    
                    Image(systemName: self.playing && !self.finish ? "pause.fill" : "play.fill").font(.title)
                }
                .buttonStyle(SimpleButtonStyle())
                
                Button(action: {
                    
                    let increase = self.player.currentTime + 15
                    
                    if increase < self.player.duration{
                        
                        self.player.currentTime = increase
                    }
                    
                }) {
                    
                    Image(systemName: "goforward.15").font(.title)
                    
                }
                .buttonStyle(SimpleButtonStyle())
                
                Button(action: {
                    
                    if self.songs.count - 1 != self.current{
                        
                        self.current += 1
                        
                        self.ChangeSongs()
                        
                    }
                    
                }) {
                    
                    Image(systemName: "forward.fill").font(.title)
                }
                .buttonStyle(SimpleButtonStyle())
                
            }.padding(.top,25)
                .foregroundColor(.darkEnd)
                
                
                .padding()
                .foregroundColor(.darkEnd)
                .accentColor(.gray)
            
            
        }.padding()
            .onAppear {
                
                let url = Bundle.main.path(forResource: self.songs[self.current], ofType: "mp3")
                
                self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
                
                self.player.delegate = self.del
                
                self.player.prepareToPlay()
                self.getData()
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                    
                    if self.player.isPlaying{
                        
                        let screen = UIScreen.main.bounds.width - 30
                        
                        let value = self.player.currentTime / self.player.duration
                        
                        self.width = screen * CGFloat(value)
                    }
                }
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
                    
                    self.finish = true
                }
        }
    }
    
    func getData(){
        
        
        let asset = AVAsset(url: self.player.url!)
        
        for i in asset.commonMetadata{
            
            if i.commonKey?.rawValue == "artwork"{
                
                let data = i.value as! Data
                self.data = data
            }
            
            if i.commonKey?.rawValue == "title"{
                
                let title = i.value as! String
                self.title = title
            }
        }
    }
    
    func ChangeSongs(){
        
        let url = Bundle.main.path(forResource: self.songs[self.current], ofType: "mp3")
        
        self.player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
        
        self.player.delegate = self.del
        
        self.data = .init(count: 0)
        
        self.title = ""
        
        self.player.prepareToPlay()
        self.getData()
        
        self.playing = true
        
        self.finish = false
        
        self.width = 0
        
        self.player.play()
        
    }
}


class AVdelegate : NSObject,AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}
