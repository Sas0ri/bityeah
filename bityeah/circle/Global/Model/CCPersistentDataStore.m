//
//  CCPersistentDataStore.m
//  testCircle
//
//  Created by Sasori on 14/12/15.
//  Copyright (c) 2014年 huhoo. All rights reserved.
//

#import "CCPersistentDataStore.h"
#import "Circle.pb.h"

@implementation CCPersistentDataStore

- (instancetype)init {
    if (self = [super init]) {
        [self makeDirectoryIfNeeded];
    }
    return self;
}

- (void)setUid:(int64_t)uid {
    _uid = uid;
    [self makeDirectoryIfNeeded];
}

- (NSArray *)loadFirstPageAbstracts {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    NSArray* arr = [[NSArray alloc] initWithContentsOfFile:[firstPageFile stringByAppendingPathComponent:@"FP"]];
    NSMutableArray* result = [NSMutableArray array];
    for (NSNumber* waveId in arr) {
        PBFetchWaveIdsRespPBWaveAbstract* ab = [self abstractForId:waveId.longLongValue];
        if (ab) {
            [result addObject:ab];
        }
    }
    return [result copy];
}

- (void)saveFirstPageAbstracts:(NSArray *)firstPage {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    NSMutableArray* arr = [NSMutableArray array];
    for (PBFetchWaveIdsRespPBWaveAbstract* ab in firstPage) {
        NSString* path = [firstPageFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(ab.waveId)]];
        [[ab data] writeToFile:path atomically:YES];
        [arr addObject:@(ab.waveId)];
    }
    firstPageFile = [firstPageFile stringByAppendingPathComponent:@"FP"];
    [arr writeToFile:firstPageFile atomically:YES];
}

- (PBFetchWaveIdsRespPBWaveAbstract *)abstractForId:(int64_t)waveId {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    NSString* path = [firstPageFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(waveId)]];
    NSInputStream* is = [[NSInputStream alloc] initWithFileAtPath:path];
    PBFetchWaveIdsRespPBWaveAbstract* ab = [PBFetchWaveIdsRespPBWaveAbstract parseFromInputStream:is];
    if (ab.hasWaveId) {
        return ab;
    }
    return nil;
}

- (void)saveAbstract:(PBFetchWaveIdsRespPBWaveAbstract *)abstract {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    NSString* path = [firstPageFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(abstract.waveId)]];
    [[abstract data] writeToFile:path atomically:YES];
}

