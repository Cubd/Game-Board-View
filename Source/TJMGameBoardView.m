//
//  GFRGameBoardView.m
//  Go Friends
//
//  Created by Tyler Milner on 2/28/14.
//  Copyright (c) 2014 Tyler Milner. All rights reserved.
//

//
//  TODO: Looks like it is possible to programatically place views at (row, col) beyond the bounds of the game board <-- Yes, it is
//  TODO: An alternative approach to the backing view arrays would be to make a category on UIView with a row, column, and view type properties (or subclasses of UIView that inmplement this). Then just search through self.subviews to access a view at a row/col. Might be useful to implement this method to try to shave off as much mem usage as possible since Fuego will use a lot.
//  TODO: Refactor to use a UICollectionView with a custom flow layout.
//

#import "TJMGameBoardView.h"
#import "TJMTwoDimensionalArray.h"

@interface TJMGameBoardView()

@property (strong, nonatomic) TJMTwoDimensionalArray *gamePieceViews;
@property (strong, nonatomic) TJMTwoDimensionalArray *supplementaryViews;

@end


@implementation TJMGameBoardView

@synthesize numberOfRows = _numberOfRows;
@synthesize numberOfColumns = _numberOfColumns;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _numberOfRows = 0;
        _numberOfColumns = 0;
        [self goGFRGameBoardViewCommonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numberOfRows numberOfColumns:(NSUInteger)numberOfColumns
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _numberOfRows = numberOfRows;
        _numberOfColumns = numberOfColumns;
        [self goGFRGameBoardViewCommonInit];
    }
    
    return self;
}

- (void)awakeFromNib
{
    _numberOfRows = 0;
    _numberOfColumns = 0;
    [self goGFRGameBoardViewCommonInit];
}

- (void)goGFRGameBoardViewCommonInit
{    
    _gamePieceViews = [[TJMTwoDimensionalArray alloc] initWithNumberOfRows:_numberOfRows numberOfColumns:_numberOfColumns];
    _supplementaryViews = [[TJMTwoDimensionalArray alloc] initWithNumberOfRows:_numberOfRows numberOfColumns:_numberOfColumns];
}

#pragma mark - View Lifecycle

- (void)drawRect:(CGRect)rect
{
    CGFloat defaultLineWidth = 2.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    NSInteger numberOfColumns = [self numberOfColumns];
    NSInteger numberOfRows = [self numberOfRows];
    
    for (int col = 0; col < numberOfColumns; col++)
    {
        CGFloat xPosition = [self xPositionForColumnNumber:col];
        
        CGPoint start = CGPointMake(xPosition, [self yPositionForRowNumber:0]);
        CGPoint end = CGPointMake(xPosition, [self yPositionForRowNumber:numberOfRows - 1]);
        
        CGFloat lineWidth = defaultLineWidth;
        
        if ([self.dataSource respondsToSelector:@selector(lineThicknessForColumnNumber:)])
        {
            lineWidth = [self.dataSource lineThicknessForColumnNumber:col];
        }
        
        CGContextSetLineWidth(context, lineWidth);
        
        [self drawLineFromPoint:start toPoint:end usingContext:context];
    }
    
    for (int row = 0; row < numberOfRows; row++)
    {
        CGFloat yPosition = [self yPositionForRowNumber:row];
        
        CGPoint start = CGPointMake([self xPositionForColumnNumber:0], yPosition);
        CGPoint end = CGPointMake([self xPositionForColumnNumber:numberOfColumns - 1], yPosition);
        
        CGFloat lineWidth = defaultLineWidth;
        
        if ([self.dataSource respondsToSelector:@selector(lineThicknessForRowNumber:)])
        {
            lineWidth = [self.dataSource lineThicknessForColumnNumber:row];
        }
        
        CGContextSetLineWidth(context, lineWidth);
        
        [self drawLineFromPoint:start toPoint:end usingContext:context];
    }
}

#pragma mark - Properties

- (void)setNumberOfRows:(NSUInteger)numberOfRows
{
    if (_numberOfRows != numberOfRows)
    {
        _numberOfRows = numberOfRows;
        
        self.gamePieceViews.numberOfRows = numberOfRows;
        self.supplementaryViews.numberOfRows = numberOfRows;
    }
}

