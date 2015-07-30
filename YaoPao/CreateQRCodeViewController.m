//
//  CreateQRCodeViewController.m
//  QRCodeDemo
//
//  Created by Kelven on 15/6/25.
//  Copyright (c) 2015年 Kelven. All rights reserved.
//

#import "CreateQRCodeViewController.h"
#import "QRCodeGenerator.h"
@interface CreateQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;
- (IBAction)back:(id)sender;

@end

@implementation CreateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* uidstr = [NSString stringWithFormat:@"yaopao-addFriend-id:%@",[kApp.userInfoDic objectForKey:@"uid"]];
    NSData* originData = [uidstr dataUsingEncoding:NSASCIIStringEncoding];
    NSString* encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    self.QRCodeImageView.image = [QRCodeGenerator qrImageForString:encodeResult imageSize:self.QRCodeImageView.bounds.size.width];
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)button_clicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
