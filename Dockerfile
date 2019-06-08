FROM ubuntu
EXPOSE 80
COPY ./dist /opt/
CMD ["/opt/dist/main"]
