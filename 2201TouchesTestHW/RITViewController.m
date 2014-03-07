//
//  RITViewController.m
//  2201TouchesTestHW
//
//  Created by Pronin Alexander on 07.03.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITViewController.h"

@interface RITViewController ()

@property (strong, nonatomic) UIView* chessboard;
@property (strong, nonatomic) UIView* whiteBox;
@property (assign, nonatomic) NSUInteger cellCount;
@property (assign, nonatomic) NSUInteger cellSize;
@property (assign, nonatomic) NSUInteger fieldSize;
@property (strong, nonatomic) NSMutableArray* cells;
@property (strong, nonatomic) NSMutableArray* checkers;

@property (weak, nonatomic) UIView* draggingView;
@property (assign, nonatomic) CGPoint touchOffset;


@end

@implementation RITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeProperties];
    
    [self drawChessboard];
    
    [self drawCheckers];
    
    //[self freeCells];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self shuffleCheckers];
    
}

#pragma mark - Helper methods

- (void) initializeProperties {
    
    self.cellCount              = 8;
    NSUInteger borderOffset     = 20;
    NSUInteger screenMin        = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    // calculate cell size and field size
    self.cellSize               = (screenMin - borderOffset * 2 - 4) / self.cellCount;
    self.fieldSize              = self.cellSize * self.cellCount + 4;
    
    self.cells                  = [NSMutableArray array];
    self.checkers               = [NSMutableArray array];
}

- (void) drawChessboard {
    // set initial coordinates
    CGRect rect;
    
    // set border (black box)
    rect = CGRectMake(0, 0, self.fieldSize, self.fieldSize);
    self.chessboard = [[UIView alloc] initWithFrame:rect];
    self.chessboard.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    self.chessboard.backgroundColor = [UIColor blackColor];
    self.chessboard.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:self.chessboard];
    
    // set white box
    rect                        = CGRectMake(
                                             1,
                                             1,
                                             CGRectGetWidth(rect) - 2,
                                             CGRectGetWidth(rect) - 2
                                             );
    
    self.whiteBox            = [[UIView alloc] initWithFrame:rect];
    self.whiteBox.backgroundColor    = [UIColor whiteColor];
    [self.chessboard addSubview:self.whiteBox];
    
    // draw cells
    UIView *view =  nil;
    NSUInteger x = 0;
    NSUInteger y = 0;
    y = 1;
    for (int i = 0; i < self.cellCount; i++) {
        
        x = self.cellSize * (i % 2) + 1;
        
        for (int j = 0; j < self.cellCount / 2; j++) {
            
            rect                    = CGRectMake(x, y, self.cellSize, self.cellSize);
            view                    = [[UIView alloc] initWithFrame:rect];
            view.backgroundColor    = [UIColor blackColor];
            __weak UIView* weakView = view;
            [self.cells addObject:weakView];
            [self.whiteBox addSubview:view];
            
            x+= self.cellSize * 2;
        }
        
        y+= self.cellSize;
    }
}

- (void) createTheCheckerWithColor:(UIColor*) color andSize:(NSUInteger) size onPoint:(CGPoint) point {
    CGRect rect             = CGRectMake(0, 0, size, size);
    UIView* checker         = [[UIView alloc] initWithFrame:rect];
    checker.backgroundColor = color;
    checker.center          = point;
    checker.layer.cornerRadius = size / 2;
    checker.layer.masksToBounds = YES;
    
    /*
    checker.layer.shadowOffset = CGSizeMake(3, 0);
    checker.layer.shadowColor = [[UIColor yellowColor] CGColor];
    checker.layer.shadowRadius = 5;
    checker.layer.shadowOpacity = .25;
    */
    
    __weak UIView* weakView = checker;
    [self.checkers addObject:weakView];
    [self.whiteBox addSubview:checker];
}

