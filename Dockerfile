# A static site needs no build stage: the two source trees are joined by COPY, which is the
# same join build.sh performs for the local preview.
FROM nginx:1.27-alpine

RUN rm -f /usr/share/nginx/html/index.html /etc/nginx/conf.d/default.conf

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY site/ /usr/share/nginx/html/
COPY design-system/*.css /usr/share/nginx/html/design-system/

# 127.0.0.1 rather than localhost: busybox wget tries ::1 first, and the answer to a missing
# IPv6 listener is a confusing "unhealthy" rather than a useful error.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1

EXPOSE 80
