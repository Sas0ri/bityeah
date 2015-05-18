// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "Frame.pb.h"
// @@protoc_insertion_point(imports)

@class Int64Array;
@class Int64ArrayBuilder;
@class PBFile;
@class PBFileBuilder;
@class PBFrame;
@class PBFrameBuilder;
@class PBUploadFileReq;
@class PBUploadFileReqBuilder;
@class PBUploadFileResp;
@class PBUploadFileRespBuilder;
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

typedef NS_ENUM(SInt32, PBFileType) {
  PBFileTypeTypePicture = 1,
  PBFileTypeTypeVoice = 2,
  PBFileTypeTypeVideo = 3,
  PBFileTypeTypeDoc = 4,
  PBFileTypeTypeXls = 5,
  PBFileTypeTypePpt = 6,
  PBFileTypeTypeZip = 7,
  PBFileTypeTypeRar = 8,
  PBFileTypeTypeOther = 100,
};

BOOL PBFileTypeIsValidValue(PBFileType value);

typedef NS_ENUM(SInt32, PBFileApp) {
  PBFileAppAppCircle = 1,
};

BOOL PBFileAppIsValidValue(PBFileApp value);


@interface FileRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
+ (id<PBExtensionField>) uploadFileReq;
+ (id<PBExtensionField>) uploadFileResp;
@end

@interface PBFile : PBGeneratedMessage {
@private
  BOOL hasRelativeUrl_:1;
  BOOL hasOriginalName_:1;
  BOOL hasMd5_:1;
  BOOL hasSignature_:1;
  BOOL hasType_:1;
  BOOL hasBelongApp_:1;
  BOOL hasNonce_:1;
  BOOL hasId_:1;
  BOOL hasSenderPassportId_:1;
  BOOL hasTimestamp_:1;
  BOOL hasCreatedAt_:1;
  BOOL hasDeletedAt_:1;
  NSString* relativeUrl;
  NSString* originalName;
  NSString* md5;
  NSString* signature;
  PBFileType type;
  PBFileApp belongApp;
  SInt32 nonce;
  SInt64 id;
  SInt64 senderPassportId;
  SInt64 timestamp;
  SInt64 createdAt;
  SInt64 deletedAt;
}
- (BOOL) hasId;
- (BOOL) hasType;
- (BOOL) hasBelongApp;
- (BOOL) hasSenderPassportId;
- (BOOL) hasRelativeUrl;
- (BOOL) hasOriginalName;
- (BOOL) hasMd5;
- (BOOL) hasTimestamp;
- (BOOL) hasNonce;
- (BOOL) hasSignature;
- (BOOL) hasCreatedAt;
- (BOOL) hasDeletedAt;
@property (readonly) SInt64 id;
@property (readonly) PBFileType type;
@property (readonly) PBFileApp belongApp;
@property (readonly) SInt64 senderPassportId;
@property (readonly, strong) NSString* relativeUrl;
@property (readonly, strong) NSString* originalName;
@property (readonly, strong) NSString* md5;
@property (readonly) SInt64 timestamp;
@property (readonly) SInt32 nonce;
@property (readonly, strong) NSString* signature;
@property (readonly) SInt64 createdAt;
@property (readonly) SInt64 deletedAt;

+ (PBFile*) defaultInstance;
- (PBFile*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBFileBuilder*) builder;
+ (PBFileBuilder*) builder;
+ (PBFileBuilder*) builderWithPrototype:(PBFile*) prototype;
- (PBFileBuilder*) toBuilder;