- (PBWave *)waveForId:(int64_t)waveId {
    NSString* filePath = [[self userWaveDomainDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", waveId]];
    NSInputStream* st = [[NSInputStream alloc] initWithFileAtPath:filePath];
    PBWave* wave = [PBWave parseFromInputStream:st];
    if (wave.hasId) {
        return wave;
    }
    return nil;
}

- (PBWaveComment *)commentForId:(int64_t)commentId {
    NSString* filePath = [[self userCommentDomainDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", commentId]];
    NSInputStream* st = [[NSInputStream alloc] initWithFileAtPath:filePath];
    PBWaveComment* waveComment = [PBWaveComment parseFromInputStream:st];
    if (waveComment.hasId) {
        return waveComment;
    }
    return nil;
}

- (NSArray *)wavedsForIds:(NSArray *)waveIds {
    NSMutableArray* result = [NSMutableArray array];
    for (NSNumber* waveId in waveIds) {
        PBWave* wave = [self waveForId:waveId.longLongValue];
        [result addObject:wave];
    }
    return [result copy];
}

- (NSArray *)commentsForIds:(NSArray *)commentIds {
    NSMutableArray* result = [NSMutableArray array];
    for (NSNumber* commentId in commentIds) {
        PBWaveComment* waveComment = [self commentForId:commentId.longLongValue];
        [result addObject:waveComment];
    }
    return [result copy];
}

- (void)saveWave:(PBWave *)wave {
    NSString* filePath = [[self userWaveDomainDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", wave.id]];
    [[wave data] writeToFile:filePath atomically:YES];
}

- (void)saveWaves:(NSArray *)waves {
    for (PBWave* wave in waves) {
        [self saveWave:wave];
    }
}

- (void)saveComment:(PBWaveComment *)comment {
    NSString* filePath = [[self userCommentDomainDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", comment.id]];
    [[comment data] writeToFile:filePath atomically:YES];
}

- (void)saveComments:(NSArray *)comments {
    for (PBWaveComment* comment in comments) {
        [self saveComment:comment];
    }
}

- (void)deleteWaveById:(int64_t)waveId {
    NSString* filePath = [[self userWaveDomainDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", waveId]];
    NSFileManager* fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:filePath error:nil];
    
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    NSArray* arr = [[NSArray alloc] initWithContentsOfFile:[firstPageFile stringByAppendingPathComponent:@"FP"]];
    arr = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %lld", waveId]];
    [arr writeToFile:[firstPageFile stringByAppendingPathComponent:@"FP"] atomically:YES];
}

- (void)saveUnread:(NSArray *)commentIds {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    firstPageFile = [firstPageFile stringByAppendingPathComponent:@"UR"];
    [commentIds writeToFile:firstPageFile atomically:YES];
}

- (NSArray *)getUnread {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    firstPageFile = [firstPageFile stringByAppendingPathComponent:@"UR"];
    NSArray* result = [NSArray arrayWithContentsOfFile:firstPageFile];
    return result;
}

- (void)addFirstPageWaveId:(int64_t)waveId {
    NSString* firstPageFile = [self userFirstPageDomainDirectory];
    NSArray* arr = [[NSArray alloc] initWithContentsOfFile:[firstPageFile stringByAppendingPathComponent:@"FP"]];
    NSMutableArray* temp = [NSMutableArray arrayWithArray:arr];
    [temp insertObject:@(waveId) atIndex:0];
    if (temp.count > 20) {
        [temp removeLastObject];
    }
    [temp writeToFile:[firstPageFile stringByAppendingPathComponent:@"FP"] atomically:YES];
    
    PBFetchWaveIdsRespPBWaveAbstract* ab = [[[[[PBFetchWaveIdsRespPBWaveAbstract builder] setWaveId:waveId] setTextCommentCount:0] setYouLikeCommentId:0] build];
    [self saveAbstract:ab];
}

- (void)addMyCommentIds:(NSArray *)commentsIds {
    NSArray* arr = [self findMyCommentIds];
    if (!arr) {
        arr = [NSArray array];
    }
    NSMutableArray* localIds = [arr mutableCopy];
    [commentsIds enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber* commentId = (NSNumber*)obj;
        if (![localIds containsObject:commentId]) {
            [localIds insertObject:commentId atIndex:0];
        }
    }];
    [localIds writeToFile:[[self myCommentDomainDirectory] stringByAppendingPathComponent:@"MC"]  atomically:YES];
}

- (NSArray *)findMyCommentIds {
    NSArray* arr = [[NSArray alloc] initWithContentsOfFile:[[self myCommentDomainDirectory] stringByAppendingPathComponent:@"MC"]];
    return arr;
}

- (void)removeMyCommentIds {
    NSFileManager* fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:[[self myCommentDomainDirectory] stringByAppendingPathComponent:@"MC"] error:nil];
}

#pragma mark Directory

- (NSString*)userDomainDirectory {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld", self.uid]];
    return path;
}

- (NSString*)circleDirectory {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:@"CIRCLE"];
    return path;
}

- (NSString*)userFirstPageDomainDirectory {
    return [[self userDomainDirectory] stringByAppendingPathComponent:@"FP"];
}

- (NSString*)userWaveDomainDirectory {
    return [[self circleDirectory] stringByAppendingPathComponent:@"WAVE"];
}

- (NSString*)userCommentDomainDirectory {
    return [[self circleDirectory] stringByAppendingPathComponent:@"COMMENT"];
}

- (NSString*)myCommentDomainDirectory {
    return [[self userDomainDirectory] stringByAppendingPathComponent:@"MC"];
}

- (void)makeDirectoryIfNeeded {
    NSFileManager* fm = [NSFileManager defaultManager];
    do {
        BOOL isDirectory = NO;
        NSString* path = [self userDomainDirectory];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                break;
            }
        }
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    } while (true);
    
    do {
        BOOL isDirectory = NO;
        NSString* path = [self circleDirectory];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                break;
            }
        }
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    } while (true);
    
    do {
        BOOL isDirectory = NO;
        
        NSString* path = [self userFirstPageDomainDirectory];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                break;
            }
        }
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    } while (true);
    
    do {
        BOOL isDirectory = NO;
        
        NSString* path = [self userWaveDomainDirectory];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                break;
            }
        }
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    } while (true);
    
    do {
        BOOL isDirectory = NO;
        
        
        NSString* path = [self userCommentDomainDirectory];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                break;
            }
        }
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    } while (true);
    
    do {
        BOOL isDirectory = NO;
        
        NSString* path = [self myCommentDomainDirectory];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory) {
                break;
            }
        }
        [fm removeItemAtPath:path error:nil];
        [fm createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    } while (true);
}

@end
