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

@property(strong)	NSImage* currTrackArt;
@property(strong)	NSString* currTrackArtist;
@property(strong)	NSString* currTrackAlbum;
@property(strong)	NSString* currTrackName;
@property(strong)	NSString* currTrackLyrics;
@property			float currTrackPercentage;
@property			NSPoint imagePos;

-(void)	iTunesTrackChanged: (NSNotification*)notif;

@end
