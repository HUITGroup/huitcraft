FROM alpine:latest AS Builder
RUN apk add --update-cache --no-cache \
	curl \
	git
WORKDIR /mcbuilder
RUN git config --global core.autocrlf false
RUN curl -OL https://papermc.io/api/v2/projects/paper/versions/1.17.1/builds/221/downloads/paper-1.17.1-221.jar
RUN curl -OL https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastStableBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
RUN curl -OL https://ci.opencollab.dev//job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar
RUN mv paper-*.jar papermc.jar

FROM openjdk:16.0.2 AS Runner
WORKDIR /mc
RUN mkdir -p /mcbuilder/plugins /runtime
COPY mcstart.sh /runtime
COPY --from=Builder /mcbuilder/papermc.jar /mcbuilder
COPY --from=Builder /mcbuilder/Geyser-Spigot.jar /mcbuilder/plugins
COPY --from=Builder /mcbuilder/floodgate-spigot.jar /mcbuilder/plugins
ENTRYPOINT [ "/runtime/mcstart.sh" ]