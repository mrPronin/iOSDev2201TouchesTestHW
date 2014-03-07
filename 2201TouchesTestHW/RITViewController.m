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
@property (assign, nonatomic) NSUInteger borderOffset;
@property (assign, nonatomic) NSUInteger cellCount;
@property (assign, nonatomic) NSUInteger screenMin;
@property (assign, nonatomic) NSUInteger screenMax;
@property (assign, nonatomic) NSUInteger cellSize;
@property (assign, nonatomic) NSUInteger fieldSize;
@property (strong, nonatomic) NSMutableArray* cells;
@property (strong, nonatomic) NSMutableArray* checkers;

@end

@implementation RITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeProperties];
    
    [self drawChessboard];
    
    [self drawCheckers];
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
    
    self.borderOffset           = 20;
    self.cellCount              = 8;
    self.screenMin              = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.screenMax              = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    // calculate cell size and field size
    self.cellSize               = (self.screenMin - self.borderOffset * 2 - 4) / self.cellCount;
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
    
    UIView* whiteBox            = [[UIView alloc] initWithFrame:rect];
    whiteBox.backgroundColor    = [UIColor whiteColor];
    [self.chessboard addSubview:whiteBox];
    
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
            [whiteBox addSubview:view];
            
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
    [self.chessboard addSubview:checker];
}

- (void) drawCheckers {
    
    NSUInteger checkersCount        = self.cellCount / 2 * 3;
    NSUInteger checkerSize          = self.cellSize / 1.5f;
    
    NSUInteger i = 0;
    for (UIView* cell in self.cells) {
        
        if (i < checkersCount) {
            // white checker
            [self createTheCheckerWithColor:[UIColor whiteColor] andSize:checkerSize onPoint:cell.center];
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

@end
