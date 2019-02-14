/// Copyright (c) 2018 Razeware LLC
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


class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // Data model: These strings will be the data for the table view cells
  
 
  
  // cell reuse id (cells that scroll out of view can be reused)
  let cellReuseIdentifier = "cell"
  
  // don't forget to hook this up from the storyboard
  @IBOutlet var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Register the table view cell class and its reuse id
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    
    // (optional) include this line if you want to remove the extra empty cell divider lines
    // self.tableView.tableFooterView = UIView()
    
    // This view controller itself will provide the delegate methods and row data for the table view.
    tableView.delegate = self
    tableView.dataSource = self
    
    let notificationNme = NSNotification.Name("NotificationIdf")
    NotificationCenter.default.addObserver(self, selector: #selector(ResultViewController.relodaTableview), name: notificationNme, object: nil)
  }
  
  var resultData = [String]()
  
  // number of rows in table view
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    resultData = UserDefaults.standard.object(forKey: "resultData") as? [String] ?? [String]()
    
    //return self.animals.count
    return resultData.count
  }
  
  // create a cell for each table view row
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // create a new cell if needed or reuse an old one
    let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
    
    var resultData = [String]()

    resultData = UserDefaults.standard.object(forKey: "resultData") as? [String] ?? [String]()
    
    // set the text from the data model
    cell.textLabel?.text = resultData[indexPath.row]
    
    return cell
  }
  
  // method to run when table view cell is tapped
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //print("You tapped cell number \(indexPath.row).")
    
    var resultData = [String]()
    
    resultData = UserDefaults.standard.object(forKey: "resultData") as? [String] ?? [String]()
    
    print(resultData[indexPath.row])
    
    UserDefaults.standard.set(indexPath.row, forKey: "selectNumber")
    
    self.performSegue(withIdentifier: "ToResult", sender: self)
  }
  
  @objc func relodaTableview() {
    self.tableView.reloadData()
  }
}


  
  
  /*
  @IBAction func testButton(_ sender: Any) {
      var resultData = UserDefaults.standard.object(forKey: "resultData") as? [String] ?? [String]()
    
    print("0: \n"+resultData[0])
  }
  */





