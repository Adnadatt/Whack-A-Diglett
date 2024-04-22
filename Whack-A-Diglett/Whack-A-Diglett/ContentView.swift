//
//  ContentView.swift
//  Whack-A-Diglett
//
//  Created by Chen, Amanda M on 4/4/24.
//

import SwiftUI
import AVFAudio

struct mole: Identifiable, Equatable, Hashable {
    var id = UUID()
    var image: String
    var num: Int
    init(num: Int) {
        id = UUID()
        if (num == 0){
            image = "emptyHole"
        } else if num == 1 {
            image = "Diglett"
        } else {
            image = "Dugtrio"
        }
        
        self.num = num
        
    }
    init(){
        id = UUID()
        image = "emptyHole"
        num = 0
    }
}

struct ContentView: View {
    @State var timeRemaining = 10.0
    @State var maxTime = 10.0
    @State private var gameOn = false
    @State private var startGame = false
    @State private var playAgain = false

    @State private var clickedMole = false
    @State private var score = 0
    @State private var highScore = 0
    @State private var board: [[mole]] = [[mole(),mole(),mole()],[mole(),mole(num: 1),mole()],[mole(),mole(),mole()]]
    @State private var randomRow = 1
    @State private var randomColumn = 1
    @State private var randomPokemon = 0
    
    @State private var audioPlayer: AVAudioPlayer!
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack{
            Image("bgGrass")
                .resizable()
                .ignoresSafeArea()
                            
            VStack {
                if (gameOn == true) {
                    Text("Time Remaining: \(String(format: "%g", timeRemaining))")
                        .font(.title)
                        .onReceive(timer){_ in
                            if timeRemaining > 0 && clickedMole{
                                maxTime = maxTime * 5 / 6
                                timeRemaining = maxTime
                                clickedMole = false
                                board[randomRow][randomColumn].num = 0
                                board[randomRow][randomColumn].image = "emptyHole"
                                randomRow = Int.random(in: 0...2)
                                randomColumn = Int.random(in: 0...2)
                                randomPokemon = Int.random(in: 1...5)
                                board[randomRow][randomColumn].num = randomPokemon
                                if randomPokemon == 1 {
                                    board[randomRow][randomColumn].image = "Dugtrio"
                                } else {
                                    board[randomRow][randomColumn].image = "Diglett"
                                }
                            }
                            else if timeRemaining > 0 {
                                timeRemaining -= 0.01
                            }
                            else {
                                //if time runs out
                                playSound(soundName: "death")
                                if(score > highScore) {highScore = score}
                                
                                gameOn = false
                                playAgain = true
                            }
                        }
                    
                    Text("Score: \(score)")
                    
                    ForEach(board, id: \.self){ hitBox in
                        HStack{
                            ForEach(hitBox){ mole in
                                ZStack{
//                                    Rectangle()
//                                        .strokeBorder(.gray, lineWidth: 2)
//                                        .background(letter.color)
//                                    Image(mole.image)
//                                        .font(.title)
//                                        .padding(.horizontal)
//                                        //.fontWeight(.bold)
                                    
                                    if(mole.num == 0){
                                        Image(mole.image)
                                            .resizable()
                                    } else {
                                        Button {
                                            if randomPokemon == 1 {
                                                score += 3
                                            } else {
                                                score += 1
                                            }
                                            clickedMole = true
                                            playSound(soundName: "whack")
                                        } label: {
                                            Image(mole.image)
                                                .resizable()
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 100)
                    }

                }
                Spacer()
                
                if (startGame == false || playAgain == true) {
                    VStack{
                        Text("Professor Oak")
                            .foregroundColor(.black)
                        
                            .padding(.leading, 15)
                        Button {
                            gameOn = true
                            startGame = true
                            playAgain = false
                            score = 0
                            playSound(soundName: "startGame")
                            maxTime = 10.0
                            timeRemaining = 10.0
                        } label: {
                            Image("profoak")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100.0)
                        }
                        .padding(.leading, 15)
                        .padding(.bottom)
                        if(!playAgain) {
                            ZStack{
                                Rectangle()
                                    .fill(.white)
                                    .frame(width: 320, height: 30)
                                Text("CLICK PROFESSOR OAK TO START")
                                    .font(.title3)
                                    .padding(.all, 5.0)
                                    .border(Color(.black), width: 5)
                                    .frame(height: 10)
                            }
                        }
//                        else {
//                            ZStack{
//                                Rectangle()
//                                    .fill(.white)
//                                    .frame(width: 370, height: 30)
//
//                                Text("CLICK PROFESSOR OAK TO PLAY AGAIN")
//                                    .font(.title3)
//                                    .padding(.all, 5.0)
//                                    .border(Color(.black), width: 5)
//                                    .frame(height: 10)
//                            }
//                        }
                    }
                    .padding(.top, 600.0)
                    .padding(.bottom, 5.0)
                    
                }
            }
            .padding()
            
            if(playAgain){
                RoundedRectangle(cornerRadius: 30)
                    .fill(.red)
                    .frame(width: 350, height: 200)
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(width: 335, height: 185)
                
                
                VStack{
                    Text("Well Done!")
                        .font(.title)
                        .padding(.bottom)
                    
                    Text("Score: \(score)")
                    
                    Text("Highscore: \(highScore)")
                    
                    Button("Play Again?") {
                        playAgain = false
                        gameOn = true
                        timeRemaining = 10.0
                        maxTime = 10.0
                        score = 0
                    }
                    .tint(.black)
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                    
                }
            }

        }
    }
    
    func playSound(soundName: String){
        guard let soundFile = NSDataAsset(name: soundName) else {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
