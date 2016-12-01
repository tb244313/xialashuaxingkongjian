//
//  WJPullDownToRefreshView.h
//  shuaxinkongjian
//
//  Created by apple on 16/11/25.
//  Copyright © 2016年 apple. All rights reserved.
//  自定义下刷刷新控件

#import <UIKit/UIKit.h>

@interface WJPullDownToRefreshView : UIView
@property (nonatomic, copy) void(^refreshingBlock)();

//结束刷新
-(void)endRefreshing;

@end