+ (PBFile*) parseFromData:(NSData*) data;
+ (PBFile*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBFile*) parseFromInputStream:(NSInputStream*) input;
+ (PBFile*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBFile*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBFile*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBFileBuilder : PBGeneratedMessageBuilder {
@private
  PBFile* result;
}

- (PBFile*) defaultInstance;

- (PBFileBuilder*) clear;
- (PBFileBuilder*) clone;

- (PBFile*) build;
- (PBFile*) buildPartial;

- (PBFileBuilder*) mergeFrom:(PBFile*) other;
- (PBFileBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBFileBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasId;
- (SInt64) id;
- (PBFileBuilder*) setId:(SInt64) value;
- (PBFileBuilder*) clearId;

- (BOOL) hasType;
- (PBFileType) type;
- (PBFileBuilder*) setType:(PBFileType) value;
- (PBFileBuilder*) clearType;

- (BOOL) hasBelongApp;
- (PBFileApp) belongApp;
- (PBFileBuilder*) setBelongApp:(PBFileApp) value;
- (PBFileBuilder*) clearBelongApp;

- (BOOL) hasSenderPassportId;
- (SInt64) senderPassportId;
- (PBFileBuilder*) setSenderPassportId:(SInt64) value;
- (PBFileBuilder*) clearSenderPassportId;

- (BOOL) hasRelativeUrl;
- (NSString*) relativeUrl;
- (PBFileBuilder*) setRelativeUrl:(NSString*) value;
- (PBFileBuilder*) clearRelativeUrl;

- (BOOL) hasOriginalName;
- (NSString*) originalName;
- (PBFileBuilder*) setOriginalName:(NSString*) value;
- (PBFileBuilder*) clearOriginalName;

- (BOOL) hasMd5;
- (NSString*) md5;
- (PBFileBuilder*) setMd5:(NSString*) value;
- (PBFileBuilder*) clearMd5;

- (BOOL) hasTimestamp;
- (SInt64) timestamp;
- (PBFileBuilder*) setTimestamp:(SInt64) value;
- (PBFileBuilder*) clearTimestamp;

- (BOOL) hasNonce;
- (SInt32) nonce;
- (PBFileBuilder*) setNonce:(SInt32) value;
- (PBFileBuilder*) clearNonce;

- (BOOL) hasSignature;
- (NSString*) signature;
- (PBFileBuilder*) setSignature:(NSString*) value;
- (PBFileBuilder*) clearSignature;

- (BOOL) hasCreatedAt;
- (SInt64) createdAt;
- (PBFileBuilder*) setCreatedAt:(SInt64) value;
- (PBFileBuilder*) clearCreatedAt;

- (BOOL) hasDeletedAt;
- (SInt64) deletedAt;
- (PBFileBuilder*) setDeletedAt:(SInt64) value;
- (PBFileBuilder*) clearDeletedAt;
@end

@interface PBUploadFileReq : PBGeneratedMessage {
@private
  BOOL hasFile_:1;
  PBFile* file;
}
- (BOOL) hasFile;
@property (readonly, strong) PBFile* file;

+ (PBUploadFileReq*) defaultInstance;
- (PBUploadFileReq*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBUploadFileReqBuilder*) builder;
+ (PBUploadFileReqBuilder*) builder;
+ (PBUploadFileReqBuilder*) builderWithPrototype:(PBUploadFileReq*) prototype;
- (PBUploadFileReqBuilder*) toBuilder;

+ (PBUploadFileReq*) parseFromData:(NSData*) data;
+ (PBUploadFileReq*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBUploadFileReq*) parseFromInputStream:(NSInputStream*) input;
+ (PBUploadFileReq*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBUploadFileReq*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBUploadFileReq*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBUploadFileReqBuilder : PBGeneratedMessageBuilder {
@private
  PBUploadFileReq* result;
}

- (PBUploadFileReq*) defaultInstance;

- (PBUploadFileReqBuilder*) clear;
- (PBUploadFileReqBuilder*) clone;

- (PBUploadFileReq*) build;
- (PBUploadFileReq*) buildPartial;

- (PBUploadFileReqBuilder*) mergeFrom:(PBUploadFileReq*) other;
- (PBUploadFileReqBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBUploadFileReqBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasFile;
- (PBFile*) file;
- (PBUploadFileReqBuilder*) setFile:(PBFile*) value;
- (PBUploadFileReqBuilder*) setFileBuilder:(PBFileBuilder*) builderForValue;
- (PBUploadFileReqBuilder*) mergeFile:(PBFile*) value;
- (PBUploadFileReqBuilder*) clearFile;
@end

@interface PBUploadFileResp : PBGeneratedMessage {
@private
  BOOL hasDetail_:1;
  BOOL hasFile_:1;
  NSString* detail;
  PBFile* file;
}
- (BOOL) hasFile;
- (BOOL) hasDetail;
@property (readonly, strong) PBFile* file;
@property (readonly, strong) NSString* detail;

+ (PBUploadFileResp*) defaultInstance;
- (PBUploadFileResp*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBUploadFileRespBuilder*) builder;
+ (PBUploadFileRespBuilder*) builder;
+ (PBUploadFileRespBuilder*) builderWithPrototype:(PBUploadFileResp*) prototype;
- (PBUploadFileRespBuilder*) toBuilder;

+ (PBUploadFileResp*) parseFromData:(NSData*) data;
+ (PBUploadFileResp*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBUploadFileResp*) parseFromInputStream:(NSInputStream*) input;
+ (PBUploadFileResp*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBUploadFileResp*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBUploadFileResp*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBUploadFileRespBuilder : PBGeneratedMessageBuilder {
@private
  PBUploadFileResp* result;
}

- (PBUploadFileResp*) defaultInstance;

- (PBUploadFileRespBuilder*) clear;
- (PBUploadFileRespBuilder*) clone;

- (PBUploadFileResp*) build;
- (PBUploadFileResp*) buildPartial;

- (PBUploadFileRespBuilder*) mergeFrom:(PBUploadFileResp*) other;
- (PBUploadFileRespBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBUploadFileRespBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasFile;
- (PBFile*) file;
- (PBUploadFileRespBuilder*) setFile:(PBFile*) value;
- (PBUploadFileRespBuilder*) setFileBuilder:(PBFileBuilder*) builderForValue;
- (PBUploadFileRespBuilder*) mergeFile:(PBFile*) value;
- (PBUploadFileRespBuilder*) clearFile;

- (BOOL) hasDetail;
- (NSString*) detail;
- (PBUploadFileRespBuilder*) setDetail:(NSString*) value;
- (PBUploadFileRespBuilder*) clearDetail;
@end


// @@protoc_insertion_point(global_scope)
