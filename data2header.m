/*
   A trivial program to read characterset data files and produce an ObjC
   header file to be included into NSCharacterSet.m
   Pass it the names of the data files as arguments.
  
   Copyright (C) 2005 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald  <rfm@gnu.org>
   Date: March 2005

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

#include	<stdio.h>
#include	<string.h>

int
main(int argc, char **argv)
{
  /* If we want output to be a character/range per line we set eol to "\n",
   * otherwise (normally) the output is an entire characterset on one line.
   */
  const char    *eol = "";
  int	        i;
  int	        c;
  FILE	        *o;

  if (argc < 2)
    {
      fprintf(stderr, "Expecting names of data files to convert\n");
      return 1;
    }
  o = fopen("NSCharacterSetData.h", "w");
  fprintf(o, "/*\n");
  fprintf(o, " * THIS FILE WAS GENERATED AUTOMATICALLY BY data2header.m\n");
  fprintf(o, " * PLEASE DO NOT EDIT IT DIRECTLY.\n");
  fprintf(o, " * You can find data2header.m at\n");
  fprintf(o, " * http://svn.gna.org/viewcvs/gnustep/tools/charsets/\n");
  fprintf(o, " * The characterset rule tables for Unicode handling are\n");
  fprintf(o, " * really rather large, so the bitmaps are converted into\n");
  fprintf(o, " * constant data compiled into the GNUstep base library\n");
  fprintf(o, " * and are therefore shared between all running GNUstep\n");
  fprintf(o, " * applications, reducing the overall memory usage of a\n");
  fprintf(o, " * gnustep system and speeding up startup of GNUstep\n");
  fprintf(o, " * processes.\n");
  fprintf(o, " */\n");
  for (i = 1; i < argc; i++)
    {
      FILE	*f;
      char	name[BUFSIZ];
      int	findingLocation = 1;
      unsigned	location;
      unsigned	length;
      int	j;
      int	sep = '{';
      int	len;

      strcpy(name, argv[i]);
      j = strlen(name) - 4;
      if (j < 0 || strcmp(&name[j], ".dat") != 0)
	{
	  fprintf(stderr, "Bad file name '%s'\n", name);
	  return 1;
	}
      f = fopen(name, "r");
      if (f == NULL)
	{
	  fprintf(stderr, "Unable to read '%s'\n", name);
	  return 1;
	}
      if (fseek(f, 0, SEEK_END) != 0)
	{
	  fprintf(stderr, "Unable to seek to end of '%s'\n", name);
	  return 1;
	}
      len = ftell(f);
      if (fseek(f, 0, SEEK_SET) != 0)
	{
	  fprintf(stderr, "Unable to seek to start of '%s'\n", name);
	  return 1;
	}
      if (len == 0 || len % 8192 != 0)
	{
	  fprintf(stderr, "Length of '%s' is not a multiple of 8192\n", name);
	  return 1;
	}
      name[j] = '\0';

      fprintf(o, "#if defined(GNUSTEP_INDEX_CHARSET)\n");
      fprintf(o, "static const NSRange %s[] = ", name);
      j = 0;
      while ((c = fgetc(f)) != EOF)
	{
	  unsigned char	byte = (unsigned char)c;

	  if (byte == 0)
	    {
	      if (findingLocation == 0)
		{
		  length = j - location;
		  fprintf(o, "%c%s{%u,%u}", sep, eol, location, length);
		  sep = ',';
		  findingLocation = 1;
		}
	      j += 8;
	    }
	  else if (byte == 0xff)
	    {
	      if (findingLocation == 1)
		{
		  location = j;
		  findingLocation = 0;
		}
	      j += 8;
	    }
	  else
	    {
	      unsigned int	bit;

	      for (bit = 1; bit & 0xff; bit <<= 1)
		{
		  if ((byte & bit) == 0)
		    {
		      if (findingLocation == 0)
			{
			  length = j - location;
			  fprintf(o, "%c%s{%u,%u}", sep, eol, location, length);
			  sep = ',';
			  findingLocation = 1;
			}
		    }
		  else
		    {
		      if (findingLocation == 1)
			{
			  location = j;
			  findingLocation = 0;
			}
		    }
		  j++;
		}
	    }
	}
      if (findingLocation == 0)
	{
	  length = j - location;
	  fprintf(o, "%c%s{%u,%u}", sep, eol, location, length);
	  sep = ',';
	}
      fprintf(o,"};\n");
      fprintf(o, "#else /* GNUSTEP_INDEX_CHARSET */\n");
      if (fseek(f, 0, SEEK_SET) != 0)
	{
	  fprintf(stderr, "Unable to seek back to start of file\n");
	  return 1;
	}
      fprintf(o, "static const unsigned char %s[%d] = ", name, len);
      sep = '{';
      while ((c = fgetc(f)) != EOF)
	{
	  fprintf(o, "%c%s'\\x%02x'", sep, eol, c);
	  sep = ',';
	}
      fprintf(o,"};\n");
      fprintf(o, "#endif /* GNUSTEP_INDEX_CHARSET */\n");

      fclose(f);
    }
  fclose(o);
  return 0;
}

