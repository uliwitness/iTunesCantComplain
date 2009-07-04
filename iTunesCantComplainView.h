//
//  iTunesCantComplainView.h
//  iTunesCantComplain
//
//  Created by Uli Kusterer on 24.04.08.
//  Copyright (c) 2008, The Void Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>


@interface iTunesCantComplainView : ScreenSaverView 
{
	NSImage*		currTrackArt;
	NSString*		currTrackArtist;
	NSString*		currTrackAlbum;
	NSString*		currTrackName;
	NSString*		currTrackLyrics;
	NSPoint			imagePos;
	float			currTrackPercentage;
}

@property(retain)	NSImage* currTrackArt;
@property(retain)	NSString* currTrackArtist;
@property(retain)	NSString* currTrackAlbum;
@property(retain)	NSString* currTrackName;
@property(retain)	NSString* currTrackLyrics;
@property			float currTrackPercentage;
@property			NSPoint imagePos;

-(void)	iTunesTrackChanged: (NSNotification*)notif;

@end
