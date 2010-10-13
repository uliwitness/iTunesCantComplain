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

	CGFloat		scaleFactor = [self bounds].size.height / 768.0;
	
	NS_DURING
		NSDictionary*	bigAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont boldSystemFontOfSize: 24 * scaleFactor], NSFontAttributeName,
										[NSColor whiteColor], NSForegroundColorAttributeName,
										nil];
		NSDictionary*	smAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont boldSystemFontOfSize: 18 * scaleFactor], NSFontAttributeName,
										[NSColor whiteColor], NSForegroundColorAttributeName,
										nil];
		NSDictionary*	tinyAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont systemFontOfSize: 18 * scaleFactor], NSFontAttributeName,
										[NSColor whiteColor], NSForegroundColorAttributeName,
										nil];
		NSDictionary*	paleAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSFont systemFontOfSize: 18 * scaleFactor], NSFontAttributeName,
										[[NSColor lightGrayColor] colorWithAlphaComponent: 0.7], NSForegroundColorAttributeName,
										nil];
		
		// Draw cover image with track info:
		NSRect	desiredBox = NSMakeRect(imagePos.x,imagePos.y,0,0);
		if( [self currTrackArt] )
		{
			desiredBox.size = [[self currTrackArt] size];
			desiredBox.size.width *= ((330.0f * scaleFactor) / desiredBox.size.height);
			desiredBox.size.height = (330.0f * scaleFactor);
			[[self currTrackArt] drawInRect: desiredBox fromRect: NSZeroRect operation: NSCompositeSourceAtop fraction: 1.0];
		}
		
		[currTrackName drawAtPoint: NSMakePoint(desiredBox.origin.x,desiredBox.origin.y + (390.0f * scaleFactor)) withAttributes: bigAttrs];
		[currTrackArtist drawAtPoint: NSMakePoint(desiredBox.origin.x,desiredBox.origin.y + (370.0f * scaleFactor)) withAttributes: smAttrs];
		[currTrackAlbum drawAtPoint: NSMakePoint(desiredBox.origin.x,desiredBox.origin.y + (340.0f * scaleFactor)) withAttributes: tinyAttrs];
		
		// Indicate playback progress:
		NSRect		progressBox = NSMakeRect(NSMinX(desiredBox), NSMinY(desiredBox) -(24.0 * scaleFactor), desiredBox.size.width, (12.0 *scaleFactor));
		[[NSColor whiteColor] set];
		[NSBezierPath strokeRect: progressBox];
		progressBox.size.width *= [self currTrackPercentage];
		[NSBezierPath fillRect: progressBox];
		
		// Draw lyrics, pale and transparent on top of any track image:
		if( currTrackLyrics )
		{
			NSPoint		lyricsPos = NSMakePoint(10,10);
			lyricsPos.y -= ([currTrackLyrics sizeWithAttributes: paleAttrs].height -[self bounds].size.height +20) * (1.0 -[self currTrackPercentage]);
			[currTrackLyrics drawAtPoint: lyricsPos withAttributes: paleAttrs];
		}
	NS_HANDLER
		NSLog( @"iTunesCantComplain: Error %@", [localException reason] );
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
		
		NS_DURING
			[self setCurrTrackArt: [(iTunesArtwork*)[theImages objectAtIndex: 0] data]];
		NS_HANDLER
			[self setCurrTrackArt: nil];
			NSLog( @"iTunesCantComplain: Error %@", [localException reason] );
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
			NSLog( @"iTunesCantComplain: Error %@", [localException reason] );
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
		NSLog( @"iTunesCantComplain: Error %@", [localException reason] );
	NS_ENDHANDLER
}

@end
