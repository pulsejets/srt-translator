#!/bin/bash
##############################################################################
### NZBGET POST-PROCESSING SCRIPT                                           ###

# SRT translator
#
# This is a script extrace srt subtitles from mkv file and translate it into
# disired language using google translate
#
# the translated srt files will be placed in sam folder as the mkv file
#
# Info about srt translater:
# Author: Kenneth Moller (kenneth.moller@gmail.com).
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

#Force external subtitles for Plex
#
# Force external subtitles (for Plex) will add .forced. in file name
#
#ForceExternalSRT=yes

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

# Script variables
declare -A iso639

iso639["aa"]="aar";iso639["ab"]="abk";iso639["af"]="afr";iso639["ak"]="aka";iso639["sq"]="alb";
iso639["am"]="amh";iso639["ar"]="ara";iso639["an"]="arg";iso639["hy"]="arm";iso639["as"]="asm";
iso639["av"]="ava";iso639["ae"]="ave";iso639["ay"]="aym";iso639["az"]="aze";iso639["ba"]="bak";
iso639["bm"]="bam";iso639["be"]="bel";iso639["eu"]="baq";iso639["bn"]="ben";iso639["bh"]="bih";
iso639["bi"]="bis";iso639["bs"]="bos";iso639["br"]="bre";iso639["bg"]="bul";iso639["my"]="bur";
iso639["ca"]="cat";iso639["ch"]="cha";iso639["ce"]="che";iso639["zh"]="chi";iso639["cu"]="chu";
iso639["cv"]="chv";iso639["kw"]="cor";iso639["co"]="cos";iso639["cr"]="cre";iso639["cs"]="cze";
iso639["da"]="dan";iso639["dv"]="div";iso639["nl"]="dut";iso639["dz"]="dzo";iso639["en"]="eng";
iso639["eo"]="epo";iso639["et"]="est";iso639["ee"]="ewe";iso639["fo"]="fao";iso639["fj"]="fij";
iso639["fi"]="fin";iso639["fr"]="fre";iso639["fy"]="fry";iso639["ff"]="ful";iso639["ka"]="geo";
iso639["de"]="ger";iso639["gd"]="gla";iso639["ga"]="gle";iso639["gl"]="glg";iso639["gv"]="glv";
iso639["el"]="gre";iso639["gn"]="grn";iso639["gu"]="guj";iso639["ht"]="hat";iso639["ha"]="hau";
iso639["he"]="heb";iso639["hz"]="her";iso639["hi"]="hin";iso639["ho"]="hmo";iso639["hr"]="hrv";
iso639["hu"]="hun";iso639["ig"]="ibo";iso639["is"]="ice";iso639["io"]="ido";iso639["ii"]="iii";
iso639["iu"]="iku";iso639["ie"]="ile";iso639["ia"]="ina";iso639["id"]="ind";iso639["ik"]="ipk";
iso639["it"]="ita";iso639["jv"]="jav";iso639["ja"]="jpn";iso639["kl"]="kal";iso639["kn"]="kan";
iso639["ks"]="kas";iso639["kr"]="kau";iso639["kk"]="kaz";iso639["km"]="khm";iso639["ki"]="kik";
iso639["rw"]="kin";iso639["ky"]="kir";iso639["kv"]="kom";iso639["kg"]="kon";iso639["ko"]="kor";
iso639["kj"]="kua";iso639["ku"]="kur";iso639["lo"]="lao";iso639["la"]="lat";iso639["lv"]="lav";
iso639["li"]="lim";iso639["ln"]="lin";iso639["lt"]="lit";iso639["lb"]="ltz";iso639["lu"]="lub";
iso639["lg"]="lug";iso639["mk"]="mac";iso639["mh"]="mah";iso639["ml"]="mal";iso639["mi"]="mao";
iso639["mr"]="mar";iso639["ms"]="may";iso639["mg"]="mlg";iso639["mt"]="mlt";iso639["mn"]="mon";
iso639["na"]="nau";iso639["nv"]="nav";iso639["nr"]="nbl";iso639["nd"]="nde";iso639["ng"]="ndo";
iso639["ne"]="nep";iso639["nn"]="nno";iso639["nb"]="nob";iso639["no"]="nor";iso639["ny"]="nya";
iso639["oc"]="oci";iso639["oj"]="oji";iso639["or"]="ori";iso639["om"]="orm";iso639["os"]="oss";
iso639["pa"]="pan";iso639["fa"]="per";iso639["pi"]="pli";iso639["pl"]="pol";iso639["pt"]="por";
iso639["ps"]="pus";iso639["qu"]="que";iso639["rm"]="roh";iso639["ro"]="rum";iso639["rn"]="run";
iso639["ru"]="rus";iso639["sg"]="sag";iso639["sa"]="san";iso639["si"]="sin";iso639["sk"]="slo";
iso639["sl"]="slv";iso639["se"]="sme";iso639["sm"]="smo";iso639["sn"]="sna";iso639["sd"]="snd";
iso639["so"]="som";iso639["st"]="sot";iso639["es"]="spa";iso639["sc"]="srd";iso639["sr"]="srp";
iso639["ss"]="ssw";iso639["su"]="sun";iso639["sw"]="swa";iso639["sv"]="swe";iso639["ty"]="tah";
iso639["ta"]="tam";iso639["tt"]="tat";iso639["te"]="tel";iso639["tg"]="tgk";iso639["tl"]="tgl";
iso639["th"]="tha";iso639["bo"]="tib";iso639["ti"]="tir";iso639["to"]="ton";iso639["tn"]="tsn";
iso639["ts"]="tso";iso639["tk"]="tuk";iso639["tr"]="tur";iso639["tw"]="twi";iso639["ug"]="uig";
iso639["uk"]="ukr";iso639["ur"]="urd";iso639["uz"]="uzb";iso639["ve"]="ven";iso639["vi"]="vie";
iso639["vo"]="vol";iso639["cy"]="wel";iso639["wa"]="wln";iso639["wo"]="wol";iso639["xh"]="xho";
iso639["yi"]="yid";iso639["yo"]="yor";iso639["za"]="zha";



