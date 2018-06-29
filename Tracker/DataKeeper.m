//
//  DataKeeper.m
//  testNetwork
//
//  Created by sgcy on 2018/6/26.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "DataKeeper.h"
#import <unicode/utf8.h>


typedef struct {
    BOOL fin;
    uint8_t opcode;
    BOOL masked;
    uint64_t payload_length;
} frame_header;

@interface DataKeeper()

@property (nonatomic,strong) NSMutableDictionary *keeper;
@property (nullable, nonatomic, assign) CFHTTPMessageRef receivedHTTPHeaders;

@end


size_t SRDefaultBufferSize(void) {
    static size_t size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = getpagesize();
    });
    return size;
}

@implementation DataKeeper{
    
    dispatch_queue_t _workQueue;
    
    dispatch_data_t _readBuffer;
    NSUInteger _readBufferOffset;
    
    dispatch_data_t _outputBuffer;
    NSUInteger _outputBufferOffset;
    
    uint8_t _currentFrameOpcode;
    size_t _currentFrameCount;
    size_t _readOpCount;
    uint32_t _currentStringScanPosition;
    NSMutableData *_currentFrameData;
    
    NSString *_closeReason;
    
    NSString *_secKey;

    
    uint8_t _currentReadMaskKey[4];
    size_t _currentReadMaskOffset;
    
    BOOL _closeWhenFinishedWriting;
    BOOL _failed;
    
    NSURLRequest *_urlRequest;
    
    BOOL _sentClose;
    BOOL _didFail;
    BOOL _cleanupScheduled;
    int _closeCode;
    BOOL _isPumping;

    NSMutableSet<NSArray *> *_scheduledRunloops; // Set<[RunLoop, Mode]>. TODO: (nlutsenko) Fix clowntown

    NSArray<NSString *> *_requestedProtocols;
    
    NSMutableArray<NSData *> *_inputQueue;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static DataKeeper* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[DataKeeper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _workQueue = dispatch_queue_create("com.DataKeeperQueue", DISPATCH_QUEUE_SERIAL);
        
        _keeper = [[NSMutableDictionary alloc] init];
        
//        // Going to set a specific on the queue so we can validate we're on the work queue
//        dispatch_queue_set_specific(_workQueue, (__bridge void *)self, (__bridge void *)(_workQueue), NULL);
//
        _readBuffer = dispatch_data_empty;
        _outputBuffer = dispatch_data_empty;
        
        _currentFrameData = [[NSMutableData alloc] init];

        
        _scheduledRunloops = [[NSMutableSet alloc] init];

    }
    return self;
}


- (NSString *)getDataForUrl:(NSString *)url
{
    NSData *data = [self.keeper objectForKey:url];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)foundPieceData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"");
}

