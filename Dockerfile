FROM openjdk:16.0.2-jdk-buster AS Builder
RUN apt-get update && apt-get install -y \
	curl \
	git \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
WORKDIR /mcbuilder
RUN git config --global core.autocrlf false
RUN curl -OL https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar
RUN curl -OL https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastStableBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
RUN java -jar -Xmx3G BuildTools.jar --rev 1.17.1
RUN mv spigot-*.jar spigot.jar

FROM openjdk:16.0.2 AS Runner
WORKDIR /mc
RUN echo 'eula=true' > eula.txt
COPY --from=Builder /mcbuilder/spigot.jar .
COPY --from=Builder /mcbuilder/Geyser-Spigot.jar ./plugins
RUN pwd
ENTRYPOINT [ "java", "-Xms1G", "-Xmx3G", "-XX:+UseG1GC", "-jar", "spigot.jar" ]