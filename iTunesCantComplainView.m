//
//  iTunesCantComplainView.m
//  iTunesCantComplain
//
//  Created by Uli Kusterer on 24.04.08.
//  Copyright (c) 2008, The Void Software. All rights reserved.
//

#import "iTunesCantComplainView.h"
#import "iTunes.h"


@implementation iTunesCantComplainView

@synthesize currTrackArt;
@synthesize currTrackAlbum;
@synthesize currTrackName;
@synthesize currTrackArtist;
@synthesize currTrackLyrics;
@synthesize currTrackPercentage;
@synthesize imagePos;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self)
	{
        [self setAnimationTimeInterval: 4];
		
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self 
			selector: @selector(iTunesTrackChanged:) 
			name: @"com.apple.iTunes.playerInfo" 
			object: nil];
		
		srand( time(NULL) );
    }
    return self;
}


-(void)	dealloc
{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver: self
											name: @"com.apple.iTunes.playerInfo"
											object: nil];
	
	[currTrackArt release];
	[currTrackArtist release];
	[currTrackAlbum release];
	[currTrackName release];
	[currTrackLyrics release];
	
	[super dealloc];
}

- (void)startAnimation
{
    [super startAnimation];
	
	[self iTunesTrackChanged: nil];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect: (NSRect)rect
{
    [super drawRect: rect];

	CGFloat			scaleFactor = [self bounds].size.height / 768.0;
	NSDictionary*	bigAttrs = nil;
	NSDictionary*	smAttrs = nil;
	NSDictionary*	tinyAttrs = nil;
	NSDictionary*	paleAttrs = nil;
	
	NS_DURING
		bigAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont boldSystemFontOfSize: 24 * scaleFactor], NSFontAttributeName,
										[NSColor whiteColor], NSForegroundColorAttributeName,
										nil];
		smAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont boldSystemFontOfSize: 18 * scaleFactor], NSFontAttributeName,
										[NSColor whiteColor], NSForegroundColorAttributeName,
										nil];
		tinyAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont systemFontOfSize: 18 * scaleFactor], NSFontAttributeName,
										[NSColor whiteColor], NSForegroundColorAttributeName,
										nil];
		paleAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont systemFontOfSize: 18 * scaleFactor], NSFontAttributeName,
										[[NSColor lightGrayColor] colorWithAlphaComponent: 0.7], NSForegroundColorAttributeName,
										nil];
	NS_HANDLER
		NSLog( @"iTunesCantComplain: %s(1) Error %@", __PRETTY_FUNCTION__, [localException reason] );
	NS_ENDHANDLER
	
	NSRect	desiredBox = { 0 };
	NS_DURING
		// Draw cover image with track info:
		desiredBox = NSMakeRect(imagePos.x,imagePos.y,0,0);
		if( [self currTrackArt] && [[self currTrackArt] isKindOfClass: [NSImage class]] )
		{
			desiredBox.size = [[self currTrackArt] size];
			desiredBox.size.width *= ((330.0f * scaleFactor) / desiredBox.size.height);
			desiredBox.size.height = (330.0f * scaleFactor);
			[[self currTrackArt] drawInRect: desiredBox fromRect: NSZeroRect operation: NSCompositeSourceAtop fraction: 1.0];
		}
		else if( [self currTrackArt] != nil )
			NSLog( @"curr track art = %@", [self currTrackArt] );
		
