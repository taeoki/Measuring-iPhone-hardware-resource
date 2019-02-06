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

import Foundation

class SystemMemoryUsage {
  
}

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

