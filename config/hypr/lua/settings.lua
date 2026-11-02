-- Look and behavior. Visual values are Hyprlust's; the rest is JaKooLit's defaults.

hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 6,
        border_size      = 2,
        col = {
            active_border   = C.color12,
            inactive_border = C.background,
        },
        resize_on_border = true,
        layout           = "master",   -- SUPER+ALT+L switches between master and dwindle
    },

    decoration = {
        rounding           = 10,
        active_opacity     = 1.0,
        inactive_opacity   = 1.0,
        fullscreen_opacity = 1.0,
        dim_inactive       = false,
        dim_strength       = 0.1,
        dim_special        = 0.8,
        shadow = {
            enabled        = false,
            range          = 6,
            render_power   = 1,
            color          = C.color12,
            color_inactive = C.color2,
        },
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 3,
            noise             = 0.02,
            vibrancy          = 0.1796,
            ignore_opacity    = true,
            new_optimizations = true,
            special           = true,
            popups            = true,
        },
    },

    group = {
        col = { border_active = C.color12 },
        groupbar = { col = { active = C.color0 } },
    },

    dwindle = {
        preserve_split       = true,
    },

    master = {
        new_status = "master",
        new_on_top = true,
        mfact      = 0.5,
    },

    input = {
        kb_layout          = "us",
        kb_variant         = "",
        kb_model           = "",
        kb_options         = "",
        kb_rules           = "",
        repeat_rate        = 50,
        repeat_delay       = 300,
        sensitivity        = 0,
        numlock_by_default = true,
        left_handed        = false,
        follow_mouse       = 1,
        float_switch_override_focus = 0,
        touchpad = {
            disable_while_typing    = true,
            natural_scroll          = true,
            clickfinger_behavior    = false,
            middle_button_emulation = true,
            tap_to_click            = true,
            drag_lock               = false,
        },
        touchdevice = { enabled = true },
    },

    gestures = {
        workspace_swipe_distance           = 500,
        workspace_swipe_invert             = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio       = 0.5,
        workspace_swipe_create_new         = true,
        workspace_swipe_forever            = true,
    },

    misc = {
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        vrr                        = 2,
        mouse_move_enables_dpms    = true,
        enable_swallow             = true,
        swallow_regex              = "^(kitty)$",
        focus_on_activate          = false,
        initial_workspace_tracking = 0,
        middle_click_paste         = true,
        enable_anr_dialog          = true,
        anr_missed_pings           = 15,
        allow_session_lock_restore = true,
        on_focus_under_fullscreen  = 1,
    },

    debug = {
        vfr = true,
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles   = true,
        pass_mouse_when_bound    = false,
    },

    xwayland = {
        enabled            = true,
        force_zero_scaling = true,
    },

    render = {
        direct_scanout = 0,
    },

    cursor = {
        sync_gsettings_theme     = true,
        no_hardware_cursors      = false,
        enable_hyprcursor        = true,
        warp_on_change_workspace = 1,
        no_warps                 = true,
    },
})

-- 3-finger horizontal swipe on the touchpad = switch workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Scratchpad / special workspaces (SUPER+S): windows fill the whole screen (below the bar),
-- like a pop-up layer. (Replaces dwindle.special_scale_factor, deprecated in Hyprland 0.57.)
hl.workspace_rule({ workspace = "s[true]", gaps_out = 0 })
