// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class Int64Array;
@class Int64ArrayBuilder;
@class PBFrame;
@class PBFrameBuilder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef NS_ENUM(SInt32, PBFrameCmd) {
  PBFrameCmdCmdNil = 0,
  PBFrameCmdCmdFetchPassport = 100,
  PBFrameCmdCmdFetchChangedPassports = 101,
  PBFrameCmdCmdPassportChangedNotification = 150,
  PBFrameCmdCmdFetchRoster = 200,
  PBFrameCmdCmdFetchChangedRoster = 201,
  PBFrameCmdCmdFetchRosterRequest = 202,
  PBFrameCmdCmdRosterChangedNotification = 250,
  PBFrameCmdCmdRosterRequestNotification = 251,
  PBFrameCmdCmdFetchGroup = 300,
  PBFrameCmdCmdFetchGroupAndMembers = 301,
  PBFrameCmdCmdFetchGroupAndMembersByPassportId = 302,
  PBFrameCmdCmdFetchChangedGroup = 303,
  PBFrameCmdCmdGroupChangedNotification = 350,
  PBFrameCmdCmdFetchCorporation = 400,
  PBFrameCmdCmdFetchChangedCorporation = 401,
  PBFrameCmdCmdFetchCorporationByPassportId = 402,
  PBFrameCmdCmdFetchCorporationStruct = 403,
  PBFrameCmdCmdCorporationChangedNotification = 450,
  PBFrameCmdCmdFetchParkMembers = 500,
  PBFrameCmdCmdFetchUserParksByPassportId = 501,
  PBFrameCmdCmdParkMembersChangedNotification = 550,
  PBFrameCmdCmdSendWave = 1000,
  PBFrameCmdCmdSendWaveComment = 1001,
  PBFrameCmdCmdFetchWaveComment = 1002,
  PBFrameCmdCmdDeleteWave = 1003,
  PBFrameCmdCmdDeleteWaveComment = 1004,
  PBFrameCmdCmdClearMyWaveComment = 1005,
  PBFrameCmdCmdFetchWaves = 1006,
  PBFrameCmdCmdFetchWaveIds = 1007,
  PBFrameCmdCmdFetchWaveCommentIds = 1008,
  PBFrameCmdCmdFetchAllWaves = 1009,
  PBFrameCmdCmdFetchUserWaveCount = 1010,
  PBFrameCmdCmdFetchWavesAndComents = 1024,
  PBFrameCmdCmdSendRedPacket = 1100,
  PBFrameCmdCmdRobRedPacket = 1101,
  PBFrameCmdCmdFetchRedPacket = 1102,
  PBFrameCmdCmdFetchRedPacketTicket = 1103,
  PBFrameCmdCmdSetRedPacketTicketReceived = 1104,
  PBFrameCmdCmdFetchRedPackets = 1105,
  PBFrameCmdCmdFetchRedPacketCount = 1106,
  PBFrameCmdCmdFetchRedPacketMyTicketCount = 1107,
};

BOOL PBFrameCmdIsValidValue(PBFrameCmd value);

typedef NS_ENUM(SInt32, PBFrameSessionId) {
  PBFrameSessionIdSessionIdClientMin = 1,
  PBFrameSessionIdSessionIdClientMax = 1073741823,
  PBFrameSessionIdSessionIdServerMin = 1073741824,
  PBFrameSessionIdSessionIdServerMax = 2147483646,
};

BOOL PBFrameSessionIdIsValidValue(PBFrameSessionId value);

typedef NS_ENUM(SInt32, PBFrameApp) {
  PBFrameAppHuhoo = 1,
  PBFrameAppPark = 2,
};

BOOL PBFrameAppIsValidValue(PBFrameApp value);


@interface FrameRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PBFrame : PBExtendableMessage {
@private
  BOOL hasDetail_:1;
  BOOL hasExtensionData_:1;
  BOOL hasCmd_:1;
  BOOL hasApp_:1;
  BOOL hasSessionId_:1;
  BOOL hasErrorCode_:1;
  BOOL hasPassportId_:1;
  BOOL hasServerTimestamp_:1;
  BOOL hasParkId_:1;
  NSString* detail;
  NSData* extensionData;
  PBFrameCmd cmd;
  PBFrameApp app;
  SInt32 sessionId;
  SInt32 errorCode;
  SInt64 passportId;
  SInt64 serverTimestamp;
  SInt64 parkId;
}
- (BOOL) hasPassportId;
- (BOOL) hasCmd;
- (BOOL) hasSessionId;
- (BOOL) hasErrorCode;
- (BOOL) hasDetail;
- (BOOL) hasExtensionData;
- (BOOL) hasServerTimestamp;
- (BOOL) hasApp;
- (BOOL) hasParkId;
@property (readonly) SInt64 passportId;
@property (readonly) PBFrameCmd cmd;
@property (readonly) SInt32 sessionId;
@property (readonly) SInt32 errorCode;
@property (readonly, strong) NSString* detail;
@property (readonly, strong) NSData* extensionData;
@property (readonly) SInt64 serverTimestamp;
@property (readonly) PBFrameApp app;
@property (readonly) SInt64 parkId;

