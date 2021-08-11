#!/usr/bin/env sh

echo 'eula=true' > /mc/eula.txt
mv /mcbuilder/* /mc
exec java -Xms1G -Xmx3G -XX:+UseG1GC -jar /mc/spigot.jar