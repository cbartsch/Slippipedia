#include "utils.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

bool Utils::exploreToFile(const QString &filePath)
{
  NSString *nsPath = [NSString stringWithUTF8String:filePath.toUtf8().data()];
  NSURL *nsUrl = [NSURL fileURLWithPath:nsPath];

  [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[nsUrl]];

  return true; //TODO no return value from NSWorkspace
}
