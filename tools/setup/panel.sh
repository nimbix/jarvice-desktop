#!/usr/bin/env bash

mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="false"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=960;y=1061"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="36"/>
      <property name="size" type="uint" value="36"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
      </property>
      <property name="background-style" type="uint" value="0"/>
      <property name="mode" type="uint" value="0"/>
      <property name="nrows" type="uint" value="1"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-icon" type="string" value="/usr/local/JARVICE/tools/nimbix_desktop/share/icons/nimbix-favicon.png"/>
      <property name="show-button-title" type="bool" value="true"/>
      <property name="show-menu-icons" type="bool" value="true"/>
      <property name="show-tooltips" type="bool" value="true"/>
      <property name="button-title" type="string" value="Nimbix"/>
      <property name="show-generic-names" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="grouping" type="uint" value="1"/>
    </property>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="pager"/>
  </property>
</channel>
EOF
