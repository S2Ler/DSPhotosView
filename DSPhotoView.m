
#import "DSPhotoView.h"

@interface DSPhotoView ()
@property (nonatomic, assign, getter=isZoomed) BOOL zoomed;
@property (nonatomic, strong) NSTimer *tapTimer;

//TODO: setup constraints
@property (weak, nonatomic) NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) NSLayoutConstraint *constraintBottom;

@property (nonatomic) CGFloat lastZoomScale;
@end

@implementation DSPhotoView

- (void)dealloc
{
  [[self imageView] removeObserver:self forKeyPath:@"image"];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  [self setTranslatesAutoresizingMaskIntoConstraints:NO];
  self.userInteractionEnabled = YES;
  self.clipsToBounds = YES;
  self.delegate = self;
  self.contentMode = UIViewContentModeScaleToFill;
  self.maximumZoomScale = 3.0;
  self.minimumZoomScale = 1;
  self.decelerationRate = .85;
  
  UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
  imageView.translatesAutoresizingMaskIntoConstraints = NO;
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  _imageView = imageView;
  [self addSubview:imageView];
  
  [[self imageView] addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
  
  NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:[self imageView]
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1
                                                                     constant:100];
  NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:[self imageView]
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:100];
  NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:[self imageView]
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:100];
  NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:[self imageView]
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:100];

  [self addConstraints:@[constraintLeft, constraintRight, constraintTop, constraintBottom]];
  
  [self setConstraintLeft:constraintLeft];
  [self setConstraintRight:constraintRight];
  [self setConstraintTop:constraintTop];
  [self setConstraintBottom:constraintBottom];
  
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if (context == nil) {
    [[self imageView] setAlpha:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      CATransition *transition = [CATransition animation];
      [transition setDuration:0.25];
      [transition setTimingFunction:
       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
      [transition setType:kCATransitionFade];
      
      [[self layer] addAnimation:transition forKey:nil];
      [[self imageView] setAlpha:1];
      [self updateZoom];
      [self updateConstraints];
    });
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

#pragma mark - Layout
- (void) updateConstraints {
  
  float imageWidth = self.imageView.image.size.width;
  float imageHeight = self.imageView.image.size.height;
  
  float viewWidth = self.superview.bounds.size.width;
  float viewHeight = self.superview.bounds.size.height;
  
  // center image if it is smaller than screen
  float hPadding = (viewWidth - self.zoomScale * imageWidth) / 2;
  if (hPadding < 0) hPadding = 0;
  
  float vPadding = (viewHeight - self.zoomScale * imageHeight) / 2;
  if (vPadding < 0) vPadding = 0;
  
  self.constraintLeft.constant = hPadding;
  self.constraintRight.constant = hPadding;
  
  self.constraintTop.constant = vPadding;
  self.constraintBottom.constant = vPadding;
  
  [super updateConstraints];
}

// Zoom to show as much image as possible unless image is smaller than screen
- (void) updateZoom {
  float minZoom = MIN(self.superview.bounds.size.width / self.imageView.image.size.width,
                      self.superview.bounds.size.height / self.imageView.image.size.height);
  
  if (minZoom > 1) minZoom = 1;
  
  self.minimumZoomScale = minZoom;
  
  // Force scrollViewDidZoom fire if zoom did not change
  if (minZoom == self.lastZoomScale) minZoom += 0.000001;
  
  self.lastZoomScale = self.zoomScale = minZoom;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return [self imageView];
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
  [self updateConstraints];
}

@end
