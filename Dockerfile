# Pinned so redeploys don't silently pull a new major version.
# Bump deliberately: https://github.com/dani-garcia/vaultwarden/releases
FROM vaultwarden/server:1.37.3

# Railway injects PORT at build/run time; Rocket must listen on it.
ARG PORT=8080
ENV ROCKET_PORT=${PORT}

EXPOSE ${PORT}

CMD [ "./start.sh" ]
