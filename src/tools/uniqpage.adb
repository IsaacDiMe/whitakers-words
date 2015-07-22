-- WORDS, a Latin dictionary, by Colonel William Whitaker (USAF, Retired)
--
-- Copyright William A. Whitaker (1936–2010)
--
-- This is a free program, which means it is proper to copy it and pass
-- it on to your friends. Consider it a developmental item for which
-- there is no charge. However, just for form, it is Copyrighted
-- (c). Permission is hereby freely given for any and all use of program
-- and data. You can sell it as your own, but at least tell me.
--
-- This version is distributed without obligation, but the developer
-- would appreciate comments and suggestions.
--
-- All parts of the WORDS system, source code and data files, are made freely
-- available to anyone who wishes to use them, for whatever purpose.

with Text_IO;
with Latin_Utils.Strings_Package; use Latin_Utils.Strings_Package;
-- with Latin_Utils.Latin_File_Names; use Latin_Utils.Latin_File_Names;
with Latin_Utils.Inflections_Package; use Latin_Utils.Inflections_Package;
with Latin_Utils.Dictionary_Package; use Latin_Utils.Dictionary_Package;
-- with line_stuff; use line_stuff;
-- with dictionary_form;
procedure uniqpage is

--   package Integer_IO is new Text_IO.Integer_IO (Integer);
   use Text_IO;
   use Dictionary_Entry_IO;
   use Part_Entry_IO;
   use Kind_Entry_IO;
   use Translation_Record_IO;
   use Age_Type_IO;
   use Area_Type_IO;
   use Geo_Type_IO;
   use Frequency_Type_IO;
   use Source_Type_IO;

   uniques_file, uniqpage : Text_IO.File_Type;

   s : constant String (1 .. 400) := (others => ' ');
   line : String (1 .. 400) := (others => ' ');
   blanks : constant String (1 .. 400) := (others => ' ');
   l, last : Integer := 0;

   stem : Stem_Type := Null_Stem_Type;
   qual : quality_record;
   kind : Kind_Entry;
   tran : Translation_Record;
   mean : Meaning_Type;

   procedure get_line_unique
     (input : in Text_IO.File_Type;
      s     : out String;
      last  : out Natural)
   is
   begin
      last := 0;
      Text_IO.Get_Line (input, s, last);
      -- FIXME: this if statement was commented out, because it triggered
      -- warning "if statement has no effect". I didn't delete it because quite
      -- possibly author wanted it to do something. Question is what?
      --if Trim (s (s'First .. last)) /= ""  then   --  Rejecting blank lines
      --   null;
      --end if;
   end get_line_unique;

begin
   Put_Line ("UNIQUES.LAT -> UNIQPAGE.PG");
   Put_Line ("Takes UNIQUES form, single lines it, puts # at begining,");
   Put_Line ("producing a .PG file for sorting to produce paper dictionary");
   Create (uniqpage, Out_File, "UNIQPAGE.PG");
   Open (uniques_file, In_File, "UNIQUES.LAT");

   Over_Lines :
   while not End_Of_File (uniques_file)  loop
      line := blanks;
      get_line_unique (uniques_file, line, last);      --  STEM
      stem := Head (Trim (line (1 .. last)), Max_Stem_Size);

      line := blanks;
      get_line_unique (uniques_file, line, last);    --  QUAL, KIND, TRAN
      quality_record_io.Get (line (1 .. last), qual, l);
      Get (line (l + 1 .. last), qual.pofs, kind, l);
      Age_Type_IO.Get (line (l + 1 .. last), tran.Age, l);
      Area_Type_IO.Get (line (l + 1 .. last), tran.Area, l);
      Geo_Type_IO.Get (line (l + 1 .. last), tran.Geo, l);
      Frequency_Type_IO.Get (line (l + 1 .. last), tran.Freq, l);
      Source_Type_IO.Get (line (l + 1 .. last), tran.Source, l);

      line := blanks;
      get_line_unique (uniques_file, line, l);         --  MEAN
      mean := Head (Trim (line (1 .. l)), Max_Meaning_Size);

      --      while not END_OF_FILE (UNIQUES_FILE) loop
      --         S := BLANK_LINE;
      --         GET_LINE (INPUT, S, LAST);
      --         if TRIM (S (1 .. LAST)) /= ""  then   --  Rejecting blank lines
      --
      --

      Text_IO.Put (uniqpage, "#" & stem);

      quality_record_io.Put (uniqpage, qual);

      -- PART := (V, (QUAL.V.CON, KIND.V_KIND));

      if (qual.pofs = V)  and then  (kind.v_kind in Gen .. Perfdef)  then
         Text_IO.Put (uniqpage, "  " &
           Verb_Kind_Type'Image (kind.v_kind) & "  ");
      end if;

      Text_IO.Put (uniqpage, " [");
      Age_Type_IO.Put (uniqpage, tran.Age);
      Area_Type_IO.Put (uniqpage, tran.Area);
      Geo_Type_IO.Put (uniqpage, tran.Geo);
      Frequency_Type_IO.Put (uniqpage, tran.Freq);
      Source_Type_IO.Put (uniqpage, tran.Source);
      Text_IO.Put (uniqpage, "]");

      Put (uniqpage, " :: ");
      Put_Line (uniqpage, mean);

      --end if;  --  Rejecting blank lines
   end loop Over_Lines;

   Close (uniqpage);
exception
   when Text_IO.Data_Error  =>
      null;
   when others =>
      Put_Line (s (1 .. last));
      Close (uniqpage);

end uniqpage;