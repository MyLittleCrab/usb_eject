package require Tk

# --- Главное окно ---
wm title . "Select Device"
wm geometry . 650x550

# Command-line handling: accept a single optional argument which is the path
# to the usb_eject executable. If provided, set exe_path to that value.
if {[info exists ::argc] && $::argc > 0} {
    # Take only the first argument
    set arg0 [lindex $::argv 0]
    # If the argument is a directory, join with usb_eject, otherwise use as-is
    if {[file isdirectory $arg0]} {
        set exe_path [file join $arg0 "usb_eject"]
    } else {
        set exe_path $arg0
    }
}


# --- Список устройств ---
listbox .list -selectmode single -height 5
pack .list -fill both -expand 1 -padx 10 -pady 10

# Асинхронная загрузка списка устройств
proc load_devices_async {} {
    .list delete 0 end
    .list insert end "Loading devices..."
    update
    after 100 [list load_devices]
}

proc load_devices {} {
    # Use provided exe_path if set, otherwise default to ./usb_eject in CWD
    if {![info exists ::exe_path]} {
        set ::exe_path [file join [pwd] "usb_eject"]
    }
    set exe_path $::exe_path
    catch {set devices [split [exec $exe_path --only-list] "\n"]} err
    .list delete 0 end
    if {[info exists devices] && [llength $devices] > 0} {
        foreach line $devices {
            if {[regexp {VID:PID =} $line]} {
                .list insert end $line
            }
        }
        if {[.list size] == 0} {
            .list insert end "No USB devices found."
        }
    } else {
        .list insert end "Error loading devices: $err"
    }
}

load_devices_async

# --- Кнопки ---
frame .buttons
pack .buttons -fill x -padx 10 -pady 10

button .buttons.eject -text "Eject" -width 10 -command {
    set sel [.list curselection]
    if {$sel eq ""} {
        tk_messageBox -message "Please select a device first." -icon warning
    } else {
        set item [.list get $sel]
        # Ensure exe_path is set (may have been provided as CLI arg)
        if {![info exists ::exe_path]} {
            set ::exe_path [file join [pwd] "usb_eject"]
        }
        set exe_path $::exe_path

        # Парсим VID и PID из строки
        if {[regexp {VID:PID = ([0-9a-fA-F]+):([0-9a-fA-F]+)} $item -> vid pid]} {
            # Команда с sudo/administrator
            if {$tcl_platform(os) eq "Darwin"} {
                # macOS: AppleScript для sudo
                set script "do shell script \"$exe_path $vid $pid\" with administrator privileges"
                set cmd [list osascript -e $script]
            } else {
                # Linux: pkexec
                set cmd [list pkexec $exe_path $vid $pid]
            }

            if {[catch {set result [exec {*}$cmd]} err]} {
                tk_messageBox -message "Error: $err\nCMD: $cmd" -icon error
            } else {
                tk_messageBox -message "Ejecting: $item\n\n$result" -icon info
                exit
            }
        } else {
            tk_messageBox -message "Could not parse VID/PID from: $item" -icon error
        }
    }
}

button .buttons.cancel -text "Cancel" -width 10 -command { exit }

pack .buttons.eject -side left -expand 1
pack .buttons.cancel -side right -expand 1
