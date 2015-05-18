#import "HFImageEditorViewController.h"
#import "HFImageEditorFrameView.h"

static const CGFloat kMaxUIImageSize = 1024;
static const CGFloat kPreviewImageSize = 120;
//static const CGFloat kDefaultCropWidth = 320;
//static const CGFloat kDefaultCropHeight = 320;
//static const CGFloat kBoundingBoxInset = 15;
static const NSTimeInterval kAnimationIntervalReset = 0.25;
static const NSTimeInterval kAnimationIntervalTransform = 0.2;

@interface HFImageEditorViewController ()
@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic,assign) CGRect cropRect;
@property (retain, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (retain, nonatomic) UIRotationGestureRecognizer *rotationRecognizer;
@property (retain, nonatomic) UIPinchGestureRecognizer *pinchRecognizer;
@property (retain, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic,retain)  UIView<HFImageEditorFrame> *frameView;


@property(nonatomic,assign) NSUInteger gestureCount;
@property(nonatomic,assign) CGPoint touchCenter;
@property(nonatomic,assign) CGPoint rotationCenter;
@property(nonatomic,assign) CGPoint scaleCenter;
@property(nonatomic,assign) CGFloat scale;
- (void)initialize;
@end



@implementation HFImageEditorViewController

@synthesize doneCallback = _doneCallback;
@synthesize sourceImage = _sourceImage;
@synthesize previewImage = _previewImage;
@synthesize cropSize = _cropSize;
@synthesize outputWidth = _outputWidth;
@synthesize frameView = _frameView;
@synthesize imageView = _imageView;
@synthesize panRecognizer = _panRecognizer;
@synthesize rotationRecognizer = _rotationRecognizer;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize pinchRecognizer = _pinchRecognizer;
@synthesize touchCenter = _touchCenter;
@synthesize rotationCenter = _rotationCenter;
@synthesize scaleCenter = _scaleCenter;
@synthesize scale = _scale;
@synthesize minimumScale = _minimumScale;
@synthesize maximumScale = _maximumScale;
@synthesize gestureCount = _gestureCount;

@dynamic panEnabled;
@dynamic rotateEnabled;
@dynamic scaleEnabled;
@dynamic tapToResetEnabled;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
		[self initialize];
    }
    return self;
}

- (id)init
{
	if (self = [super init]) {
		[self initialize];
	}
	return self;
}

- (void)initialize
{
	_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	_rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
	_pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
}

#pragma mark Properties

- (void)setCropSize:(CGSize)cropSize
{
    _cropSize = cropSize;
    [self updateCropRect];
}

- (CGSize)cropSize
{
    if(_cropSize.width == 0 || _cropSize.height == 0) {
        _cropSize = CGSizeMake(kFrame_Width, kFrame_Width);
    }
    return _cropSize;
}

- (UIImage *)previewImage
{
    if(_previewImage == nil && _sourceImage != nil) {
        if(self.sourceImage.size.height > kMaxUIImageSize || self.sourceImage.size.width > kMaxUIImageSize) {
            CGFloat aspect = self.sourceImage.size.height/self.sourceImage.size.width;
            CGSize size;
            if(aspect >= 1.0) { //square or portrait
                size = CGSizeMake(kPreviewImageSize,kPreviewImageSize*aspect);
            } else { // landscape
                size = CGSizeMake(kPreviewImageSize,kPreviewImageSize*aspect);
            }
            _previewImage = [self scaledImage:self.sourceImage  toSize:size withQuality:kCGInterpolationLow];
        } else {
            _previewImage = _sourceImage;
        }
    }
    return  _previewImage;
}

- (void)setSourceImage:(UIImage *)sourceImage
{
    if(sourceImage != _sourceImage) {
        _sourceImage = sourceImage;
        self.previewImage = nil;
    }
}


- (void)updateCropRect
{
    self.cropRect = CGRectMake((self.frameView.bounds.size.width-self.cropSize.width)/2,
                               (self.frameView.bounds.size.height-self.cropSize.height)/2,
                               self.cropSize.width, self.cropSize.height);
    
    self.frameView.cropRect = self.cropRect;
}


- (void)setPanEnabled:(BOOL)panEnabled
{
    self.panRecognizer.enabled = panEnabled;
}

- (BOOL)panEnabled
{
    return self.panRecognizer.enabled;
}

- (void)setScaleEnabled:(BOOL)scaleEnabled
{
    self.pinchRecognizer.enabled = scaleEnabled;
}

- (BOOL)scaleEnabled
{
    return self.pinchRecognizer.enabled;
}


- (void)setRotateEnabled:(BOOL)rotateEnabled
{
    self.rotationRecognizer.enabled = rotateEnabled;
}

- (BOOL)rotateEnabled
{
    return self.rotationRecognizer.enabled;
}

- (void)setTapToResetEnabled:(BOOL)tapToResetEnabled
{
    self.tapRecognizer.enabled = tapToResetEnabled;
}

- (BOOL)tapToResetEnabled
{
    return self.tapToResetEnabled;
}