- (NSUInteger)numberOfRows
{
    NSUInteger numberOfRows = 0;

    // Always asks delegate unless the setter has been used
    if (_numberOfRows)
    {
        numberOfRows = _numberOfRows;
    }
    else if ([self.dataSource respondsToSelector:@selector(numberOfRows)])
    {
        numberOfRows = [self.dataSource numberOfRows];
    }
    
    return numberOfRows;
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns
{
    if (_numberOfColumns != numberOfColumns)
    {
        _numberOfColumns = numberOfColumns;
        
        self.gamePieceViews.numberOfColumns = numberOfColumns;
        self.supplementaryViews.numberOfColumns = numberOfColumns;
    }
}

- (NSUInteger)numberOfColumns
{
    NSUInteger numberOfColumns = 0;
    
    if (_numberOfColumns)
    {
        numberOfColumns = _numberOfColumns;
    }
    else if ([self.dataSource respondsToSelector:@selector(numberOfColumns)])
    {
        numberOfColumns = [self.dataSource numberOfColumns];
    }
    
    return numberOfColumns;
}

#pragma mark - Public

- (void)placeGamePieceView:(UIView *)gamePieceView atRow:(NSUInteger)row column:(NSUInteger)column
{
    NSAssert(gamePieceView, @"Game piece view should not be nil.");
    
    [self placeView:gamePieceView atRow:row column:column];
    [self.gamePieceViews setObject:gamePieceView atRow:row column:column];
}

- (void)placeSupplementaryView:(UIView *)supplementaryView atRow:(NSUInteger)row column:(NSUInteger)column
{
    NSAssert(supplementaryView, @"Supplementary view should not be nil.");
    
    [self placeView:supplementaryView atRow:row column:column];
    [self.supplementaryViews setObject:supplementaryView atRow:row column:column];
}

- (void)removeGamePieceViewAtRow:(NSUInteger)row column:(NSUInteger)column
{
    [self removeViewIn2DArray:self.gamePieceViews atRow:row column:column];
}

- (void)removeSupplementaryViewAtRow:(NSUInteger)row column:(NSUInteger)column
{
    [self removeViewIn2DArray:self.supplementaryViews atRow:row column:column];
}

- (void)reset
{
    [self removeAllGamePieceViews];
    [self removeAllSupplementaryViews];
}

- (void)removeAllGamePieceViews
{
    for (NSUInteger row = 0; row < self.numberOfRows; row++)
    {
        for (NSUInteger column = 0; column < self.numberOfColumns; column++)
        {
            id view = [self.gamePieceViews objectAtRow:row column:column];
            
            if ([view isKindOfClass:[UIView class]])
            {
                [self removeGamePieceViewAtRow:row column:column];
            }
        }
    }
}

- (void)removeAllSupplementaryViews
{
    for (NSUInteger row = 0; row < self.numberOfRows; row++)
    {
        for (NSUInteger column = 0; column < self.numberOfColumns; column++)
        {
            [self removeSupplementaryViewAtRow:row column:column];
        }
    }
}

- (UIView *)gamePieceViewAtRow:(NSUInteger)row column:(NSUInteger)column
{
    UIView *gamePieceView = [self viewIn2DArray:self.gamePieceViews atRow:row column:column];
    return gamePieceView;
}

- (UIView *)supplementaryViewAtRow:(NSUInteger)row column:(NSUInteger)column
{
    UIView *supplementaryView = [self viewIn2DArray:self.supplementaryViews atRow:row column:column];
    return supplementaryView;
}

- (CGSize)recommendedGamePieceSize
{
    CGFloat width = [self boardSize].width / [self numberOfColumns];
    CGFloat height = [self boardSize].height / [self numberOfRows];
    
    CGSize recommendedSize = CGSizeMake(width, height);
    return recommendedSize;
}

- (NSString *)description
{
    NSMutableString *description = [[super description] mutableCopy];
    [description appendFormat:@"; Number of rows: %lu", (unsigned long)self.numberOfRows];
    [description appendFormat:@"; Number of columns: %lu", (unsigned long)self.numberOfColumns];
    [description appendFormat:@"; Game piece views: %@", [self.gamePieceViews description]];
    [description appendFormat:@"; Supplementary views: %@", [self.supplementaryViews description]];
    
    return description;
}

#pragma mark - Private

- (CGFloat)horizontalMargin
{
    CGFloat horizontalMargins = 10.0f;
    
    if ([self.dataSource respondsToSelector:@selector(horizontalBoardMargins)])
    {
        horizontalMargins = [self.dataSource horizontalBoardMargins];
    }
    
    return horizontalMargins;
}

- (CGFloat)verticalMargin
{
    CGFloat verticalMargins = 10.0f;
    
    if ([self.dataSource respondsToSelector:@selector(verticalBoardMargins)])
    {
        verticalMargins = [self.dataSource verticalBoardMargins];
    }
    
    return verticalMargins;
}

- (CGSize)boardSize
{
    CGFloat boardWidth = CGRectGetWidth(self.bounds) - (2.0f * [self horizontalMargin]);
    CGFloat boardHeight = CGRectGetHeight(self.bounds) - (2.0f * [self verticalMargin]);
    CGSize boardSize = CGSizeMake(boardWidth, boardHeight);
    return boardSize;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(gameBoardView:didTapRow:column:)])
    {
        CGFloat closestDistance = CGFLOAT_MAX;
        CGPoint closetCoordinate = CGPointZero;
        
        for (NSUInteger row = 0; row < [self numberOfRows]; row++)
        {
            for (NSUInteger col = 0; col < [self numberOfColumns]; col++)
            {
                CGPoint currentPoint = [self intersectionPointAtRow:row column:col];
                CGFloat touchPointDistanceToCurrentPoint = [self distanceFromPoint:touchPoint toPoint:currentPoint];
                
                if (touchPointDistanceToCurrentPoint < closestDistance)
                {
                    closestDistance = touchPointDistanceToCurrentPoint;
                    closetCoordinate = CGPointMake(row, col);
                }
            }
        }
        
        [self.delegate gameBoardView:self didTapRow:(NSUInteger)closetCoordinate.x column:(NSUInteger)closetCoordinate.y];
    }
}

