#!/bin/bash
##############################################################################
### NZBGET POST-PROCESSING SCRIPT                                           ###

# SRT translater
#
# This is a script extrace srt subtitles from mkv file and translate it into
# disired language using google translate
#
# the translated srt files will be placed in sam folder as the mkv file
#
# Info about srt translater:
# Author: Kenneth Moller (k@gmail.com).
# Web-site: github.com
# License: GPLv3 (http://www.gnu.org/licenses/gpl.html).
# srt tranlator  Version: 1.0.
#
# NOTE: This script requires mkvmerge,mkvextract an jq to be installed on your system.

##############################################################################
### OPTIONS                                                                   ###

# source langanguage, 
#
# what language of subtitles shall it extract from the mkv file , that is 
# use for the souce to translate.
#
# it uses ISO 639-1 languge code  ex. en,nl,sv 
# https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
#SourceLang=en

# distination langanguage, 
#
# what language shall it translate into 
#
# # it uses ISO 639-1 languge code  ex. en,nl,sv 
# https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
#DestinationLang=nl

#Directory to store temporary files.
# 
# Directory to store temporary files.
#
#TempDir=TempDir${MainDir}/tmp

# Print more logging messages (yes, no).
#
# For debugging or if you need to report a bug
# 
#Verbose=yes
#

### NZBGET POST-PROCESSING SCRIPT                                           ###
##############################################################################

#nzb exit codes

nzblog_warning=""
nzblog_error=""
nzblog_info=""
nzblog_detail=""

exit_success=0
exit_error=1
exit_skip=0

SECONDS=0
file=""
target_language="da"
source_language="en"
working_directory="tmp"
ISO_639_list="ISO_639.csv"
nzb_script_dir=""
split=50
overwrite=false
scan=false
scan_type="mkv"
passon_args=""
verbose=false
debug=false


debug() {
    if [ "$debug" == "true" ]; then 
        echo  "DEBUG : $1"
    fi
    }

verbose(){
 if [ "$verbose" == "true" ]; then 

    echo -e "$nzblog_detail $1\n"
    fi

}

if [ -n "$NZBPP_FINALDIR" ]; then

     
     nzb_script_dir="$NZBOP_SCRIPTDIR/"
    file="$(find "$NZBPP_FINALDIR" -type f -name "*.mkv")"
    working_directory="$NZBOP_TEMPDIR"
    target_language="$NZBPO_DestinationLang"
    source_language="$NZBPO_SourceLang"
    nzblog_warning="[WARNING]"
    nzblog_error="[ERROR]"
    nzblog_info="[INFO]"
    nzblog_detail="[DETAIL]"
    exit_success=93
    exit_error=94
    exit_skip=95
    echo "$nzblog_info Processing  : $file"
    if [$Verbose ="yes"];then
    verbose="true"
    else
    verbose="false"
    fi
else
    
   
    # Define usage function
    usage() {
    echo -n "Usage: $0"
    echo -n " -f < file >" 
    echo -n " -s < source language >"
    echo -n " -t < target language >"
    echo -n " [-w <working directory>]" 
    echo -n " [-z <split>]"
    echo -n " [-d <debug>]"
    echo -n " [-o <overwrite STR>]"
    echo -n " [-v verbose]"
    echo -n " [-M Process all mkv files in directory]"
    echo -n " [-S Process all SRT files in directory]"
    echo 
    echo "example  $0 \"Movies/Green Mile (2000)/Green Mile (2000).mkv\" -s en -t nl"
    
    exit $exit_error
    }

    # Parse command line arguments
    while getopts ":f:s:t:w:z:dovMS" opt; do
    case "$opt" in
        f) file="$OPTARG";;
        s) source_language="$OPTARG"
        passon_args="$passon_args -s $OPTARG"
        ;;
        t) target_language="$OPTARG"¨
        passon_args="$passon_args -t $OPTARG"
        ;;
        w) working_directory="$OPTARG";;
        z) split="$OPTARG"
        passon_args="$passon_args -z $OPTARG"
        ;;
        d) debug="true"
        passon_args="$passon_args -d "
        ;;
        o) overwrite="true"
        passon_args="$passon_args -o "
        ;;
        v) verbose="true"
        passon_args="$passon_args -v "
        ;;
        M) scan="true"
        scan_type="mkv"
        ;;
        S) scan="true"
            scan_type="srt"
            ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage;;
    esac
    done
    
    verbose "***********************************************"
    verbose "            Srt Translater                     "
    verbose "***********************************************"
    # Check if mandatory arguments are provided
    if [ -z "$file" ] || [ -z "$source_language" ] || [ -z "$target_language" ] || [ -z "$working_directory" ] || [ -z "$split" ];  then
    echo
    echo "Mandatory arguments are missing."
    echo $file $source_language $target_language $working_directory $split
    echo $@
    usage
    fi


    if [ "$scan" = "true" ]; then
        mapfile -t files < <(find "$file" -type f -name "*.${scan_type}")
        if [ "${#files[@]}" -gt 0 ]; then
        # Loop through the found files (you can perform any operations you want here)
        verbose "Found ${#files[@]}  file(s)" 
            
        for mkv_file in "${files[@]}"; do
        verbose "processing $files"
        verbose "------------------------------------------------------------------------"
            bash $0 -f "$files"
            verbose $0 -f "$files" "$passon_args" 
            
        done
        else
        echo "No .mkv files found in $directory"
        exit $exit_error
        fi




    exit
    fi

