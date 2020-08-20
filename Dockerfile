FROM i386/golang:1.15.0-buster as gobuild
ARG VERSION
WORKDIR ${GOPATH}/src/github.com/hikhvar
RUN git clone https://github.com/hikhvar/mqtt2prometheus.git
WORKDIR ${GOPATH}/src/github.com/hikhvar/mqtt2prometheus
RUN if [ $VERSION != "master" ]; then git checkout tags/$VERSION; fi
RUN make static_build TARGET_FILE=/bin/mqtt2prometheus
FROM i386/debian:buster-slim
ENV USER mqtt2prometheus
ENV UID 8002
ENV GID 8002
RUN addgroup --gid "${GID}" "${USER}" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "${USER}" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"
COPY --from=gobuild /bin/mqtt2prometheus /mqtt2prometheus/mqtt2prometheus
RUN chown -R ${UID}:${GID} /mqtt2prometheus
USER ${UID}:${GID}
EXPOSE 8002
ENTRYPOINT ["/mqtt2prometheus/mqtt2prometheus", "-config", "/mqtt2prometheus/config.yaml"]
