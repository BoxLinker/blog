FROM index.boxlinker.com/library/nginx:alpine
RUN ls
COPY public /usr/share/nginx/html