SECONDS=0
file=""
target_language="da"
source_language="en"
working_directory="tmp"

nzb_script_dir=""
scan_type="mkv"
passon_args=""
forced=""
split=50

overwrite=false
scan=false

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

 # If script is run via NZBget post processing 

if [ -n "$NZBPP_FINALDIR" ]; then

   
    file="$(find "$NZBPP_FINALDIR" -type f -name "*.mkv")"
    nzb_script_dir="$NZBOP_SCRIPTDIR/"
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
    
    if [ $ForceExternalSRT ="yes" ];then
        forced="forced."
    else
        forced=""
    fi
    if [ $Verbose ="yes" ];then
        verbose="true"
    else
        verbose="false"
    fi
else
    
   # run from cli
    
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
    echo -n " [-F Force external subtitles (for Plex) will add .forced. in file name]"
    echo 
    echo "example  $0 \"Movies/Green Mile (2000)/Green Mile (2000).mkv\" -s en -t nl"
    
    exit $exit_error
    }

    # Parse command line arguments
    while getopts ":f:s:t:w:z:dovMSF" opt; do
        case "$opt" in
            f) file="$OPTARG";;
            s) source_language="$OPTARG"
            passon_args="$passon_args -s $OPTARG"
            ;;
            t) target_language="$OPTARG"
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
            F) forced="forced."
            ;;
            \?) echo "Invalid option: -$OPTARG" >&2; usage;;
            :) echo "Option -$OPTARG requires an argument." >&2; usage;;
        esac
    done
    
if ! command -v mkvmerge &> /dev/null || ! command -v mkvextract &> /dev/null || ! command -v jq &> /dev/null || ! command -v dos2unix &> /dev/null; then
    echo "One or more of the required programs (mkvmerge, mkvextract, jq, dos2unix) is not installed. Please install them."
    echo "$nzblog_error  One or more of the required programs (mkvmerge, mkvextract, jq, dos2unix) is not installed. Please install them."
    exit $exit_error
