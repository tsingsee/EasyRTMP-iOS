//
//  ViewController.h
//  EasyCapture
//
//  Created by lyy on 9/7/18.
//  Copyright © 2018 lyy. All rights reserved.
//

#import "BaseViewController.h"
#import "CameraEncoder.h"

@interface PushViewController : BaseViewController {
    CameraEncoder *encoder;
}

- (instancetype) initWithStoryboard;

@end