#pragma mark Public methods
-(void)reset:(BOOL)animated
{
    CGFloat aspect = self.sourceImage.size.height/self.sourceImage.size.width;
    CGFloat w = CGRectGetWidth(self.cropRect);
    CGFloat h = aspect * w;
    self.scale = 1;
    
    void (^doReset)(void) = ^{
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = CGRectMake(CGRectGetMidX(self.cropRect) - w/2, CGRectGetMidY(self.cropRect) - h/2,w,h);
    };
    if(animated) {
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:kAnimationIntervalReset animations:doReset completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
    } else {
        doReset();
    }
}

#pragma mark View Lifecycle

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor blackColor];
	HFImageEditorFrameView* hf = [[HFImageEditorFrameView alloc] initWithFrame:self.view.bounds];
	self.frameView = hf;
	[self.view addSubview:self.frameView];
	
	UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn setFrame:CGRectMake(8, 7, 60, 30)];
	[btn setTintColor:[UIColor colorWithRed:0 green:128/255.0f blue:1.0f alpha:1.0f]];
	[btn setTitle:@"取消" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *barbuttonitem1 = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	UIBarButtonItem *barbuttonitem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn setFrame:CGRectMake(self.view.bounds.size.width - 60 - 8, 7, 60, 30)];
	[btn setTitle:@"保存" forState:UIControlStateNormal];
	[btn setTintColor:[UIColor colorWithRed:0 green:128/255.0f blue:1.0f alpha:1.0f]];
	[btn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *barbuttonitem3 = [[UIBarButtonItem alloc] initWithCustomView:btn];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 416.0, kFrame_Width, 44.0)];
	toolbar.autoresizesSubviews = YES;
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	toolbar.barStyle = UIBarStyleBlackOpaque;
	toolbar.clipsToBounds = NO;
	toolbar.contentMode = UIViewContentModeScaleToFill;
	toolbar.frame = CGRectMake(0.0, self.view.bounds.size.height - 44.0, kFrame_Width, 44.0);
	[toolbar setItems:[NSArray arrayWithObjects:barbuttonitem1, barbuttonitem2, barbuttonitem3, nil]];
	
	[self.view addSubview:toolbar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateCropRect];
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.view insertSubview:imageView belowSubview:self.frameView];
    self.imageView = imageView;
    [self reset:NO];
    
    [self.view setMultipleTouchEnabled:YES];

    self.panRecognizer.cancelsTouchesInView = NO;
    self.panRecognizer.delegate = self;
    [self.frameView addGestureRecognizer:self.panRecognizer];
    self.rotationRecognizer.cancelsTouchesInView = NO;
    self.rotationRecognizer.delegate = self;
    [self.frameView addGestureRecognizer:self.rotationRecognizer];
    self.pinchRecognizer.cancelsTouchesInView = NO;
    self.pinchRecognizer.delegate = self;
    [self.frameView addGestureRecognizer:self.pinchRecognizer];
    self.tapRecognizer.numberOfTapsRequired = 2;
    [self.frameView addGestureRecognizer:self.tapRecognizer];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setFrameView:nil];
    [self setImageView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    self.imageView.image = self.previewImage;
    
    if(self.previewImage != self.sourceImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGImageRef hiresCGImage = NULL;
            CGFloat aspect = self.sourceImage.size.height/self.sourceImage.size.width;
            CGSize size;
            if(aspect >= 1.0) { //square or portrait
                size = CGSizeMake(kMaxUIImageSize*aspect,kMaxUIImageSize);
            } else { // landscape
                size = CGSizeMake(kMaxUIImageSize,kMaxUIImageSize*aspect);
            }
            hiresCGImage = [self newScaledImage:self.sourceImage.CGImage withOrientation:self.sourceImage.imageOrientation toSize:size withQuality:kCGInterpolationDefault];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = [UIImage imageWithCGImage:hiresCGImage scale:1.0 orientation:UIImageOrientationUp];
                CGImageRelease(hiresCGImage);
            });
        });
    }
}

#pragma mark Actions

- (IBAction)resetAction:(id)sender
{
    [self reset:NO];
}

- (IBAction)resetAnimatedAction:(id)sender
{
    [self reset:YES];
}


- (void)doneAction:(id)sender
{
    self.view.userInteractionEnabled = NO;
    [self startTransformHook];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef resultRef = [self newTransformedImage:self.imageView.transform
                                        sourceImage:self.sourceImage.CGImage
                                         sourceSize:self.sourceImage.size
                                  sourceOrientation:self.sourceImage.imageOrientation
                                        outputWidth:self.outputWidth ? self.outputWidth : self.sourceImage.size.width
                                            cropSize:self.cropSize
                                    imageViewSize:self.imageView.bounds.size];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *transform =  [UIImage imageWithCGImage:resultRef scale:1.0 orientation:UIImageOrientationUp];
            CGImageRelease(resultRef);
            self.view.userInteractionEnabled = YES;
            if(self.doneCallback) {
                self.doneCallback(transform, NO);
            }
            [self endTransformHook];
        });
    });
}


