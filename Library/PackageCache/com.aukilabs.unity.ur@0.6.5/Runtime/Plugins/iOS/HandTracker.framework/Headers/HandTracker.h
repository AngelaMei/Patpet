// Copyright (c) Auki Labs 2022

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class HTLandmark;
@class CameraIntrinsics;
@class HandTracker;

extern const int LandmarksCount;
extern const int TranslationsCount;

@protocol TrackerDelegate <NSObject>

- (void)handTracker: (HandTracker*)handTracker didOutput3DLandmarks:(NSArray<NSArray<HTLandmark *> *> *)landmarks
        didOutputTrans:(NSArray<NSArray<HTLandmark *> *> *)trans
        didOutputHandness: (NSArray<NSNumber *> *)isRightHands 
        didOutputScore: (NSArray<NSNumber *> *)scores
        didOutputCount: (int)count;

@end

@interface HandTracker : NSObject

- (instancetype)init;

- (void)startGraphWithNumHands: (int)numHands
        withFilteringEnabled: (bool)enableFiltering
        withMinCutOff: (int)minCutOff
        withBeta: (int)beta;

- (void)stopGraph;

- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer
        withCameraIntrinsics:(CameraIntrinsics *)instrinsics;

@property (strong, atomic) id<TrackerDelegate> delegate;
@end

@interface HTLandmark: NSObject
@property(nonatomic) float x;
@property(nonatomic) float y;
@property(nonatomic) float z;
@end

@interface CameraIntrinsics: NSObject
- (instancetype)initWithFx:(float)fx Fy:(float)fy Ox:(float)Ox Oy:(float)Oy;
@property(nonatomic) float fx;
@property(nonatomic) float fy;
@property(nonatomic) float ox;
@property(nonatomic) float oy;
@end
