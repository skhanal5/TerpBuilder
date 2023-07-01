//
//  ReviewView.swift
//  Terp_Builder
//
//  Created by caleb on 4/25/23.
//

import SwiftUI
import Firebase

struct ReviewView: View {
    @State private var reviewText:String = ""
    @State private var course:String = ""
    @State private var professor:String = ""
    @State private var rating = 3
    @State private var submitted:Bool = false
    
    var body: some View {
        VStack {
            Text("Review")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(.white)
                .fontWeight(.bold)
            
            VStack {
                Spacer()
                VStack {

                    TextField(
                        "Course Number",
                        text: $course
                        
                    ).padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding()
                    
                    TextField(
                        "Proffesor",
                        text: $professor
                        
                    ).padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding()
                    
                    ratingView(rating: $rating)
                    
                    TextEditor(text: $reviewText)
                        .padding(8)
                        .frame(height: 200)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding()
                    
                    Button("Submit Review",action: {upload()})
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
                Spacer()
            }.padding()
                .background(CustomColor.NEUTRAL)
            
        }.background(Color.accentColor)
            .alert(isPresented: $submitted) {
                Alert(title: Text("Review Submitted"),
                      message: Text("Thank you for taking the time to review a course!"),
                      dismissButton: .default(Text("Ok")))
            }
    }
    
    
    func upload() {
        
        if (!reviewText.isEmpty &&
            !course.isEmpty) {
            let root = Database.database().reference()
            root.child("courses").child(course.uppercased()).childByAutoId()
                .setValue(["professor": professor, "review": reviewText, "rating": String(rating)])
            submitted = true
            reviewText = ""
            course = ""
            rating = 3
            professor = ""
        }
    }

}


struct ratingView: View {
    @Binding var rating: Int
    
    var maxRating: Int = 5
    
    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { num in
                Image(systemName: num <= rating ? "star.fill" : "star")
                    .font(.system(size: 40))
                    .foregroundColor(num <= rating ? .yellow : .gray)
                    .onTapGesture {
                        rating = num
                    }
            }
        }
    }
    
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView()
    }
}
