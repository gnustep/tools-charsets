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
  int	i;
  int	c;
  FILE	*o;

  if (argc < 2)
    {
      fprintf(stderr, "Expecting names of data files to convert\n");
      return 1;
    }
  o = fopen("NSCharacterSetData.h", "w");
  for (i = 1; i < argc; i++)
    {
      FILE	*f;
      char	name[BUFSIZ];
      int	j;
      int	sep = '{';
      long	len;

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
      fprintf(o, "static const unsigned char %s[%d] = ", name, len);
      while ((c = fgetc(f)) != EOF)
	{
	  fprintf(o, "%c\n'\\x%02x'", sep, c);
	  sep = ',';
	}
      fprintf(o,"};\n");
      fclose(f);
    }
  fclose(o);
  return 0;
}

