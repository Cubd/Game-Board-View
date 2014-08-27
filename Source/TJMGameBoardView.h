//
//  GFRGameBoardView.h
//  Go Friends
//
//  Created by Tyler Milner on 2/28/14.
//  Copyright (c) 2014 Tyler Milner. All rights reserved.
//


//
//  TODO: Clean up how sizes are generated (perform rounding)
//  TODO: The 2D array can be generalized to perform the actions on id rather than just UIView
//  TODO: Add reset method
//

#import <UIKit/UIKit.h>

@protocol GFRGameBoardViewDelegate;
@protocol GFRGameBoardViewDataSource;

@interface TJMGameBoardView : UIView

@property (assign, nonatomic) NSUInteger numberOfRows;
@property (assign, nonatomic) NSUInteger numberOfColumns;

@property (assign, nonatomic) CGFloat minZoomLevel;
@property (assign, nonatomic) CGFloat maxZoomLevel;
@property (assign, nonatomic) BOOL tapFirstToZoomEnabled;

@property (weak, nonatomic) IBOutlet id<GFRGameBoardViewDataSource>dataSource;
@property (weak, nonatomic) IBOutlet id<GFRGameBoardViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numberOfRows numberOfColumns:(NSUInteger)numberOfColumns;

- (void)placeGamePieceView:(UIView *)gamePieceView atRow:(NSUInteger)row column:(NSUInteger)column;
- (void)placeSupplementaryView:(UIView *)supplementaryView atRow:(NSUInteger)row column:(NSUInteger)column;
- (void)removeGamePieceViewAtRow:(NSUInteger)row column:(NSUInteger)column;
- (void)removeSupplementaryViewAtRow:(NSUInteger)row column:(NSUInteger)column;
- (void)reset;
- (void)removeAllGamePieceViews;
- (void)removeAllSupplementaryViews;
- (UIView *)gamePieceViewAtRow:(NSUInteger)row column:(NSUInteger)column;
- (UIView *)supplementaryViewAtRow:(NSUInteger)row column:(NSUInteger)column;
- (CGSize)recommendedGamePieceSize;

@end


@protocol GFRGameBoardViewDataSource <NSObject>

@required
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfColumns;
@optional
- (CGFloat)lineThicknessForRowNumber:(NSUInteger)rowNumber;
- (CGFloat)lineThicknessForColumnNumber:(NSUInteger)columnNumber;
- (CGFloat)horizontalBoardMargins;
- (CGFloat)verticalBoardMargins;

@end

@protocol GFRGameBoardViewDelegate <NSObject>

@optional
- (void)gameBoardView:(TJMGameBoardView *)gameBoardView didTapRow:(NSUInteger)row column:(NSUInteger)column;
- (BOOL)gameBoardViewShouldZoom:(TJMGameBoardView *)gameBoardView;

@end
