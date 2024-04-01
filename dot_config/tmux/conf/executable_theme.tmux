#!/usr/bin/env bash
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

color_bg="#2e323b"
color_fg="#282c34"
color_green="#98c379"
color_yellow="#e5c07b"
color_red="#e06c75"
color_blue="#61afef"
color_cyan="#56b6c2"
color_purple="#c678dd"
color_gray="#0"
color_buffer="#939aa3"
color_selection="#3e4452"
color_white="#ffffff"

SCRIPTS_PATH="$CURRENT_DIR/src"

window_id_style="none"
pane_id_style="hsquare"
zoom_id_style="dsquare"

#netspeed="#($SCRIPTS_PATH/netspeed.sh)"
#cmus_status="#($SCRIPTS_PATH/music-tmux-statusbar.sh)"
git_status="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"
wb_git_status="#($SCRIPTS_PATH/wb-git-status.sh #{pane_current_path} &)"
window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P $pane_id_style)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P $zoom_id_style)"
date_and_time="$($SCRIPTS_PATH/datetime-widget.sh)"

tmux set -g status on
tmux set -g window-status-separator ""
# tmux set -g status-interval 10                       # Redraw status line every 10 seconds
tmux set -g status-justify centre
tmux set -g status-left-length 120
tmux set -g status-position bottom
tmux set -g status-right-length 120
tmux set -g status-style "bg=$color_fg"
tmux set -g mode-style set-window-option bg=$color_green,fg=$color_bg
tmux set -g mode-style "fg=$color_purple,bg=$color_gray"
tmux set -g message-style "bg=$color_blue,fg=$color_gray"
tmux set -g message-command-style "fg=$color_buffer,bg=$color_gray"
tmux set -g pane-border-style "fg=$color_gray"
tmux set -g pane-active-border-style "fg=$color_blue"
tmux set -g status-style bg="$color_bg"

tmux set -g @mode_indicator_prefix_prompt " WAIT "
tmux set -g @mode_indicator_prefix_mode_style "fg=$color_bg,bg=$color_blue,bold"
tmux set -g @mode_indicator_copy_prompt " COPY "
tmux set -g @mode_indicator_copy_mode_style "fg=$color_bg,bg=$color_yellow,bold"
tmux set -g @mode_indicator_sync_prompt " SYNC "
tmux set -g @mode_indicator_sync_mode_style "fg=$color_bg,bg=$color_red,bold"
tmux set -g @mode_indicator_empty_prompt " TMUX "
tmux set -g @mode_indicator_empty_mode_style fg=$color_green,bold

# tmux cpu
tmux set -g @cpu_percentage_format "%3.0f%%"

# tmux-online-status
tmux set -g @route_to_ping "verizon.com"
tmux set -g @online_icon "#[fg=$color_gray]📶"
tmux set -g @offline_icon "#[fg=$color_red]🔺"

# tmux-pomodoro
tmux set -g @pomodoro_on " | #[fg=$color_red] "
tmux set -g @pomodoro_complete " | #[fg=$color_green] "

# tmux-battery
tmux set -g @batt_icon_charge_tier8 ""
tmux set -g @batt_icon_charge_tier7 ""
tmux set -g @batt_icon_charge_tier6 ""
tmux set -g @batt_icon_charge_tier5 ""
tmux set -g @batt_icon_charge_tier4 ""
tmux set -g @batt_icon_charge_tier3 ""
tmux set -g @batt_icon_charge_tier2 ""
tmux set -g @batt_icon_charge_tier1 ""
tmux set -g @batt_icon_status_charged " "
tmux set -g @batt_icon_status_charging "  "
tmux set -g @batt_icon_status_discharging " "
tmux set -g @batt_icon_status_attached " "
tmux set -g @batt_icon_status_unknown " "
tmux set -g @batt_remain_short true

#+--- Bars LEFT ---+
# Session name
# tmux set -g status-left "#[fg=$color_bg,bg=$color_blue,bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[fg=$color_white,bg=$color_purple,bold,nodim]#S $RESET"
# tmux set -g status-left "#{tmux_mode_indicator} #{online_status}  #[fg=$color_gray]%R#{pomodoro_status}"
tmux set -g status-left "#[fg=$color_bg,bg=$color_blue,bold]#{tmux_mode_indicator} #{online_status} #{pomodoro_status} "

#+--- Windows ---+
# Focus
# tmux set -g window-status-current-format "#[fg=$color_green,italics]#I: #[fg=$color_buffer,noitalics,bold]#W"
tmux set -g window-status-current-format "#[fg=$color_green,bg=$color_bg]   #[fg=$color_gray]$window_number #[bold,nodim]#W#[nobold,dim]#{?window_zoomed_flag, $zoom_number, $custom_pane} #{?window_last_flag,,} "
# Unfocused
# setw -g window-status-format "#[fg=$color_gray,italics]#I: #[noitalics]#W"
tmux set -g window-status-format "#[fg=$color_buffer,bg=default,none,dim]   $window_number #W#[nobold,dim]#{?window_zoomed_flag, $zoom_number, $custom_pane}#[fg=yellow,blink] #{?window_last_flag,󰁯 ,} "

#+--- Bars RIGHT ---+
# tmux set -g status-right "$cmus_status#[fg=#a9b1d6,bg=#24283B]$netspeed$git_status$wb_git_status$date_and_time"
# tmux set -g status-right "#[fg=$color_gray]#{battery_icon_charge}  #{battery_percentage}#{battery_icon_status}#{battery_remain} | CPU:#{cpu_percentage}"
tmux set -g status-right "#[fg=$color_gray,bg=$color_bg] $git_status$wb_git_status$date_and_time"
