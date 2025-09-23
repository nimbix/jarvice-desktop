#!/usr/bin/env bash

mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

# Override all desktops
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="1"/>
          <property name="last-image" type="string" value="/usr/lib/JARVICE/tools/nimbix_desktop/share/icons/nimbix-logo.png"/>
          <property name="rgba1" type="array">
            <value type="double" value="0.082352941176470587"/>
            <value type="double" value="0.13333333333333336"/>
            <value type="double" value="0.20000000000000001"/>
            <value type="double" value="1"/>
          </property>
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
  <property name="last-settings-migration-version" type="uint" value="1"/>
</channel>
EOF