fi ## end NZBPP_FINALDIR


# Initialize variables
part_num=1
consecutive_empty_line_count=0
part_content=""

country_list="${nzb_script_dir}${ISO_639_list}" 
filename=$(basename "$file")
filename_no_extension="${filename%.*}"
file_extension="${file##*.}"
file_directory="$(dirname "${file}")"

source_file="$working_directory/$filename_no_extension.$source_language.srt"
srt_target_file="$file_directory/$filename_no_extension.$target_language.srt"

if [ "$overwrite" = "true" ]; then
 rm "$srt_target_file"
fi

mkdir -p $working_directory
rm -f $working_directory/*.srt

debug "$0 all arguments $@"
debug "Variable: file directory = $file_directory"
debug "Variable: file= $file"

debug "Variable: filename = $filename"
debug "Variable: filename_no_extension = $filename_no_extension"
debug "Variable: file_extension = $file_extension"
debug "Variable: file_directory = $file_directory"

if [ ! -f "$file" ]; then
    echo "$nzblog_error [$file] The file does not exist. Exiting..."
   exit $exit_error
fi 

if [ -f "$srt_target_file" ]; then
    echo "$nzblog_warning subtitle '$srt_target_file' exsist , no need to creat Exiting..."
    exit $exit_skip
fi
if [ ! -d "$working_directory" ] || [ ! -r "$working_directory" ]; then
    
    echo "$nzblog_error $working_directory directory is not readable or does not exist."
    exit $exit_error
fi

if [ ! -d "$file_directory" ] || [ ! -r "$file_directory" ]; then
    echo "$nzblog_error $file_directory directory is not readable or does not exist."
    exit $exit_error
fi


  
# Check if the file extension is "mkv" or "srt"
if [ "$file_extension" = "mkv" ]; then
    verbose "$nzblog_detail The file has the 'mkv' extension."
    type="mkv"
   
elif [ "$file_extension" = "srt" ]; then
    verbose "$nzblog_detail The file has the 'srt' extension."
    type="srt"
    source_file=$file
else
    echo "$nzblog_error $nzblog_error $file_extension is an unknown file type"
    exit $exit_error
fi






function check_language_code() {
    result=$(cat "$country_list" |cut -d ";" -f2 |grep $1 |wc -l)
    if [ $result -eq 0 ]; then
        echo "$nzblog_error $1 language doesn't exsist , exting"
        exit $exit_error
    fi
}


#check_language_code "$target_language"
#check_language_code "$source_language"

function Iso639_full_contry (){ awk -v search="$1" -F ';' '$2 == search {print $3}' $country_list ;}

function Iso639_2 (){ awk -v search="$1" -F ';' '$2 == search {print $1}' $country_list ;}




function drawProgressBar() {
    local progress=$1
    local total=$2
    local bar_length=80
    local progress_length=$((progress * bar_length / total))
    local bar=""
    local spaces=""

    for ((i = 0; i < progress_length; i++)); do
        bar+="="
    done

    for ((i = progress_length; i < bar_length; i++)); do
        spaces+=" "
    done

    echo -ne "[${bar}${spaces}] ${progress}/${total}\r"
    }


function Translate() {
    local strfile=$1
    local target_language=$2
    local source_language=$3
    local progress=1
    

    local filename=$(basename "$strfile")
    local filename_no_extension="${filename%.*}"
    local dir="$(dirname "${strfile}")"
    local temp_srt_file="$dir/$filename_no_extension.$target_language.srt"

    local total_lines=$(awk '!/^[0-9]+$/ && !/^[0-9]+:[0-9]+:[0-9]+,[0-9]+ --> [0-9]+:[0-9]+:[0-9]+,[0-9]+$/' "${strfile}" |grep "\S" |wc -l)
    
    debug "Variable: temp_srt_file= $temp_srt_file"
    
    while IFS= read -r line; do
        if [[ $line =~ ^[0-9][^:]*$ ]]; then
            subtitle_id="$line" 
            continue
        elif [[ $line =~ ^[0-9][0-9]:[0-9][0-9] ]]; then
            timestamp="$line"
            continue
        elif [[ $line != "" ]]; then
        
            sl=${#line}

            if [ "$sl" != 1 ]; then
            
                ((progress=progress+1))
                drawProgressBar "$progress" "$total_lines"
                #debug "http://translate.googleapis.com/translate_a/single?client=gtx&sl=$source_language&tl=$target_language&dt=t&q=$line"
                translated_line=$(wget -U "Mozilla/5.0" -q -O- "http://translate.googleapis.com/translate_a/single?client=gtx&sl=$source_language&tl=$target_language&dt=t&q=$line"  | jq -r '.[0][0][0]')
                
                if [ "$pre_subtitle_id" = "$subtitle_id" ];then 
                    echo "$translated_line" >> "$temp_srt_file"
                else                   
                    echo "$subtitle_id" >> "$temp_srt_file"
                    echo "$timestamp" >> "$temp_srt_file"
                    echo "$translated_line" >> "$temp_srt_file"
                    pre_subtitle_id=$subtitle_id
                fi
            fi

        else
            echo "" >> "$temp_srt_file"
        fi
    done < "$strfile"

}

############################# Extract subtitles from MKV file only ##################################


 if [ "$type" == "mkv" ]; then 

    target_target_Iso639_2=$(Iso639_2 "$target_language")
    source_target_Iso639_2=$(Iso639_2 "$source_language")
    debug $target_target_Iso639_2
    debug $source_target_Iso639_2
    subtiles_exsist=$(mkvmerge -J "$file" | jq -r  --arg var "${target_target_Iso639_2}" '.tracks[] | select(.type == "subtitles" and .properties.language == $var)'.id)
    if [ -n "$subtiles_exsist" ]; then
        echo "$nzblog_warning $target_language subtiles exsist, no need to translate "
        exit $exit_skip
    else 
        debug "$target_language subtiles not found."
    fi
    
    debug "looking for $source_language subtitles"

    
    
    id=$(mkvmerge -J "$file" | jq -r --arg lang "$source_target_Iso639_2"  '.tracks[] | select(.type == "subtitles" and .properties.language == $lang and ((.properties.track_name // "") | test("SDH") | not)).id')
  
   if [ -z "$id" ]; then 
        debug "No $source_target_Iso639_2 text found"
        debug "Will try seach for SDH $source_target_Iso639_2 subtitls"
        id=$(mkvmerge -J "$file" | jq -r --arg lang "$source_target_Iso639_2"  '.tracks[] | select(.type == "subtitles" and . "properties": {"codec_id".language == $lang and ((.properties.track_name // "") | test("SDH"))).id') 
   fi

        codec_type=$(mkvmerge -J "$file" | jq -r --argjson id "$id" '.tracks[] | select(.id == $id) | .codec')

        if [ "$codec_type" = "VobSub" ]; then
  echo "$nzblog_error $nzblog_warning The codec type is vobsub. not suported yet."
  exit $exit_skip
fi

 debug "Track id = $id"
 debug "codec: Variable =$codec_type"
 
    debug "$source_language subtitles found id:$id"

    verbose "Extracting subtitles $source_language to file: $source_file "  
   # verbose "mkvextract tracks  $file  $id:$source_file" 
    mkvextract tracks "$file" $id:"$source_file" 
fi

verbose "Splitting srt file per $split line to speed up translating"

############################# Start splitting SRT file ##################################

while IFS= read -r line; do

    #echo $line
    if [[ $line =~ ^$'\n'*$ ]]; then
        ((consecutive_empty_line_count++))
    fi


    part_content+="$line"$'\n'
    #echo $consecutive_empty_line_count
        # Check if we've reached 200 consecutive empty lines
        if [ "$consecutive_empty_line_count" -eq $split ]; then
            #echo "$working_directory/part$part_num.srt"
            #echo $part_content
            # Write the part content to a new file
            echo -n "$part_content" > "$working_directory/part$part_num.srt"
            debug "$part_content  > $working_directory/part$part_num.srt"
            # Reset variables for the next part
            part_content=""
            ((part_num++))
            consecutive_empty_line_count=0
        fi
done < "$source_file"

rm -f "$source_file"
# Write any remaining content to a part file
if [ -n "$part_content" ]; then
    echo -n "$part_content" > "$working_directory/part$part_num.srt"
fi

############################# End splitting SRT file ##################################

############################# start  translating ##################################

verbose "Starts translating $total_lines lines from $source_language to $target_language \n"

count=1
 ((part_num++))
# Use a while loop
while [ "$count" -ne $part_num ]; do
    debug "Command : Translate $working_directory/part$count.srt  $target_language $source_language" 
    Translate "$working_directory/part$count.srt" "$target_language" "$source_language"  &
    ((count++))
done

wait
rm -f "$working_directory/$filename_no_extension.$target_language.srt"
verbose "\n$nzblog_info transling done"

############################# end  translating ##################################

verbose "combining parts file to $srt_target_file"

count=1

while [ "$count" -ne $part_num ]; do
    cat "$working_directory/part$count.$target_language.srt" >> "$srt_target_file"
    rm  -f "$working_directory/part$count.$target_language.srt"
    rm  -f "$working_directory/part$count.srt"
    ((count++))
done

echo "$nzblog_info DONE"
ELAPSED="Elapsed: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo "$nzblog_info Translating time : $ELAPSED"

 exit $exit_success
# Print the extracted text
