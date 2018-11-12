dir=$HOME/.themes/colorizer/
pwd=/usr/bin/pwd
conf=$HOME/.config/
file=$HOME/.Xresources
arr=()

fill_color(){
        get_colors(){
                grep "color$1 *:" $file | awk -F\# '{print $2}' | head -1
        }
        get_colors_bg=`grep "background *:" $file | awk -F\# '{print $2}' | head -1`
}

xfwm_themer(){
	if [ ! -d "$dir"xfwm4/ ]; then
	    mkdir -p "$dir"xfwm4/
	else
		rm "$dir"xfwm4/*
	fi	
	cp `$pwd`/xfwm4/$1/* "$dir"xfwm4/
	sed -i s/"color_bg"/"${get_colors_bg}"/g "$dir"xfwm4/*
	for i in {1..8}; do
		sed -i s/"color_$i"/"$(get_colors $i)"/g "$dir"xfwm4/*;
	done
	cp -r `$pwd`/xfce-notify-4.0 "$dir"
	sed -i s/"color_bg"/"${get_colors_bg}"/g "$dir"xfce-notify-4.0/*
	for i in {1..8}; do
		sed -i s/"color_$i"/"$(get_colors $i)"/g "$dir"xfce-notify-4.0/*;
	done
}

ob_themer(){
	if [ ! -d "$dir"openbox-3/ ]; then
	    mkdir -p "$dir"openbox-3/
	else
		rm "$dir"openbox-3/*
	fi	
	cp `$pwd`/openbox/$1/* "$dir"openbox-3/
	sed -i s/"color_bg"/"${get_colors_bg}"/g "$dir"openbox-3/*
	for i in {1..8}; do
		sed -i s/"color_$i"/"$(get_colors $i)"/g "$dir"openbox-3/*;
	done
	if [[ $(cat $HOME/.config/openbox/rc.xml | grep "colorize") ]]; then
		openbox --reconfigure
	elif [[ $(which obconf) ]]; then
		obconf >/dev/null 2>&1
	fi
}

tint_themer(){
	cp "$conf"/tint2/tint2rc "$conf"/tint2/tint2rc.old
	cp `$pwd`/tint2/$1/* "$conf"tint2/
	sed -i s/"color_bg"/"${get_colors_bg}"/g "$conf"tint2/tint2rc
	for i in {1..8}; do
		sed -i s/"color_$i"/"$(get_colors $i)"/g "$conf"tint2/tint2rc;
	done
	sed -i -E "s%\/home\/[a-zA-Z0-9_-]+\/%\/home\/${USER}\/%g" ~/.config/tint2/tint2rc
	killall tint2
	tint2 </dev/null &>/dev/null &
}

gtk_themer(){
	rm -rf "$dir"gtk-*
	cp -r `$pwd`/gtk/$1/* "$dir"
	find "$dir"gtk-2.0/ -type f -exec sed -i s/"color_bg"/"${get_colors_bg}"/g {} \;
	find "$dir"gtk-2.0/menubar-toolbar/ -type f -exec sed -i s/"color_bg"/"${get_colors_bg}"/g {} \;
	find "$dir"gtk-3.0/ -type f -exec sed -i s/"color_bg"/"${get_colors_bg}"/g {} \;
	for i in {1..8}; do
		find "$dir"gtk-2.0/ -type f -exec sed -i s/"color_$i"/"$(get_colors $i)"/g {} \;;
		find "$dir"gtk-2.0/menubar-toolbar/ -type f -exec sed -i s/"color_$i"/"$(get_colors $i)"/g {} \;
		find "$dir"gtk-3.0/ -type f -exec sed -i s/"color_$i"/"$(get_colors $i)"/g {} \;
	done
}

apply_theme(){
	echo "Applying theme ..."
	xfconf-query -c xfwm4 -p /general/theme -s "adwaita"
	xfconf-query -c xfwm4 -p /general/theme -s "colorizer"
	xfconf-query -c xsettings -p /Net/ThemeName -s "adwaita"
	xfconf-query -c xsettings -p /Net/ThemeName -s "colorizer"
	echo "Done"
	notify-send "Done changing theme :)"
}

show_help(){
	cat <<-EOF
		                                    
	 _____     _         _             
	|     |___| |___ ___|_|___ ___ ___ 
	|   --| . | | . |  _| |- _| -_|  _|
	|_____|___|_|___|_| |_|___|___|_|  
	                                   


	Usage : colorizer [options #parameter]

	Avaible options
	--wal       Generate color from pywal cache
	--xcolor    Generate color from custom .Xresources file
	--gtk       Choose gtk theme from list [ fantome ]
	--xfwm      Choose xfwm4 theme from list [ pastel | black-paha | one_new | nest1 | diamondo | wendows | tetris | ribbon | just-title-bar ]
	--openbox   Choose openbox theme from list [ pelangi | tricky | large-tb | mek-oes ]
	--tint2     Choose tint2 theme from list [ chromeos | chromeos-tinted | chromeos-pelangi | slim-text-dark | slim-text-tinted | slim-text-tinted-dark | floaty-rounded | floaty ]
	--help      Show help

	EOF
}

if [[ $# -eq 0 ]]; then
	show_help
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --wal | -w )
			if [[ -n $xcolor ]]; then
				file=$xcolor
			elif [[ ! -e $HOME/.cache/wal/colors.Xresources ]]; then
				echo "File $HOME/.cache/wal/colors.Xresources doesn't exist"
				echo "You must install pywal first"
				exit 1
			else
				wal=1
				file=$HOME/.cache/wal/colors.Xresources
			fi
			;;
		--xcolor | -xc )
			if [[ -z $2 ]]; then
				echo "Please specify the .Xresources location"
				exit 1
			elif [[ ! -e $2 ]]; then
				echo "File $2 doesn't exist"
				exit 1
			else
				xcolor=$2
				file=$xcolor
				#arr[${#arr[@]}]="xcolor"
				shift
			fi
			;;
        --gtk | -g )
			if [[ -z $2 ]]; then
				echo "Please specify the gtk theme"
				exit 1
			elif [[ $2 = fantome ]]; then
				gtk=$2
				#echo $gtk
				#$(gtk_themer $gtk)
				arr[${#arr[@]}]="gtk"
				shift
			else
				show_help |grep gtk
				exit 1
			fi			
			;;
		--openbox | -ob )
			if [[ -z $2 ]]; then
				echo "Please specify the openbox theme"
				exit 1
			elif [[ "$2" = "pelangi" || "$2" = "tricky" || "$2" = "large-tb" || "$2" == "mek-oes" ]]; then
				openbox=$2
				#echo $openbox
				#$(ob_themer $openbox)
				arr[${#arr[@]}]="openbox"
				shift
			else
				show_help |grep openbox
				exit 1
			fi
			;;
		--xfwm | -xf )
			if [[ -z $2 ]]; then
				echo "Please specify the xfwm theme"
				exit 1
			elif [[ "$2" = "pastel" || "$2" = "black-paha" || "$2" = "one_new" || "$2" = "nest1" || "$2" = "diamondo" || "$2" = "wendows" || "$2" = "tetris" || "$2" = "ribbon" || "$2" = "just-title-bar" ]]; then
				xfwm=$2
				#echo $xfwm
				#$(xfwm_themer $xfwm)
				arr[${#arr[@]}]="xfwm"
				shift
			else
				show_help |grep xfwm
				exit 1
			fi
			;;
		--tint2 | -t )
			if [[ -z $2 ]]; then
				echo "Please specify the tint2 theme"
				exit 1
			elif [[ "$2" = "chromeos" || "$2" = "chromeos-tinted" || "$2" = "chromeos-pelangi" || "$2" = "slim-text-dark" || "$2" = "slim-text-tinted" || "$2" = "slim-text-tinted-dark" || "$2" = "floaty-rounded" || "$2" = "floaty" ]]; then
				tint2=$2
				#echo $tint2
				#$(tint_themer $tint2)
				arr[${#arr[@]}]="tint2"
				shift
			else
				show_help |grep tint2
				exit 1
			fi
			;;
        --help | -h )
			show_help
            exit
            ;;
        * )
			show_help
            exit 1
    esac
    shift
done

main() {
	if [[ ! -d $HOME/.themes/colorizer ]]; then
		mkdir $HOME/.themes/colorizer
	fi
	echo "Generating theme ..."
	fill_color
	#for i in {1..8}; do
	#	echo $(get_colors $i)
	#done
	i=0
	while [ $i -lt ${#arr[@]} ]; do
		case ${arr[$i]} in
			gtk )
				#echo "$gtk"
				$(gtk_themer $gtk)
				;;
			tint2 )
				#echo "$tint2"
				$(tint_themer $tint2)
				;;
			xfwm )
				#echo "$xfwm"
				$(xfwm_themer $xfwm)
				;;			
			openbox )
				#echo "$openbox"
				$(ob_themer $openbox)
				;;
		esac
		i=$(expr $i + 1)
	done
	apply_theme
}

if [[ $# -ne 1 ]]; then
	main
fi
