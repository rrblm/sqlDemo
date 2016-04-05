//
//  TestProtocol.h
//  SqlStudy
//
//  Created by 谭亮 on 16/3/29.
//  Copyright © 2016年 GFENG. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MyProtocol <NSObject>

-(void)testProtocol;



@end

@interface TestProtocol : NSObject<MyProtocol>



@end
