#!/usr/bin/env sh

echo 'eula=true' > /mc/eula.txt
mv /mcbuilder/* /mc
exec java -Xms1G -Xmx4G -XX:+UseG1GC -jar /mc/papermc.jar