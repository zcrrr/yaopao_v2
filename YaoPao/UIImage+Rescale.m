//
//  UIImage+Rescale.m
//  Trafficeye_new
//
//  Created by zc on 13-9-6.
//  Copyright (c) 2013年 张 驰. All rights reserved.
//

#import "UIImage+Rescale.h"

@implementation UIImage (Rescale)

- (UIImage *)rescaleImageToSize:(CGSize)size {
    UIImage* imagefixed = [self fixOrientation:self];
    CGRect crop_rect;
    if(imagefixed.size.width >= imagefixed.size.height){
        int offsize = self.size.width - self.size.height;
        crop_rect = CGRectMake(offsize/2+imagefixed.size.height*0.05, imagefixed.size.height*0.05, imagefixed.size.height*0.9, imagefixed.size.height*0.9);
    }else{
        int offsize = self.size.height - self.size.width;
        crop_rect = CGRectMake(imagefixed.size.width*0.05, offsize/2+imagefixed.size.width*0.05, imagefixed.size.width*0.9, imagefixed.size.width*0.9);
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect([imagefixed CGImage], crop_rect);
    UIImage *image_crop = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    [image_crop drawInRect:rect];
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    NSData* imageData = UIImageJPEGRepresentation(resImage, 0.2);
//    UIImage* image_compressed = [UIImage imageWithData:imageData];
    return resImage;
}
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
