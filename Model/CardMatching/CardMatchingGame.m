//
//  CardMatchingGame.m
//  Machismo
//
//  Created by 彩月葵 on 2018/03/17.
//  Copyright © 2018年 彩月葵. All rights reserved.
//

#import "CardMatchingGame.h"
#import "PlayingCard.h"
#import "ChoosingResult.h"

@implementation CardMatchingGame

NSString *const RESULT_TYPE_FLIP_UP   = @"flip up";
NSString *const RESULT_TYPE_FLIP_DOWN = @"flip down";
NSString *const RESULT_TYPE_MATCH     = @"match";
NSString *const RESULT_TYPE_MISMATCH  = @"mismatch";
NSString *const RESULT_TYPE_DISABLE   = @"disable";

static const int MISMATCH_PANELTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;

- (ChoosingResult *)chooseCardAtIndex:(NSUInteger)index {
    self.started = YES;
    
    NSInteger oldScore = self.score;
    
    Card *card = [self cardAtIndex:index];
    if (card.isMatched) return [[ChoosingResult alloc] init:nil type:RESULT_TYPE_DISABLE scoreDelta:self.score - oldScore];
    
    if (card.isChosen) {
        [self setCardChosen:card chosen:NO];
        return [[ChoosingResult alloc] init:@[card] type:RESULT_TYPE_FLIP_DOWN scoreDelta:self.score - oldScore];
    } else {
        [self setCardChosen:card chosen:YES];
        
        if (self.choosingCount == self.chosenCount) {
            NSMutableArray *chosenCards = [[NSMutableArray alloc] init];
            for (Card *chosenCard in self.cards) {
                if (!(chosenCard.isChosen && !chosenCard.isMatched)) continue;
                
                [chosenCards addObject:chosenCard];
                [self setCardChosen:chosenCard chosen:NO];
            }
            
            int matchScore = [PlayingCard match:chosenCards];
            
            if (matchScore) {
                self.score += matchScore * MATCH_BONUS;
                
                for (Card *chosenCard in chosenCards) {
                    chosenCard.matched = YES;
                }
                
                return [[ChoosingResult alloc] init:chosenCards type:RESULT_TYPE_MATCH scoreDelta:self.score - oldScore];
            } else {
                self.score -= MISMATCH_PANELTY;
                
                return [[ChoosingResult alloc] init:chosenCards type:RESULT_TYPE_MISMATCH scoreDelta:self.score - oldScore];
            }
            
        } else {
            return [[ChoosingResult alloc] init:@[card] type:RESULT_TYPE_FLIP_UP scoreDelta:self.score - oldScore];
        }
    }
    
    return nil;
}

- (void)setCardChosen:(Card *)card
               chosen:(BOOL)chosen {
    if (card.isChosen != chosen) {
        self.chosenCount += chosen ? 1 : -1;
        if (chosen) self.score -= COST_TO_CHOOSE;
    }
    
    card.chosen = chosen;
}

@end