- (void)placeView:(UIView *)view atRow:(NSUInteger)row column:(NSUInteger)column
{
    CGPoint intersectionPoint = [self intersectionPointAtRow:row column:column];
    view.center = intersectionPoint;
    [self addSubview:view];
}

- (void)removeViewIn2DArray:(TJMTwoDimensionalArray *)array atRow:(NSUInteger)row column:(NSUInteger)column
{
    id view = [array objectAtRow:row column:column];
    
    // TODO: This is broken
    if ([view isKindOfClass:[UIView class]])
    {
        [view removeFromSuperview];
    }
    
    [array setObject:[TJMTwoDimensionalArray nullObject] atRow:row column:column];
}

- (UIView *)viewIn2DArray:(TJMTwoDimensionalArray *)array atRow:(NSUInteger)row column:(NSUInteger)column
{
    id view = [array objectAtRow:row column:column];
    
    if ([view isKindOfClass:[UIView class]])
    {
        return (UIView *)view;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)distanceFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    CGFloat deltaX = (toPoint.x - fromPoint.x);
    CGFloat deltaY = (toPoint.y - fromPoint.y);
    
    CGFloat distance = sqrtf(powf(deltaX, 2.0f) + powf(deltaY, 2.0f));
    return distance;
}

- (void)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint usingContext:(CGContextRef)context
{
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
    CGContextStrokePath(context);
}

- (CGPoint)intersectionPointAtRow:(NSUInteger)row column:(NSUInteger)column
{
    CGFloat xPosition = [self xPositionForColumnNumber:column];
    CGFloat yPosition = [self yPositionForRowNumber:row];
    
    CGPoint intersection = CGPointMake(xPosition, yPosition);
    return intersection;
}

- (CGFloat)xPositionForColumnNumber:(NSUInteger)columnNumber
{
    CGFloat horizontalMargin = [self horizontalMargin];
    CGFloat boardWidth = CGRectGetWidth(self.bounds) - (2.0f * horizontalMargin);
    CGFloat horizontalLineSpacing = boardWidth / ([self numberOfColumns] - 1);
    
    CGFloat xPosition = horizontalMargin + (columnNumber * horizontalLineSpacing);
    return xPosition;
}

- (CGFloat)yPositionForRowNumber:(NSUInteger)rowNumber
{
    CGFloat verticalMargin = [self verticalMargin];
    CGFloat boardHeight = CGRectGetHeight(self.bounds) - (2.0f * verticalMargin);
    CGFloat verticalLineSpacing = boardHeight / ([self numberOfRows] - 1);
    
    CGFloat yPosition = verticalMargin + (rowNumber * verticalLineSpacing);
    return yPosition;
}

@end
