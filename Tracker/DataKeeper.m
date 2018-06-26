//
//  DataKeeper.m
//  testNetwork
//
//  Created by sgcy on 2018/6/26.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "DataKeeper.h"

@interface DataKeeper()

@property (nonatomic,strong) NSMutableDictionary *keeper;

@end

@implementation DataKeeper

- (NSString *)getDataForUrl:(NSString *)url
{
    NSData *data = [self.keeper objectForKey:url];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)appendData:(const void *)buffer length:(size_t)length ForUrl:(NSString *)url
{
    
}




- (void)doReadData
{
    // This method is called on the socketQueue.
    
    BOOL hasBytesAvailable = NO;
    unsigned long estimatedBytesAvailable = 0;

    estimatedBytesAvailable = socketFDBytesAvailable;
    hasBytesAvailable = (estimatedBytesAvailable > 0);
    
        

    BOOL done        = NO;  // Completed read operation
    NSError *error   = nil; // Error occurred
    
    NSUInteger totalBytesReadForCurrentRead = 0;

    
    BOOL socketEOF = (flags & kSocketHasReadEOF) ? YES : NO;  // Nothing more to read via socket (end of file)
    BOOL waiting   = !done && !error && !socketEOF && !hasBytesAvailable; // Ran out of data, waiting for more
    
    if (!done && !error && !socketEOF && hasBytesAvailable)
    {
        NSAssert(([preBuffer availableBytes] == 0), @"Invalid logic");
        
        BOOL readIntoPreBuffer = NO;
        uint8_t *buffer = NULL;
        size_t bytesRead = 0;
                    
            NSUInteger bytesToRead;
            
            // There are 3 types of read packets:
            //
            // 1) Read all available data.
            // 2) Read a specific length of data.
            // 3) Read up to a particular terminator.
            
            if (currentRead->term != nil)
            {
                // Read type #3 - read up to a terminator
                
                bytesToRead = [currentRead readLengthForTermWithHint:estimatedBytesAvailable
                                                     shouldPreBuffer:&readIntoPreBuffer];
            }
            else
            {
                // Read type #1 or #2
                
                bytesToRead = [currentRead readLengthForNonTermWithHint:estimatedBytesAvailable];
            }
            
            if (bytesToRead > SIZE_MAX) { // NSUInteger may be bigger than size_t (read param 3)
                bytesToRead = SIZE_MAX;
            }
            
            // Make sure we have enough room in the buffer for our read.
            //
            // We are either reading directly into the currentRead->buffer,
            // or we're reading into the temporary preBuffer.
            
            if (readIntoPreBuffer)
            {
                [preBuffer ensureCapacityForWrite:bytesToRead];
                
                buffer = [preBuffer writeBuffer];
            }
            else
            {
                [currentRead ensureCapacityForAdditionalDataOfLength:bytesToRead];
                
                buffer = (uint8_t *)[currentRead->buffer mutableBytes]
                + currentRead->startOffset
                + currentRead->bytesDone;
            }
            
            // Read data into buffer
            
            int socketFD = (socket4FD != SOCKET_NULL) ? socket4FD : (socket6FD != SOCKET_NULL) ? socket6FD : socketUN;
            
            ssize_t result = read(socketFD, buffer, (size_t)bytesToRead);
            LogVerbose(@"read from socket = %i", (int)result);
            
            if (result < 0)
            {
                if (errno == EWOULDBLOCK)
                    waiting = YES;
                else
                    error = [self errnoErrorWithReason:@"Error in read() function"];
                
                socketFDBytesAvailable = 0;
            }
            else if (result == 0)
            {
                socketEOF = YES;
                socketFDBytesAvailable = 0;
            }
            else
            {
                bytesRead = result;
                
                if (bytesRead < bytesToRead)
                {
                    // The read returned less data than requested.
                    // This means socketFDBytesAvailable was a bit off due to timing,
                    // because we read from the socket right when the readSource event was firing.
                    socketFDBytesAvailable = 0;
                }
                else
                {
                    if (socketFDBytesAvailable <= bytesRead)
                        socketFDBytesAvailable = 0;
                    else
                        socketFDBytesAvailable -= bytesRead;
                }
                
                if (socketFDBytesAvailable == 0)
                {
                    waiting = YES;
                }
            }
        }
        
        if (bytesRead > 0)
        {
            // Check to see if the read operation is done
            
            if (currentRead->readLength > 0)
            {
                // Read type #2 - read a specific length of data
                //
                // Note: We should never be using a prebuffer when we're reading a specific length of data.
                
                NSAssert(readIntoPreBuffer == NO, @"Invalid logic");
                
                currentRead->bytesDone += bytesRead;
                totalBytesReadForCurrentRead += bytesRead;
                
                done = (currentRead->bytesDone == currentRead->readLength);
            }
            else if (currentRead->term != nil)
            {
                // Read type #3 - read up to a terminator
                
                if (readIntoPreBuffer)
                {
                    // We just read a big chunk of data into the preBuffer
                    
                    [preBuffer didWrite:bytesRead];
                    LogVerbose(@"read data into preBuffer - preBuffer.length = %zu", [preBuffer availableBytes]);
                    
                    // Search for the terminating sequence
                    
                    NSUInteger bytesToCopy = [currentRead readLengthForTermWithPreBuffer:preBuffer found:&done];
                    LogVerbose(@"copying %lu bytes from preBuffer", (unsigned long)bytesToCopy);
                    
                    // Ensure there's room on the read packet's buffer
                    
                    [currentRead ensureCapacityForAdditionalDataOfLength:bytesToCopy];
                    
                    // Copy bytes from prebuffer into read buffer
                    
                    uint8_t *readBuf = (uint8_t *)[currentRead->buffer mutableBytes] + currentRead->startOffset
                    + currentRead->bytesDone;
                    
                    memcpy(readBuf, [preBuffer readBuffer], bytesToCopy);
                    
                    // Remove the copied bytes from the prebuffer
                    [preBuffer didRead:bytesToCopy];
                    LogVerbose(@"preBuffer.length = %zu", [preBuffer availableBytes]);
                    
                    // Update totals
                    currentRead->bytesDone += bytesToCopy;
                    totalBytesReadForCurrentRead += bytesToCopy;
                    
                    // Our 'done' variable was updated via the readLengthForTermWithPreBuffer:found: method above
                }
                else
                {
                    // We just read a big chunk of data directly into the packet's buffer.
                    // We need to move any overflow into the prebuffer.
                    
                    NSInteger overflow = [currentRead searchForTermAfterPreBuffering:bytesRead];
                    
                    if (overflow == 0)
                    {
                        // Perfect match!
                        // Every byte we read stays in the read buffer,
                        // and the last byte we read was the last byte of the term.
                        
                        currentRead->bytesDone += bytesRead;
                        totalBytesReadForCurrentRead += bytesRead;
                        done = YES;
                    }
                    else if (overflow > 0)
                    {
                        // The term was found within the data that we read,
                        // and there are extra bytes that extend past the end of the term.
                        // We need to move these excess bytes out of the read packet and into the prebuffer.
                        
                        NSInteger underflow = bytesRead - overflow;
                        
                        // Copy excess data into preBuffer
                        
                        LogVerbose(@"copying %ld overflow bytes into preBuffer", (long)overflow);
                        [preBuffer ensureCapacityForWrite:overflow];
                        
                        uint8_t *overflowBuffer = buffer + underflow;
                        memcpy([preBuffer writeBuffer], overflowBuffer, overflow);
                        
                        [preBuffer didWrite:overflow];
                        LogVerbose(@"preBuffer.length = %zu", [preBuffer availableBytes]);
                        
                        // Note: The completeCurrentRead method will trim the buffer for us.
                        
                        currentRead->bytesDone += underflow;
                        totalBytesReadForCurrentRead += underflow;
                        done = YES;
                    }
                    else
                    {
                        // The term was not found within the data that we read.
                        
                        currentRead->bytesDone += bytesRead;
                        totalBytesReadForCurrentRead += bytesRead;
                        done = NO;
                    }
                }
                
                if (!done && currentRead->maxLength > 0)
                {
                    // We're not done and there's a set maxLength.
                    // Have we reached that maxLength yet?
                    
                    if (currentRead->bytesDone >= currentRead->maxLength)
                    {
                        error = [self readMaxedOutError];
                    }
                }
            }
            else
            {
                // Read type #1 - read all available data
                
                if (readIntoPreBuffer)
                {
                    // We just read a chunk of data into the preBuffer
                    
                    [preBuffer didWrite:bytesRead];
                    
                    // Now copy the data into the read packet.
                    //
                    // Recall that we didn't read directly into the packet's buffer to avoid
                    // over-allocating memory since we had no clue how much data was available to be read.
                    //
                    // Ensure there's room on the read packet's buffer
                    
                    [currentRead ensureCapacityForAdditionalDataOfLength:bytesRead];
                    
                    // Copy bytes from prebuffer into read buffer
                    
                    uint8_t *readBuf = (uint8_t *)[currentRead->buffer mutableBytes] + currentRead->startOffset
                    + currentRead->bytesDone;
                    
                    memcpy(readBuf, [preBuffer readBuffer], bytesRead);
                    
                    // Remove the copied bytes from the prebuffer
                    [preBuffer didRead:bytesRead];
                    
                    // Update totals
                    currentRead->bytesDone += bytesRead;
                    totalBytesReadForCurrentRead += bytesRead;
                }
                else
                {
                    currentRead->bytesDone += bytesRead;
                    totalBytesReadForCurrentRead += bytesRead;
                }
                
                done = YES;
            }
            
        } // if (bytesRead > 0)
        
    } // if (!done && !error && !socketEOF && hasBytesAvailable)
    
    
    if (!done && currentRead->readLength == 0 && currentRead->term == nil)
    {
        // Read type #1 - read all available data
        //
        // We might arrive here if we read data from the prebuffer but not from the socket.
        
        done = (totalBytesReadForCurrentRead > 0);
    }
    
    // Check to see if we're done, or if we've made progress
    
    if (done)
    {
        [self completeCurrentRead];
        
        if (!error && (!socketEOF || [preBuffer availableBytes] > 0))
        {
            [self maybeDequeueRead];
        }
    }
    else if (totalBytesReadForCurrentRead > 0)
    {
        // We're not done read type #2 or #3 yet, but we have read in some bytes
        //
        // We ensure that `waiting` is set in order to resume the readSource (if it is suspended). It is
        // possible to reach this point and `waiting` not be set, if the current read's length is
        // sufficiently large. In that case, we may have read to some upperbound successfully, but
        // that upperbound could be smaller than the desired length.
        waiting = YES;
        
        __strong id theDelegate = delegate;
        
        if (delegateQueue && [theDelegate respondsToSelector:@selector(socket:didReadPartialDataOfLength:tag:)])
        {
            long theReadTag = currentRead->tag;
            
            dispatch_async(delegateQueue, ^{ @autoreleasepool {
                
                [theDelegate socket:self didReadPartialDataOfLength:totalBytesReadForCurrentRead tag:theReadTag];
            }});
        }
    }
    
    // Check for errors
    
    if (error)
    {
        [self closeWithError:error];
    }
    else if (socketEOF)
    {
        [self doReadEOF];
    }
    else if (waiting)
    {
        if (![self usingCFStreamForTLS])
        {
            // Monitor the socket for readability (if we're not already doing so)
            [self resumeReadSource];
        }
    }
    
    // Do not add any code here without first adding return statements in the error cases above.
}

@end
