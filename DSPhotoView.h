
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol DSPhotoViewDelegate;

@interface DSPhotoView : UIScrollView <UIScrollViewDelegate> 

@property (nonatomic, weak) id<DSPhotoViewDelegate> photoDelegate;

@property (nonatomic, weak) UIImageView *imageView;

//Call on rotation
- (void)updateZoom;

@end



@protocol DSPhotoViewDelegate

// indicates single touch and allows controller repsond and go toggle fullscreen
- (void)didTapPhotoView:(DSPhotoView*)photoView;

@end

