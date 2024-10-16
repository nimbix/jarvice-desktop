#!/usr/bin/env bash

xfrun_desktop="xfrun4.desktop"
[ ! -e /etc/redhat-release ] && xfrun_desktop="xfce4-run.desktop"
app_menu_dir=$HOME/.config/menus
app_menu=$app_menu_dir/xfce-applications.menu
mkdir -p "$app_menu_dir"

cat > "$app_menu" <<EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">

<Menu>
    <Name>Xfce</Name>

    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>

    <Include>
        <Category>X-Xfce-Toplevel</Category>
    </Include>

    <Layout>
        <Filename>$xfrun_desktop</Filename>
        <Separator/>
        <Filename>exo-terminal-emulator.desktop</Filename>
        <Filename>exo-file-manager.desktop</Filename>
        <Filename>exo-web-browser.desktop</Filename>
        <Filename>xfce4-session-logout.desktop</Filename>
    </Layout>

</Menu>
EOF