- (void) drawCheckers {
    
    NSUInteger checkersCount        = self.cellCount / 2 * 3;
    NSUInteger checkerSize          = self.cellSize / 1.5f;
    
    NSUInteger i = 0;
    for (UIView* cell in self.cells) {
        
        if (i < checkersCount) {
            // white checker
            [self createTheCheckerWithColor:[UIColor grayColor] andSize:checkerSize onPoint:cell.center];
        }
        
        if (i >= ([self.cells count] - checkersCount)) {
            // red checker
            [self createTheCheckerWithColor:[UIColor redColor] andSize:checkerSize onPoint:cell.center];
        }
        
        i++;
    }
}

- (void) shuffleCheckers {
    
    NSMutableArray* cells           = [NSMutableArray arrayWithArray:self.cells];
    
    for (UIView* checker in self.checkers) {
        NSUInteger emptyCells       = [cells count];
        NSUInteger cellIndex        = arc4random() % emptyCells;
        UIView* cell                = cells[cellIndex];
        checker.center              = cell.center;
        [cells removeObjectAtIndex:cellIndex];
    }
    
}

- (double) calculateDistanceBetween:(CGPoint)point1 and:(CGPoint)point2 {
    
    double dx = (point2.x-point1.x);
    double dy = (point2.y-point1.y);
    return sqrt(dx*dx + dy*dy);
    
}

- (BOOL) cellIsFree:(UIView*)cell forChecker:(UIView*)checker {
    BOOL cellIsFree = YES;
    
    for (UIView* ch in self.checkers) {
        
        if ([checker isEqual:ch]) {
            continue;
        }
        
        if ([cell pointInside:[self.whiteBox convertPoint:ch.center toView:cell] withEvent:nil]) {
            cellIsFree = NO;
        }
    }
    return cellIsFree;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet* setOfCheckers = [NSSet setWithArray:self.checkers];
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.whiteBox];
    UIView* view = [self.whiteBox hitTest:pointOnMainView withEvent:event];
    
    //NSLog(@"bounds = %@", NSStringFromCGRect(view.bounds));
    
    if ([setOfCheckers containsObject:view]) {
        
        self.draggingView = view;
        
        [self.view bringSubviewToFront:self.draggingView];
        
        CGPoint touchPoint = [touch locationInView:self.draggingView];
        
        /*
        NSLog(@"bounds = %@", NSStringFromCGRect(self.draggingView.bounds));
        NSLog(@"MidX = %f, MidY = %f", CGRectGetMidX(self.draggingView.bounds), CGRectGetMidY(self.draggingView.bounds));
        NSLog(@"Touch point = %@", NSStringFromCGPoint(touchPoint));
        */
         
        self.touchOffset = CGPointMake(
                                       CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
        
        //NSLog(@"Touch offset = %@", NSStringFromCGPoint(self.touchOffset));
        //[self.draggingView.layer removeAllAnimations];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.draggingView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
            self.draggingView.alpha = 0.6f;
        }];
        
    } else {
        
        self.draggingView = nil;
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.draggingView) {
        
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.whiteBox];
        
        CGPoint correction = CGPointMake(
                                         pointOnMainView.x + self.touchOffset.x,
                                         pointOnMainView.y + self.touchOffset.y);
        
        self.draggingView.center = correction;
    }
    
}

- (void) onTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    
    [UIView animateWithDuration:0.3f animations:^{
        self.draggingView.transform = CGAffineTransformIdentity;
        self.draggingView.alpha = 1.f;
    }];
    
    // find the minimum distance cell
    CGPoint centerPoint = self.draggingView.center;
    UIView* forstView = self.cells[0];
    CGPoint nearestPoint = forstView.center;
    CGFloat minDistance = [self calculateDistanceBetween:centerPoint and:nearestPoint];
    for (UIView* cell in self.cells) {
        
        if (!([self cellIsFree:cell forChecker:self.draggingView])) {
            continue;
        }
        
        CGFloat distance = [self calculateDistanceBetween:centerPoint and:cell.center];
        if (distance < minDistance) {
            minDistance = distance;
            nearestPoint = cell.center;
        }
    }
    self.draggingView.center = nearestPoint;
    
    self.draggingView = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouchesEnded:touches withEvent:event];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouchesEnded:touches withEvent:event];
    
}

@end
