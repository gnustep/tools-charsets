/* mkcharsets.m: A utility to create bitmaps for the standard character sets.
   Copyright (C) 2001,2006 Free Software Foundation, Inc.

   Written by:  Jonathan Gapen  <jagapen@home.com>
   Date: March 2001
   Update by: Richard Frith-Macdonald <rfm@gnu.org>

   This file is part of GNUstep.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import <Foundation/Foundation.h>
#import <libgnustep-ucsdata/GSUnicodeData.h>
#import <libgnustep-ucsdata/GSUniChar.h>

int main(int argc, char *argv[])
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  GSUnicodeData *ud;
  NSEnumerator *enumerator;
  GSUniChar *ucdEntry;
  NSMutableCharacterSet *alnumSet, *controlSet, *dDigitSet, *decompSet;
  NSMutableCharacterSet *illegalSet, *letterSet, *lCaseSet, *nonBaseSet;
  NSMutableCharacterSet *puncSet, *symbolSet, *tCaseSet, *uCaseSet;
  NSMutableCharacterSet *whiteSet;
  NSString *decompMap;
  NSData *bitmap;

  ud = [GSUnicodeData dataWithContentsOfFile: @"UnicodeData.txt"];
  if (ud == nil)
    {
      ud = [GSUnicodeData unicodeData];
    }
  if (ud == nil)
    {
      NSLog(@"Error getting Unicode database object.");
      [arp release];
      exit(0);
    }

  alnumSet = [NSMutableCharacterSet new];
  controlSet = [NSMutableCharacterSet new];
  dDigitSet = [NSMutableCharacterSet new];
  decompSet = [NSMutableCharacterSet new];
  illegalSet = [NSMutableCharacterSet new];
  [illegalSet invert];
  letterSet = [NSMutableCharacterSet new];
  lCaseSet = [NSMutableCharacterSet new];
  nonBaseSet = [NSMutableCharacterSet new];
  puncSet = [NSMutableCharacterSet new];
  symbolSet = [NSMutableCharacterSet new];
  uCaseSet = [NSMutableCharacterSet new];
  tCaseSet = [NSMutableCharacterSet new];
  whiteSet = [NSMutableCharacterSet new];

  enumerator = [ud objectEnumerator];
  while ((ucdEntry = [enumerator nextObject]))
    {
      NSRange range = [ucdEntry range];
      UCDGeneralCategory category = [ucdEntry generalCategory];

      [illegalSet removeCharactersInRange: range];

      switch (category)
        {
          case UCDLetterUppercaseCategory:
            [uCaseSet addCharactersInRange: range];
            break;
          case UCDLetterLowercaseCategory:
            [lCaseSet addCharactersInRange: range];
            break;
          case UCDLetterTitlecaseCategory:
            [tCaseSet addCharactersInRange: range];
            break;
          case UCDLetterModifierCategory:
          case UCDMarkNonSpacingCategory:
          case UCDMarkSpacingCombiningCategory:
          case UCDMarkEnclosingCategory:
            [nonBaseSet addCharactersInRange: range];
            break;
          case UCDNumberLetterCategory:
          case UCDNumberOtherCategory:
            [letterSet addCharactersInRange: range];
            break;
          case UCDSeparatorSpaceCategory:
          case UCDSeparatorLineCategory:
          case UCDSeparatorParagraphCategory:
            [whiteSet addCharactersInRange: range];
            break;
          case UCDControlCategory:
            [controlSet addCharactersInRange: range];
            break;
          case UCDNumberDecimalDigitCategory:
            [dDigitSet addCharactersInRange: range];
            break;
          case UCDLetterOtherCategory:
            [letterSet addCharactersInRange: range];
            break;
          case UCDPunctuationConnectorCategory:
          case UCDPunctuationDashCategory:
          case UCDPunctuationOpenCategory:
          case UCDPunctuationCloseCategory:
          case UCDPunctuationInitialQuoteCategory:
          case UCDPunctuationFinalQuoteCategory:
          case UCDPunctuationOtherCategory:
            [puncSet addCharactersInRange: range];
            break;
          case UCDSymbolMathCategory:
          case UCDSymbolCurrencyCategory:
          case UCDSymbolModifierCategory:
          case UCDSymbolOtherCategory:
            [symbolSet addCharactersInRange: range];
            break;
	  case UCDNotAssignedCategory:
	  case UCDFormatCategory:
	  case UCDSurrogateCategory:
	  case UCDPrivateUseCategory:
	    break;
        }

      decompMap = [ucdEntry decompositionMapping];
      if ([decompMap isEqualToString: @""] == NO)
        [decompSet addCharactersInRange: range];
    }

  [letterSet formUnionWithCharacterSet: lCaseSet];
  [letterSet formUnionWithCharacterSet: uCaseSet];
  [letterSet formUnionWithCharacterSet: tCaseSet];
  [letterSet formUnionWithCharacterSet: nonBaseSet];

  [alnumSet formUnionWithCharacterSet: letterSet];
  [alnumSet formUnionWithCharacterSet: dDigitSet];

  bitmap = [alnumSet bitmapRepresentation];
  [bitmap writeToFile: @"alphanumericCharSet.dat" atomically: NO];

  bitmap = [controlSet bitmapRepresentation];
  [bitmap writeToFile: @"controlCharSet.dat" atomically: NO];

  bitmap = [dDigitSet bitmapRepresentation];
  [bitmap writeToFile: @"decimalDigitCharSet.dat" atomically: NO];

  bitmap = [decompSet bitmapRepresentation];
  [bitmap writeToFile: @"decomposableCharSet.dat" atomically: NO];

  bitmap = [illegalSet bitmapRepresentation];
  [bitmap writeToFile: @"illegalCharSet.dat" atomically: NO];

  bitmap = [letterSet bitmapRepresentation];
  [bitmap writeToFile: @"letterCharSet.dat" atomically: NO];

  bitmap = [lCaseSet bitmapRepresentation];
  [bitmap writeToFile: @"lowercaseLetterCharSet.dat" atomically: NO];

  bitmap = [nonBaseSet bitmapRepresentation];
  [bitmap writeToFile: @"nonBaseCharSet.dat" atomically: NO];

  bitmap = [puncSet bitmapRepresentation];
  [bitmap writeToFile: @"punctuationCharSet.dat" atomically: NO];

  bitmap = [symbolSet bitmapRepresentation];
  [bitmap writeToFile: @"symbolAndOperatorCharSet.dat" atomically: NO];

  bitmap = [uCaseSet bitmapRepresentation];
  [bitmap writeToFile: @"uppercaseLetterCharSet.dat" atomically: NO];

  bitmap = [tCaseSet bitmapRepresentation];
  [bitmap writeToFile: @"titlecaseLetterCharSet.dat" atomically: NO];

  // Unicode calls tab a control character; we call it whitespace
  [whiteSet addCharactersInRange: NSMakeRange(0x09, 1)];

  bitmap = [whiteSet bitmapRepresentation];
  [bitmap writeToFile: @"whitespaceCharSet.dat" atomically: NO];

  // Add lines breaks: CR and LF
  [whiteSet addCharactersInRange: NSMakeRange(0x0A, 1)];
  [whiteSet addCharactersInRange: NSMakeRange(0x0D, 1)];
  // Also nextline
  [whiteSet addCharactersInRange: NSMakeRange(0x85, 1)];

  bitmap = [whiteSet bitmapRepresentation];
  [bitmap writeToFile: @"whitespaceAndNlCharSet.dat" atomically: NO];

  [arp release];
  return 0;
}