+ (PBFrame*) defaultInstance;
- (PBFrame*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBFrameBuilder*) builder;
+ (PBFrameBuilder*) builder;
+ (PBFrameBuilder*) builderWithPrototype:(PBFrame*) prototype;
- (PBFrameBuilder*) toBuilder;

+ (PBFrame*) parseFromData:(NSData*) data;
+ (PBFrame*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBFrame*) parseFromInputStream:(NSInputStream*) input;
+ (PBFrame*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBFrame*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBFrame*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBFrameBuilder : PBExtendableMessageBuilder {
@private
  PBFrame* result;
}

- (PBFrame*) defaultInstance;

- (PBFrameBuilder*) clear;
- (PBFrameBuilder*) clone;

- (PBFrame*) build;
- (PBFrame*) buildPartial;

- (PBFrameBuilder*) mergeFrom:(PBFrame*) other;
- (PBFrameBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBFrameBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasPassportId;
- (SInt64) passportId;
- (PBFrameBuilder*) setPassportId:(SInt64) value;
- (PBFrameBuilder*) clearPassportId;

- (BOOL) hasCmd;
- (PBFrameCmd) cmd;
- (PBFrameBuilder*) setCmd:(PBFrameCmd) value;
- (PBFrameBuilder*) clearCmd;

- (BOOL) hasSessionId;
- (SInt32) sessionId;
- (PBFrameBuilder*) setSessionId:(SInt32) value;
- (PBFrameBuilder*) clearSessionId;

- (BOOL) hasErrorCode;
- (SInt32) errorCode;
- (PBFrameBuilder*) setErrorCode:(SInt32) value;
- (PBFrameBuilder*) clearErrorCode;

- (BOOL) hasDetail;
- (NSString*) detail;
- (PBFrameBuilder*) setDetail:(NSString*) value;
- (PBFrameBuilder*) clearDetail;

- (BOOL) hasExtensionData;
- (NSData*) extensionData;
- (PBFrameBuilder*) setExtensionData:(NSData*) value;
- (PBFrameBuilder*) clearExtensionData;

- (BOOL) hasServerTimestamp;
- (SInt64) serverTimestamp;
- (PBFrameBuilder*) setServerTimestamp:(SInt64) value;
- (PBFrameBuilder*) clearServerTimestamp;

- (BOOL) hasApp;
- (PBFrameApp) app;
- (PBFrameBuilder*) setApp:(PBFrameApp) value;
- (PBFrameBuilder*) clearApp;

- (BOOL) hasParkId;
- (SInt64) parkId;
- (PBFrameBuilder*) setParkId:(SInt64) value;
- (PBFrameBuilder*) clearParkId;
@end

@interface Int64Array : PBGeneratedMessage {
@private
  PBAppendableArray * itemsArray;
}
@property (readonly, strong) PBArray * items;
- (SInt64)itemsAtIndex:(NSUInteger)index;

+ (Int64Array*) defaultInstance;
- (Int64Array*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (Int64ArrayBuilder*) builder;
+ (Int64ArrayBuilder*) builder;
+ (Int64ArrayBuilder*) builderWithPrototype:(Int64Array*) prototype;
- (Int64ArrayBuilder*) toBuilder;

+ (Int64Array*) parseFromData:(NSData*) data;
+ (Int64Array*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Int64Array*) parseFromInputStream:(NSInputStream*) input;
+ (Int64Array*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (Int64Array*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (Int64Array*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface Int64ArrayBuilder : PBGeneratedMessageBuilder {
@private
  Int64Array* result;
}

- (Int64Array*) defaultInstance;

- (Int64ArrayBuilder*) clear;
- (Int64ArrayBuilder*) clone;

- (Int64Array*) build;
- (Int64Array*) buildPartial;

- (Int64ArrayBuilder*) mergeFrom:(Int64Array*) other;
- (Int64ArrayBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (Int64ArrayBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (PBAppendableArray *)items;
- (SInt64)itemsAtIndex:(NSUInteger)index;
- (Int64ArrayBuilder *)addItems:(SInt64)value;
- (Int64ArrayBuilder *)setItemsArray:(NSArray *)array;
- (Int64ArrayBuilder *)setItemsValues:(const SInt64 *)values count:(NSUInteger)count;
- (Int64ArrayBuilder *)clearItems;
@end


// @@protoc_insertion_point(global_scope)