- (void)appendData:(const void *)buffer length:(size_t)length ForUrl:(NSString *)url
{
    
    if (length <= 0) {
        return;
    }
    
//    dispatch_async(_workQueue, ^{
        dispatch_data_t data = dispatch_data_create(buffer, length, nil, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
        _readBuffer = dispatch_data_create_concat(_readBuffer, data);
        size_t readBufferSize = dispatch_data_get_size(_readBuffer);
        size_t curSize = readBufferSize - _readBufferOffset;
        NSData *subdata = (NSData *)dispatch_data_create_subrange(_readBuffer, _readBufferOffset, readBufferSize - _readBufferOffset);
        size_t foundSize = [self scanData:(NSData *)data untilBytes:CRLFCRLFBytes length:sizeof(CRLFCRLFBytes)];
        if (foundSize) {
            dispatch_data_t slice = dispatch_data_create_subrange(_readBuffer, _readBufferOffset, foundSize);
//            _readBufferOffset += foundSize;
//            _readBuffer = dispatch_data_create_subrange(_readBuffer, _readBufferOffset, readBufferSize - _readBufferOffset);
            _readBuffer = dispatch_data_empty;
            _readBufferOffset = 0;
            [self foundPieceData:(NSData *)slice];
        }
//    });
//    if ([url isEqualToString:@"www.sina.com.cn:80"]) {

    
//    uint valid_data = validate_dispatch_data_partial_string((NSData *)data);
//    if (valid_data == -1) {
//        return;
//    }
////
//    dispatch_data_t readBuffer = [self.keeper objectForKey:url];
//    if (readBuffer) {
//        readBuffer = dispatch_data_create_concat(readBuffer, data);
//    }else{
//        readBuffer = data;
//    }
//    [self.keeper setObject:readBuffer forKey:url];

//
//
//        NSString *str = [[NSString alloc] initWithData:_readBuffer encoding:NSUTF8StringEncoding];
//        if (str.length > 100) {
//            NSLog(@"-----------------------------------------------------------------------------------%@---------",str);
//        }else{
//            NSLog(@"========================================================================================%@==---------",str);
//        }
    
//        }
    
//    });
    

 
}

static const char CRLFCRLFBytes[] = {'\r', '\n', '\r', '\n'};

- (size_t)scanData:(NSData *)data untilBytes:(const void*)bytes length:(size_t)length
{
    size_t found_size = 0;
    size_t match_count = 0;
    size_t size = data.length;
    const unsigned char *buffer = data.bytes;
    for (size_t i = 0; i < size; i++ ) {
        if (((const unsigned char *)buffer)[i] == ((const unsigned char *)bytes)[match_count]) {
            match_count += 1;
            if (match_count == length) {
                found_size = i + 1;
                break;
            }
        } else {
            match_count = 0;
        }
    }
    return found_size;
}

static inline int32_t validate_dispatch_data_partial_string(NSData *data) {
    if ([data length] > INT32_MAX) {
        // INT32_MAX is the limit so long as this Framework is using 32 bit ints everywhere.
        return -1;
    }
    
    int32_t size = (int32_t)[data length];
    
    const void * contents = [data bytes];
    const uint8_t *str = (const uint8_t *)contents;
    
    UChar32 codepoint = 1;
    int32_t offset = 0;
    int32_t lastOffset = 0;
    while(offset < size && codepoint > 0)  {
        lastOffset = offset;
        U8_NEXT(str, offset, size, codepoint);
    }
    
    if (codepoint == -1) {
        // Check to see if the last byte is valid or whether it was just continuing
        if (!U8_IS_LEAD(str[lastOffset]) || U8_COUNT_TRAIL_BYTES(str[lastOffset]) + lastOffset < (int32_t)size) {
            
            size = -1;
        } else {
            uint8_t leadByte = str[lastOffset];
            U8_MASK_LEAD_BYTE(leadByte, U8_COUNT_TRAIL_BYTES(leadByte));
            
            for (int i = lastOffset + 1; i < offset; i++) {
                if (U8_IS_SINGLE(str[i]) || U8_IS_LEAD(str[i]) || !U8_IS_TRAIL(str[i])) {
                    size = -1;
                }
            }
            
            if (size != -1) {
                size = lastOffset;
            }
        }
    }
    
    if (size != -1 && ![[NSString alloc] initWithBytesNoCopy:(char *)[data bytes] length:size encoding:NSUTF8StringEncoding freeWhenDone:NO]) {
        size = -1;
    }
    
    return size;
}


//static inline int32_t validate_dispatch_data_partial_string(NSData *data) {
//    static const int maxCodepointSize = 3;
//
//    for (int i = 0; i < maxCodepointSize; i++) {
//        NSString *str = [[NSString alloc] initWithBytesNoCopy:(char *)data.bytes length:data.length - i encoding:NSUTF8StringEncoding freeWhenDone:NO];
//        if (str) {
//            return (int32_t)data.length - i;
//        }
//    }
//
//    return -1;
//}

@end
