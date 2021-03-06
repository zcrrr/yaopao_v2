//
//  ChatGroupViewController.h
//  YaoPao
//
//  Created by 张驰 on 15/4/18.
//  Copyright (c) 2015年 张 驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "CNNetworkHandler.h"

@interface ChatGroupViewController : UIViewController<memberLocationsDelegate,MAMapViewDelegate,groupMemberDelegate,enableMyLocationInGroupDelegate>

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;
- (void)reloadData;
@property (strong, nonatomic) NSString* from;
@property (strong, nonatomic) NSString* groupname;
@property (strong, nonatomic) NSTimer* timer_update;
@property (nonatomic, strong) NSMutableArray* annoArray;
@property (strong, nonatomic) NSMutableArray* locations;
@property (assign, nonatomic) BOOL isSetRegion;
@property (strong, nonatomic) NSMutableDictionary* groupMemberDic;

@property (assign, nonatomic) int selectTab;
@property (strong, nonatomic) UIButton * button_myGroup;
@property (strong, nonatomic) UIButton * button_otherGroup;
@property (strong, nonatomic) UIView* view_line_select1;
@property (strong, nonatomic) UIView* view_line_select2;
@property (nonatomic, strong) MAMapView *mapView;
@property (assign, nonatomic) BOOL isFromRunning;
@property (nonatomic, strong) UIView* mapContainer;
@property (nonatomic, strong) UISwitch* switchButton;
@property (nonatomic, assign) BOOL isRequestingLocation;
@property (nonatomic, strong) MAPointAnnotation* annotation_me;
@property (assign, nonatomic) BOOL isOwner;

@end