//		if( desiredBox.size.width <= 100.0 )
//		{
//			desiredBox.size.height = 300.0f * scaleFactor;
//			desiredBox.size.width = 300.0f * scaleFactor;
//			[[NSColor colorWithCalibratedWhite: 1.0 alpha: 0.5] set];
//			NSRectFill(desiredBox);
//		}
		
		NSLog( @"iTunesCantComplain: %s coverArtSize = %@", __PRETTY_FUNCTION__, NSStringFromSize( desiredBox.size ) );
	NS_HANDLER
		NSLog( @"iTunesCantComplain: %s(2) Error %@", __PRETTY_FUNCTION__, [localException reason] );
	NS_ENDHANDLER
	
	NS_DURING	
		[currTrackName drawAtPoint: NSMakePoint(desiredBox.origin.x,desiredBox.origin.y + (390.0f * scaleFactor)) withAttributes: bigAttrs];
		[currTrackArtist drawAtPoint: NSMakePoint(desiredBox.origin.x,desiredBox.origin.y + (370.0f * scaleFactor)) withAttributes: smAttrs];
		[currTrackAlbum drawAtPoint: NSMakePoint(desiredBox.origin.x,desiredBox.origin.y + (340.0f * scaleFactor)) withAttributes: tinyAttrs];
		
		// Indicate playback progress:
		NSRect		progressBox = NSMakeRect(NSMinX(desiredBox), NSMinY(desiredBox) -(24.0 * scaleFactor), desiredBox.size.width, (12.0 *scaleFactor));
		[[NSColor colorWithCalibratedWhite: 1.0 alpha: 0.3] set];
		[NSBezierPath fillRect: progressBox];
		[[NSColor whiteColor] set];
		progressBox.size.width *= [self currTrackPercentage];
		[NSBezierPath fillRect: progressBox];
		
		// Draw lyrics, pale and transparent on top of any track image:
		if( currTrackLyrics && [currTrackLyrics isKindOfClass: [NSString class]] )
		{
			NSPoint		lyricsPos = NSMakePoint(10,100);
			lyricsPos.y -= ([currTrackLyrics sizeWithAttributes: paleAttrs].height -[self bounds].size.height +20 +200) * (1.0 -[self currTrackPercentage]);
			[currTrackLyrics drawAtPoint: lyricsPos withAttributes: paleAttrs];
		}
	NS_HANDLER
		NSLog( @"iTunesCantComplain: %s(3) Error %@", __PRETTY_FUNCTION__, [localException reason] );
	NS_ENDHANDLER
}

- (void)animateOneFrame
{
	[self iTunesTrackChanged: nil];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}


-(void)	iTunesTrackChanged: (NSNotification*)notif
{
	NS_DURING
		iTunesApplication*	itunes = [SBApplication applicationWithBundleIdentifier: @"com.apple.iTunes"];
		iTunesTrack*		currTrack = [itunes currentTrack];
		NSArray*			theImages = [[currTrack artworks] get];
		NSString*			imgPath = [[NSBundle bundleForClass: [self class]] pathForImageResource: @"NoAlbumArt"];
		NSImage*			noAlbumArt = [[[NSImage alloc] initWithContentsOfFile: imgPath] autorelease];
		
		NS_DURING
			if( [theImages count] > 0 )
			{
				NSImage	*	possibleImage = [(iTunesArtwork*)[theImages objectAtIndex: 0] data];
				if( [possibleImage isKindOfClass: [NSAppleEventDescriptor class]] )
					possibleImage = [[[NSImage alloc] initWithData: [(NSAppleEventDescriptor*)possibleImage data]] autorelease];
				[self setCurrTrackArt: possibleImage];
			}
			else
				[self setCurrTrackArt: noAlbumArt];
		NS_HANDLER
			[self setCurrTrackArt: noAlbumArt];
			NSLog( @"iTunesCantComplain: %s(1) Error %@", __PRETTY_FUNCTION__, [localException reason] );
		NS_ENDHANDLER
		[self setCurrTrackArtist: [currTrack artist]];
		[self setCurrTrackAlbum: [currTrack album]];
		[self setCurrTrackName: [currTrack name]];
		float		duration = [currTrack finish] -[currTrack start];
		float		percentage = [itunes playerPosition] -[currTrack start];
		percentage /= duration;
		[self setCurrTrackPercentage: percentage];
		NS_DURING
			[self setCurrTrackLyrics: [currTrack lyrics]];
		NS_HANDLER
			[self setCurrTrackLyrics: nil];
			NSLog( @"iTunesCantComplain: %s(2) Error %@", __PRETTY_FUNCTION__, [localException reason] );
		NS_ENDHANDLER
		[self setNeedsDisplay: YES];
		
		CGFloat	scaleFactor = [self bounds].size.height / 768.0;
		int		availWidth = [self bounds].size.width -(420.0 * scaleFactor);
		float	leftMin = 10;
		if( [self currTrackLyrics] && [[self currTrackLyrics] length] > 0 )
		{
			availWidth /= 2;
			leftMin += availWidth;
		}
		
		imagePos = NSMakePoint( leftMin +(rand() % availWidth),
								10 +(rand() % ((int)([self bounds].size.height -(420.0 * scaleFactor)))) );
	NS_HANDLER
		NSLog( @"iTunesCantComplain: %s(3) Error %@", __PRETTY_FUNCTION__, [localException reason] );
	NS_ENDHANDLER
}

@end
