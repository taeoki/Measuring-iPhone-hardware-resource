/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Charts

class ResultView: UIViewController {

  @IBOutlet weak var resultTextView: UITextView!
  
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBAction func randomButton(_ sender: UIButton) {
      let count = Int(arc4random_uniform(20) + 3)
      setChartValues(count)
    }
    
  override func viewDidLoad() {
        super.viewDidLoad()
    
      var resultData = UserDefaults.standard.object(forKey: "resultData") as! [String]
      var selectNumber = UserDefaults.standard.object(forKey: "selectNumber") as! Int
    
      resultTextView.text = resultData[selectNumber]
    
  
    setChartValues()

    }
  
  
  
  func setChartValues(_ count : Int = 20) {
    let values = (0..<count).map { (i) -> ChartDataEntry in
      let val = Double(arc4random_uniform(UInt32(count)) + 3)
      return ChartDataEntry(x: Double(i), y: val)
    }
    
    let set1 = LineChartDataSet(values: values, label: "cpu")
    let set2 = LineChartDataSet(values: values, label: "mem")
    
    let data = LineChartData(dataSets: [set1,set2])
   
    
    self.lineChartView.data = data
   
  }
  
  
  
  

  

}
