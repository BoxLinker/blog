FROM index.boxlinker.com/library/nginx:alpine

COPY /boxci/src/github.com/BoxLinker/blog/public /usr/share/nginx/html