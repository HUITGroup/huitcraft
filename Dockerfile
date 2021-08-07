FROM openjdk:16-jdk-buster AS Builder
RUN apt-get update && apt-get install -y \
	curl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
WORKDIR /mcbuilder
RUN curl -OL https://hub.spigotmc.org/jenkins/job/BuildTools/lastStableBuild/artifact/target/BuildTools.jar
RUN java -jar BuildTools.jar --rev latest
