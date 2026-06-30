# Pinning the image by digest for security and reproducibility.
# This corresponds to the 'latest' tag as of 2026-06-29.
FROM matrixdotorg/dendrite-monolith:latest@sha256:7dafe6edfc8cfab758a68a4cf20414df1ade4a36b45b1852554d81fb70b1272c

COPY dendrite.yaml /etc/dendrite/dendrite.yaml
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8008
ENTRYPOINT ["/start.sh"]
