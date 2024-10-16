#!/usr/bin/env bash

mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

# Override all desktops
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="image-path" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        <property name="last-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        <property name="last-single-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        <property name="image-show" type="bool" value="true"/>
        <property name="color1" type="array">
          <value type="uint" value="0"/>
          <value type="uint" value="14418"/>
          <value type="uint" value="26214"/>
          <value type="uint" value="65535"/>
        </property>
        <property name="image-style" type="int" value="1"/>
      </property>
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="1"/>
          <property name="last-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="1"/>
          <property name="last-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="1"/>
          <property name="last-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="1"/>
          <property name="last-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="2"/>
    <property name="file-icons" type="empty">
      <property name="show-removable" type="bool" value="false"/>
      <property name="show-trash" type="bool" value="false"/>
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-home" type="bool" value="false"/>
    </property>
  </property>
  <property name="desktop-menu" type="empty">
    <property name="show" type="bool" value="false"/>
  </property>
  <property name="windowlist-menu" type="empty">
    <property name="show" type="bool" value="false"/>
    <property name="show-workspace-names" type="bool" value="false"/>
  </property>
</channel>
EOF
