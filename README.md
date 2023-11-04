# srt-translater

    Super fast srt translater and mkv extracter, extract subtitles from mvk ,
    and translate into desired language in 20-40 sec.

    use as cli tool ,or add it Nzbget as post-processing scripts (supported)

    This is version 1.0, so there is probably buggy :)
    
    If you find a bug , please create an Issue 
    https://github.com/pulsejets/srt-translater/issues

# Requrements
    - mkvtoolnix (mkvmerge and mkvextract)
     -jq

# How to Install 

    1. git clone git@github.com:pulsejets/srt-translater.git
    2. chmod +x translater.sh

# How to use

 ./translater.sh -f < file > [options]
 
   Options:
    -f          -[Mandatory]    MKV,SRT or Directory 
  
    -s          -[Optinal]      language to use when it extract subtitles form MKV file ISO-639-1 format
                                (https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 
                                if not set it will use default value in script,en (english)
  
    -t          -[Optinal]      language you want to translate into , ISO-639-1 format 
                                if not set it will use default value in script,sv (sewdish)
  
    -w          -[Optinal]      Temp dir
    
    -Z          -[Optinal]      How many part the substracted srt file should be split into. aka how many google       
                                translate background job there will be created
  
    -M          -[Optinal]      Process all MKV files in directory ,if -f  is a directory

    -S          -[Optinal]      Process all SRT files in directory ,if -f  is a directory
    
    -o          -[Optinal]      Overwrite srt file at distination ,same location ad the mkv/srt file  

    -v          -[Optinal]      print more info 

    -d          -[Optinal]      Debug mode 
     



# Example how to use 

        example  translater.sh "Movies/MovieName  (2000)/MovieName (2000).mkv" -s en -t nl

        This will estract SRT file from MovieName (2000).mkv transelate it into Dutch,
        and place a SRT file in folder Movies/MovieName  (2000) , with name MovieName (2000).nl.srt

        example  translater.sh "Movies/" -s en -t nl -M

        Will find all MKV files in directory and sub directory , and extract subtile and translate it
        and place it in the folder the MKV file was found 

# Disclaimer

    The script uses translate.googleapis.com, and it hits it hard when alot translate background processes is created
    if this can result in blocking or throttling I don't know 

# Limitation 
    
    The script only supports srt codec , no Vobsub support yet 


# Todo

    - Add support for other subtitle codec 
    - Add support for merge translated subtitle back into mkv file 