fi



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
       mapfile -t files < <(find "$file" -type f -name "*.${scan_type}" -mtime -10)

        if [ "${#files[@]}" -gt 0 ]; then   
            verbose "Found ${#files[@]} file(s)"

            for mkv_file in "${files[@]}"; do
                verbose "processing $mkv_file"
               bash $0 -f "$mkv_file"  "$passon_args"
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


filename=$(basename "$file")
filename_no_extension="${filename%.*}"
file_extension="${file##*.}"
file_directory="$(dirname "${file}")"

source_file="$working_directory/$filename_no_extension.$source_language.srt"
srt_target_file="$file_directory/$filename_no_extension.$target_language.${forced}srt"

if [ "$overwrite" = "true" ]; then
    rm "$srt_target_file"
fi

mkdir -p $working_directory
   rm -f $working_directory/*.srt

debug "$0 all arguments $@"
debug "Variable: file directory = $file_directory"
debug "Variable: file= $file"
debug "Variable: split= $split"

debug "Variable: filename = $filename"
debug "Variable: filename_no_extension = $filename_no_extension"
debug "Variable: file_extension = $file_extension"
debug "Variable: file_directory = $file_directory"
debug "Variable: source_file = $source_file"
debug "Variable: srt_target_file = $srt_target_file"

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
    local pre_subtitle_id="0"
    local subtitle_id="1"
    local filename=$(basename "$strfile")
    local filename_no_extension="${filename%.*}"
    local dir="$(dirname "${strfile}")"
    local temp_srt_file="$dir/$filename_no_extension.$target_language.srt"

    local total_lines=$(awk '!/^[0-9]+$/ && !/^[0-9]+:[0-9]+:[0-9]+,[0-9]+ --> [0-9]+:[0-9]+:[0-9]+,[0-9]+$/' "${strfile}" |grep "\S" |wc -l)
     dos2unix "$strfile"
    debug "Variable: temp_srt_file= $temp_srt_file"
    
    while IFS= read -r line; do
        if [[ $line =~ ^[0-9][^:]*$  ]]; then
            subtitle_id="$line" 
            #debug "subtitle_id =$subtitle_id"
    	    continue
        elif [[ $line =~ ^[0-9][0-9]:[0-9][0-9] ]]; then
            timestamp="$line"
	        # debug "timestamp=$timestamp"
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
 target_target_Iso639_2=${iso639[$target_language]}
    source_target_Iso639_2=${iso639[$source_language]}
 


debug  "Variable: target_language = $target_language"
debug  "Variable:source_language = $source_language"

if [ "$type" == "mkv" ]; then 

    if mkvmerge -i "$file" | grep -q 'SubRip/SRT'; then
        echo "The MKV file contains SubRip/SRT subtitles."

    
        debug "Variable target_target_Iso639_2 =$target_target_Iso639_2"
        debug "Variable source_target_Iso639_2 =$source_target_Iso639_2"
    # debug "Command: mkvmerge -J '$file' | jq -r  --arg lang '$source_target_Iso639_2'  '.tracks[] | select(.type == 'audio') | select(.properties.language == $lang).id')"
        #target_audio_track_id=$(mkvmerge -J "$file" | jq -r  --arg lang "$source_target_Iso639_2"  '.tracks[] | select(.type == "audio") | select(.properties.language == $lang).id')
        
    # debug " $source_language audio id $target_audio_track_id"
        subtiles_exsist=$(mkvmerge -J "$file" | jq -r  --arg var "${target_target_Iso639_2}" '.tracks[] | select(.type == "subtitles" and .properties.language == $var)'.id)
        if [ -n "$subtiles_exsist" ]; then
            echo "$nzblog_warning $target_language subtiles exsist in mkv file, no need to translate "
            #exit $exit_skip
        else 
            debug "Status: $target_language subtiles not found."
        fi
        
        debug "Status: looking for $source_language subtitles"
        debug "Command: mkvmerge -J \"$file\" | jq -r --arg lang \"$source_target_Iso639_2\"  '.tracks[] | select(.type == \"subtitles\" and .properties.language == \$lang and ((.properties.track_name // \"\") | test(\"SDH\") | not)).id'"
    id=$(mkvmerge -J  "$file" | jq -r --arg lang "$source_target_Iso639_2" '.tracks[] | select(.type == "subtitles" and .properties.language == $lang  and .properties.codec_id == "S_TEXT/UTF8" and ((.properties.track_name // "") | test("SDH") | not)).id')
    # id=$(mkvmerge -J "$file" | jq -r --arg lang "$source_target_Iso639_2" '.tracks[] | select(.type == "subtitles" and .properties.language == $lang and ((.properties.track_name // "") | test("SDH") | not) and ((.properties.track_name // "") | test("Commentary") | not)).id')
    
        if [ -z "$id" ]; then 
            debug "Status: No $source_target_Iso639_2 text found"
            debug "Status: Will try seach for SDH $source_target_Iso639_2 subtitls"
            id=$(mkvmerge -J "$file" | jq -r --arg lang "$source_target_Iso639_2"  '.tracks[] | select(.type == "subtitles" and . "properties": {"codec_id".language == $lang and ((.properties.track_name // "") | test("SDH"))).id') 
        fi
        
        codec_type=$(mkvmerge -J "$file" | jq -r --argjson id "$id" '.tracks[] | select(.id == $id) | .codec')
        
        if [ "$codec_type" != "SubRip/SRT" ]; then
            echo "$file"
            echo  "$nzblog_warning The codec ($codec_type )type is not suported yet."
            exit $exit_skip
        fi

        debug "Variable: Track id = $id"
        debug "Variable: codec: Variable =$codec_type"
        debug "Status: $source_language subtitles found id:$id"
        debug "Command: mkvextract tracks  $file  $id:$source_file"
        
        verbose "Extracting subtitles $source_language to file: $source_file "  
        
        mkvextract tracks "$file" $id:"$source_file"
        
        else
    echo "The MKV file does not contain SubRip/SRT subtitles."
    exit $exit_error
    fi
fi

verbose "Status: Splitting srt file per $split line to speed up translating"

############################# Start splitting SRT file ##################################

while IFS= read -r line; do

    #echo $line
    if [[ $line =~ ^$'\n'*$ ]]; then
        ((consecutive_empty_line_count++))
    fi

    part_content+="$line"$'\n'
    
        # Check if we've reached x consecutive empty lines
    if [ "$consecutive_empty_line_count" -eq $split ]; then
        # Write the part content to a new file
        echo -n "$part_content" > "$working_directory/part$part_num.srt"
        #debug "$part_content  > $working_directory/part$part_num.srt"
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
debug "Variable part_num = $part_num"

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
#cat "$working_directory/part$count.$target_language.srt" >> "$srt_target_file"
while [ "$count" -ne $part_num ]; do
    cat "$working_directory/part$count.$target_language.srt" >> "$srt_target_file"
   # rm  -f "$working_directory/part$count.$target_language.srt"
    rm  -f "$working_directory/part$count.srt"
    ((count++))
done

echo "adding $srt_target_file subtitle to $file"
debug "Command: mkvmerge -o \"${file}.tmp\"  \"$file\" --language 0:\"$target_target_Iso639_2\" \"$srt_target_file\""

mkvmerge -o "${file}.tmp"  "$file" --language 0:"$target_target_Iso639_2" "$srt_target_file"

if [ $? -eq 0 ]; then
    echo "mkvmerge succeeded"
    echo "deleting $file"
    rm -f "$file"
    echo "renaming ${file}.tmp to  ${file}"
    mv "${file}.tmp" "${file}"
else
    echo "mkvmerge failed with exit code $?"
    exit $exit_error
fi

echo "$nzblog_info DONE"
ELAPSED="Elapsed: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo "$nzblog_info Translating time : $ELAPSED"

 exit $exit_success
# Print the extracted text