- (IBAction)cancelAction:(id)sender
{
    if(self.doneCallback) {
        self.doneCallback(nil, YES);
    }
}

#pragma mark Touches

- (void)handleTouches:(NSSet*)touches
{
    self.touchCenter = CGPointZero;
    if(touches.count < 2) return;
    
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = (UITouch*)obj;
        CGPoint touchLocation = [touch locationInView:self.imageView];
        self.touchCenter = CGPointMake(self.touchCenter.x + touchLocation.x, self.touchCenter.y +touchLocation.y);
    }];
    self.touchCenter = CGPointMake(self.touchCenter.x/touches.count, self.touchCenter.y/touches.count);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:[event allTouches]];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   [self handleTouches:[event allTouches]];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   [self handleTouches:[event allTouches]];
}

#pragma mark Gestures

- (BOOL)handleGestureState:(UIGestureRecognizerState)state
{
    BOOL handle = YES;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.gestureCount++;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.gestureCount--;
            handle = NO;
            if(self.gestureCount == 0) {
                CGFloat scale = self.scale;
                if(self.minimumScale != 0 && self.scale < self.minimumScale) {
                    scale = self.minimumScale;
                } else if(self.maximumScale != 0 && self.scale > self.maximumScale) {
                    scale = self.maximumScale;
                }
                if(scale != self.scale) {
                    CGFloat deltaX = self.scaleCenter.x-self.imageView.bounds.size.width/2.0;
                    CGFloat deltaY = self.scaleCenter.y-self.imageView.bounds.size.height/2.0;
                    
                    CGAffineTransform transform =  CGAffineTransformTranslate(self.imageView.transform, deltaX, deltaY);
                    transform = CGAffineTransformScale(transform, scale/self.scale , scale/self.scale);
                    transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
                    self.view.userInteractionEnabled = NO;
                    [UIView animateWithDuration:kAnimationIntervalTransform delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.imageView.transform = transform;            
                    } completion:^(BOOL finished) {
                        self.view.userInteractionEnabled = YES;
                        self.scale = scale;
                    }];
                    
                }
            }
        } break;
        default:
            break;
    }
    return handle;
}


- (IBAction)handlePan:(UIPanGestureRecognizer*)recognizer
{
        if([self handleGestureState:recognizer.state]) {
        CGPoint translation = [recognizer translationInView:self.imageView];
        CGAffineTransform transform = CGAffineTransformTranslate( self.imageView.transform, translation.x, translation.y);
        self.imageView.transform = transform;

        [recognizer setTranslation:CGPointMake(0, 0) inView:self.frameView];
    }

}

- (IBAction)handleRotation:(UIRotationGestureRecognizer*)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        if(recognizer.state == UIGestureRecognizerStateBegan){
            self.rotationCenter = self.touchCenter;
        } 
        CGFloat deltaX = self.rotationCenter.x-self.imageView.bounds.size.width/2;
        CGFloat deltaY = self.rotationCenter.y-self.imageView.bounds.size.height/2;

        CGAffineTransform transform =  CGAffineTransformTranslate(self.imageView.transform,deltaX,deltaY);
        transform = CGAffineTransformRotate(transform, recognizer.rotation);
        transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
        self.imageView.transform = transform;

        recognizer.rotation = 0;
    }

}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if([self handleGestureState:recognizer.state]) {
        if(recognizer.state == UIGestureRecognizerStateBegan){
            self.scaleCenter = self.touchCenter;
        } 
        CGFloat deltaX = self.scaleCenter.x-self.imageView.bounds.size.width/2.0;
        CGFloat deltaY = self.scaleCenter.y-self.imageView.bounds.size.height/2.0;

        CGAffineTransform transform =  CGAffineTransformTranslate(self.imageView.transform, deltaX, deltaY);
        transform = CGAffineTransformScale(transform, recognizer.scale, recognizer.scale);
        transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
        self.scale *= recognizer.scale;
        self.imageView.transform = transform;

        recognizer.scale = 1;
    }
}

- (IBAction)handleTap:(UITapGestureRecognizer *)recogniser {
    [self reset:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

# pragma mark Image Transformation


- (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGImageRef cgImage  = [self newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:size withQuality:quality];
    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}


- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8, //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                     sourceImage:(CGImageRef)sourceImage
                    sourceSize:(CGSize)sourceSize
           sourceOrientation:(UIImageOrientation)sourceOrientation
                 outputWidth:(CGFloat)outputWidth
                    cropSize:(CGSize)cropSize
               imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [self newScaledImage:sourceImage
                         withOrientation:sourceOrientation
                                  toSize:sourceSize
                             withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    CGContextSetFillColorWithColor(context,  [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width/cropSize.width,
                                                            outputSize.height/cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height/2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       ,source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}

#pragma mark Subclass Hooks

- (void)startTransformHook
{
}

- (void)endTransformHook
{
}



@end
