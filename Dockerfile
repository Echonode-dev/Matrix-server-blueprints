FROM matrixdotorg/dendrite-monolith:latest

COPY dendrite.yaml /etc/dendrite/dendrite.yaml
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8008
ENTRYPOINT ["/start.sh"]
