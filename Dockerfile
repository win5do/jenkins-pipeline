FROM ubuntu
COPY ./dist /opt/dist/
EXPOSE 5100
CMD ["/opt/dist/main"]
