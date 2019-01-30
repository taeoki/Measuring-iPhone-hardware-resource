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
import AVFoundation

class AudioViewController: UIViewController {
  
  private var count = 0
  
  @IBOutlet var songLabel: UILabel!
  @IBOutlet var timeLabel: UILabel!
  lazy var player: AVQueuePlayer = self.makePlayer()
  
  private lazy var songs: [AVPlayerItem] = {
    let songNames = ["FeelinGood", "IronBacon", "WhatYouWant","FeelinGood", "IronBacon", "WhatYouWant","FeelinGood", "IronBacon", "WhatYouWant"]
    return songNames.map {
      let url = Bundle.main.url(forResource: $0, withExtension: "mp3")!
      return AVPlayerItem(url: url)
    }
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try AVAudioSession.sharedInstance().setCategory(
        AVAudioSession.Category.playAndRecord,
        mode: .default,
        options: [])
    } catch {
      print("Failed to set audio session category.  Error: \(error)")
    }
    
    player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 100, timescale: 100), queue: DispatchQueue.main) { [weak self] time in
      guard let self = self else { return }
      let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
      
      if UIApplication.shared.applicationState == .active {
        self.timeLabel.text = timeString
      }
      else {
        self.count = self.count + 1
        print("\(self.count): free-\(self.getFreeMemory()) / active-\(self.getActiveMemory()) / in-\(self.getInactiveMemory()) /cpu :\(self.cpuUsage())")
      }
    }
  }
  
  private func makePlayer() -> AVQueuePlayer {
    let player = AVQueuePlayer(items: songs)
    player.actionAtItemEnd = .advance
    player.addObserver(self, forKeyPath: "currentItem", options: [.new, .initial] , context: nil)
    return player
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "currentItem",
      let player = object as? AVPlayer,
      let currentItem = player.currentItem?.asset as? AVURLAsset {
      songLabel.text = currentItem.url.lastPathComponent
    }
  }
  
  @IBAction func playPauseAction(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    if sender.isSelected {
      player.play()
    } else {
      player.pause()
      self.count = 0
    }
  }
  
  
  //MARK:- 내가 추가한 함수
  
  //MARK:- 가상 메모리 페이지 크기 가져오기
  //- returns: 가상 메모리 페이지 크기 */
  fileprivate func getVMPageSize() -> UInt
  {
    var pageSize: vm_size_t = 0
    
    let result = withUnsafeMutablePointer(to: &pageSize) { (size) -> kern_return_t in host_page_size(mach_host_self(), size) }
    
    guard result == KERN_SUCCESS else { return 0 }
    
    return UInt(pageSize)
    
  }
  /** 가상 메모리 데이터 가져오기 - returns: 가상 메모리 데이터 구조체 */
  
  fileprivate func getVMStatistics() -> vm_statistics
  {
    var vmstat = vm_statistics()
    var count = UInt32(MemoryLayout<vm_statistics>.size / MemoryLayout<integer_t>.size)
    
    let result = withUnsafeMutablePointer(to: &vmstat) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        return host_statistics(mach_host_self(), HOST_VM_INFO, host_info_t($0), &count)
        
      }
      
    }
    
    guard result == KERN_SUCCESS else {
      
      return vm_statistics()
      
    }
    return vmstat
    
  }
  
  /** 사용 가능한 메모리 가져오기 - returns: 사용가능한 메모리 */
  func getFreeMemory() -> UInt
  {
    return UInt(getVMStatistics().free_count) * getVMPageSize() / ( 1024*1024 )
    
  }
  
  func getActiveMemory() -> UInt
  {
    return UInt(getVMStatistics().active_count) * getVMPageSize() / ( 1024*1024 )
  }
  
  func getInactiveMemory() -> UInt
  {
    return UInt(getVMStatistics().inactive_count) * getVMPageSize() / ( 1024*1024 )
  }
  func getTotalMemory() ->UInt64
  {
    let total = ProcessInfo.processInfo.physicalMemory
    return total / (1_024*1_024)
  }
  
  
  
  //--------
  
   func cpuUsage() -> Double {
    var kr: kern_return_t
    var task_info_count: mach_msg_type_number_t
    
    task_info_count = mach_msg_type_number_t(TASK_INFO_MAX)
    var tinfo = [integer_t](repeating: 0, count: Int(task_info_count))
    
    kr = task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), &tinfo, &task_info_count)
    if kr != KERN_SUCCESS {
      return -1
    }
    
    var thread_list: thread_act_array_t? = UnsafeMutablePointer(mutating: [thread_act_t]())
    var thread_count: mach_msg_type_number_t = 0
    defer {
      if let thread_list = thread_list {
        vm_deallocate(mach_task_self_, vm_address_t(UnsafePointer(thread_list).pointee), vm_size_t(thread_count))
      }
    }
    
    kr = task_threads(mach_task_self_, &thread_list, &thread_count)
    
    if kr != KERN_SUCCESS {
      return -1
    }
    
    var tot_cpu: Double = 0
    
    if let thread_list = thread_list {
      
      for j in 0 ..< Int(thread_count) {
        var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
        var thinfo = [integer_t](repeating: 0, count: Int(thread_info_count))
        kr = thread_info(thread_list[j], thread_flavor_t(THREAD_BASIC_INFO),
                         &thinfo, &thread_info_count)
        if kr != KERN_SUCCESS {
          return -1
        }
        
        let threadBasicInfo = convertThreadInfoToThreadBasicInfo(thinfo)
        
        if threadBasicInfo.flags != TH_FLAGS_IDLE {
          tot_cpu += (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
        }
      } // for each thread
    }
    
    return tot_cpu
  }
  
   func convertThreadInfoToThreadBasicInfo(_ threadInfo: [integer_t]) -> thread_basic_info {
    var result = thread_basic_info()
    
    result.user_time = time_value_t(seconds: threadInfo[0], microseconds: threadInfo[1])
    result.system_time = time_value_t(seconds: threadInfo[2], microseconds: threadInfo[3])
    result.cpu_usage = threadInfo[4]
    result.policy = threadInfo[5]
    result.run_state = threadInfo[6]
    result.flags = threadInfo[7]
    result.suspend_count = threadInfo[8]
    result.sleep_time = threadInfo[9]
    
    return result
  }
  
  
  
  
}
