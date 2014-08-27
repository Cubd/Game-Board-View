//
//  TJMViewController.m
//  Game Board View
//
//  Created by Soz on 8/17/14.
//  Copyright (c) 2014 Tyler Milner. All rights reserved.
//

#import "TJMViewController.h"
#import "TJMGameBoardView.h"
#import "TJMGameBoard.h"

#define kNumRows 4
#define kNumCols 4

@interface TJMViewController () <TJMGameBoardViewDataSource, TJMGameBoardViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *gameBoardViewContainer;
@property (strong, nonatomic) TJMGameBoardView *gameBoardView;
@property (strong, nonatomic) TJMGameBoard *gameBoard;
@property (assign, nonatomic) BOOL isPlayerTwosTurn;

@end

@implementation TJMViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        [self tjmViewControllerCommonInit];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self tjmViewControllerCommonInit];
}

- (void)tjmViewControllerCommonInit
{
    _gameBoard = [[TJMGameBoard alloc] initWithNumberOfRows:kNumRows numberOfColumns:kNumCols];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.gameBoardView = [[TJMGameBoardView alloc] initWithFrame:self.gameBoardViewContainer.bounds numberOfRows:kNumRows numberOfColumns:kNumCols];
    self.gameBoardView.backgroundColor = [UIColor clearColor];
    self.gameBoardView.dataSource = self;
    self.gameBoardView.delegate = self;
    [self.gameBoardViewContainer addSubview:self.gameBoardView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (TJMGameBoardCellState)nextCellState
{
    TJMGameBoardCellState state = (self.isPlayerTwosTurn ? TJMGameBoardCellStateWhite : TJMGameBoardCellStateBlack);
    self.isPlayerTwosTurn = !self.isPlayerTwosTurn;
    
    return state;
}

#pragma mark - TJMGameBoardViewDataSource

- (NSUInteger)numberOfRows
{
    return kNumRows;
}

- (NSUInteger)numberOfColumns
{
    return kNumCols;
}

#pragma mark - TJMGameBoardViewDelegate

- (void)gameBoardView:(TJMGameBoardView *)gameBoardView didTapRow:(NSUInteger)row column:(NSUInteger)column
{
    if ([self.gameBoard gameBoardCellStateAtRow:row column:column] == TJMGameBoardCellStateEmpty)
    {
        TJMGameBoardCellState cellState = [self nextCellState];
        
        [self.gameBoard setGameBoardCellState:cellState AtRow:row column:column];
        
        CGSize gamePieceSize = [gameBoardView recommendedGamePieceSize];
        
        UIView *gamePieceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, gamePieceSize.width, gamePieceSize.height)];
        gamePieceView.backgroundColor = (cellState == TJMGameBoardCellStateBlack ? [UIColor blackColor] : [UIColor whiteColor]);
        gamePieceView.layer.cornerRadius = gamePieceSize.width / 2.0f;
        
        [gameBoardView placeGamePieceView:gamePieceView atRow:row column:column];
    }
}

@end
